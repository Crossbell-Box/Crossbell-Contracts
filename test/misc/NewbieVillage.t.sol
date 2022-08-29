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

    address public alice = address(0x1111);
    address public bob = address(0x2222);

    NewbieVillage public newbie;

    function setUp() public {
        _setUp();

        newbie = new NewbieVillage();
        newbie.initialize(address(web3Entry));

        newbie.grantRole(OPERATOR_ROLE, alice);
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

    function testTransferCharacter() public {
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbie)));

        vm.prank(alice);
        Web3Entry(address(newbie)).transferFrom(address(newbie), bob, Const.FIRST_CHARACTER_ID);
        assertEq(web3Entry.ownerOf(Const.FIRST_CHARACTER_ID), bob);
    }
}
