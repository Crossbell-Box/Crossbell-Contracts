// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/console2.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/misc/NewbieVillage.sol";

contract NewbieVillageTest is Test, SetUp, Utils {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    address public alice = address(0x1111);
    address public bob = address(0x2222);

    NewbieVillage public newbie;

    function setUp() public {
        _setUp();

        newbie = new NewbieVillage();
        newbie.initialize(address(web3Entry));

        newbie.grantRole(OPERATOR_ROLE, alice);
    }

    function testNewbieInitializeFail() public {
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        newbie.initialize(address(web3Entry));
    }

    function testNewbieLinkCharacter() public {
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbie)));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));

        assertEq(web3Entry.ownerOf(Const.FIRST_CHARACTER_ID), address(newbie));
        assertEq(web3Entry.ownerOf(Const.SECOND_CHARACTER_ID), bob);

        vm.prank(alice);
        Web3Entry(address(newbie)).linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        assertEq(linklist.ownerOf(1), address(newbie));
    }

    function testNewbieSetCharacterUri() public {
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbie)));

        vm.prank(alice);
        Web3Entry(address(newbie)).setCharacterUri();
    }

    function testNewbieLinkCharacterFail() public {
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbie)));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));

        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(bob),
                " is missing role ",
                Strings.toHexString(uint256(OPERATOR_ROLE), 32)
            )
        );
        vm.prank(bob);
        Web3Entry(address(newbie)).linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
    }

    function testNewbiePostNote() public {
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbie)));

        vm.prank(alice);
        Web3Entry(address(newbie)).postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        _matchNote(
            note,
            Const.bytes32Zero,
            Const.bytes32Zero,
            Const.MOCK_NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testNewbieSetOperator() public {
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbie)));

        vm.prank(alice);
        Web3Entry(address(newbie)).setOperator(Const.FIRST_CHARACTER_ID, bob);

        // check operator
        assertEq(web3Entry.getOperator(Const.FIRST_CHARACTER_ID), bob);
    }

    function testNewbieTransferCharacter() public {
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbie)));

        vm.prank(alice);
        Web3Entry(address(newbie)).transferFrom(address(newbie), bob, Const.FIRST_CHARACTER_ID);
        assertEq(web3Entry.ownerOf(Const.FIRST_CHARACTER_ID), bob);
    }

    function testNewbieRole() public {
        // check role
        assertEq(cbt.hasRole(OPERATOR_ROLE, alice), false);
        assertEq(cbt.hasRole(OPERATOR_ROLE, bob), false);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, alice), false);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, bob), false);

        // grant role
        cbt.grantRole(OPERATOR_ROLE, bob);
        cbt.grantRole(DEFAULT_ADMIN_ROLE, alice);

        // check role
        assertEq(cbt.hasRole(OPERATOR_ROLE, alice), false);
        assertEq(cbt.hasRole(OPERATOR_ROLE, bob), true);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, alice), true);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, bob), false);

        // get role member
        assertEq(cbt.getRoleMember(DEFAULT_ADMIN_ROLE, 1), alice);
        assertEq(cbt.getRoleMember(OPERATOR_ROLE, 0), bob);

        // get role admin
        assertEq(cbt.getRoleAdmin(OPERATOR_ROLE), DEFAULT_ADMIN_ROLE);
        assertEq(cbt.getRoleAdmin(DEFAULT_ADMIN_ROLE), DEFAULT_ADMIN_ROLE);

        // revoke role
        cbt.revokeRole(OPERATOR_ROLE, bob);
        assertEq(cbt.hasRole(OPERATOR_ROLE, bob), false);
    }

    function testNewbieRenounceRol() public {
        // grant role to bob
        cbt.grantRole(OPERATOR_ROLE, bob);
        assertEq(cbt.hasRole(OPERATOR_ROLE, bob), true);
        assertEq(cbt.getRoleMemberCount(OPERATOR_ROLE), 1);
        assertEq(cbt.getRoleMember(OPERATOR_ROLE, 0), bob);

        // renounce role
        vm.prank(bob);
        cbt.renounceRole(OPERATOR_ROLE, bob);
        assertEq(cbt.hasRole(OPERATOR_ROLE, bob), false);
        assertEq(cbt.getRoleMemberCount(OPERATOR_ROLE), 0);
    }
}
