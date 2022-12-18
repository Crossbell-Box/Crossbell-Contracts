// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../../contracts/misc/NewbieVilla.sol";

contract NewbieVillaTest is Test, SetUp, Utils {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public xsyncOperator = address(0x3333);

    NewbieVilla public newbieVilla;

    function setUp() public {
        _setUp();

        newbieVilla = new NewbieVilla();
        newbieVilla.initialize(address(web3Entry), xsyncOperator);

        // grant mint role to alice
        newbieVilla.grantRole(ADMIN_ROLE, alice);
    }

    function testNewbieInitializeFail() public {
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        newbieVilla.initialize(address(web3Entry), xsyncOperator);
    }

    function testNewbieCreateCharacter() public {
        vm.prank(alice);
        Web3Entry(address(web3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbieVilla))
        );

        // check operators
        address[] memory operators = web3Entry.getOperators(Const.FIRST_CHARACTER_ID);
        assertEq(operators[0], alice);
        assertEq(operators[1], xsyncOperator);

        // check operator permission bitmap
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, alice),
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, xsyncOperator),
            OP.POST_NOTE_PERMISSION_BITMAP
        );
    }

    function testNewbieCreateCharacterFail() public {
        // bob has no mint role, so he can't send character to newbieVilla contract
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NewbieVilla: receive unknown character"));
        Web3Entry(address(web3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbieVilla))
        );
    }

    function testTransferNewbieIn() public {
        vm.prank(alice);
        Web3Entry(address(web3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(alice))
        );
        vm.prank(alice);
        Web3Entry(address(web3Entry)).safeTransferFrom(
            address(alice),
            address(newbieVilla),
            Const.FIRST_CHARACTER_ID
        );
        // check operators
        address[] memory operators = web3Entry.getOperators(Const.FIRST_CHARACTER_ID);
        assertEq(operators[0], alice);
        assertEq(operators[1], xsyncOperator);

        // check operator permission bitmap
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, alice),
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, xsyncOperator),
            OP.POST_NOTE_PERMISSION_BITMAP
        );
    }

    function testTransferNewbieInFail() public {
        vm.startPrank(bob);
        Web3Entry(address(web3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(bob))
        );
        vm.expectRevert(abi.encodePacked("NewbieVilla: receive unknown character"));
        Web3Entry(address(web3Entry)).safeTransferFrom(
            address(bob),
            address(newbieVilla),
            Const.FIRST_CHARACTER_ID
        );

        NFT nft = new NFT();
        nft.mint(bob);
        vm.expectRevert(abi.encodePacked("NewbieVilla: receive unknown token"));
        nft.safeTransferFrom(address(bob), address(newbieVilla), Const.FIRST_CHARACTER_ID);
    }

    function testWithdrawNewbieOut() public {
        // In Hardhat
    }

    function testExpired() public {
        vm.expectRevert("NewbieVilla: receipt has expired");
        newbieVilla.withdraw(bob, 1, 0, block.timestamp - 1, "");
    }

    function testNewbieRole() public {
        // check role
        assertEq(cbt.hasRole(ADMIN_ROLE, alice), false);
        assertEq(cbt.hasRole(ADMIN_ROLE, bob), false);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, alice), false);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, bob), false);

        // grant role
        cbt.grantRole(ADMIN_ROLE, bob);
        cbt.grantRole(DEFAULT_ADMIN_ROLE, alice);

        // check role
        assertEq(cbt.hasRole(ADMIN_ROLE, alice), false);
        assertEq(cbt.hasRole(ADMIN_ROLE, bob), true);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, alice), true);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, bob), false);

        // get role member
        assertEq(cbt.getRoleMember(DEFAULT_ADMIN_ROLE, 1), alice);
        assertEq(cbt.getRoleMember(ADMIN_ROLE, 0), bob);

        // get role admin
        assertEq(cbt.getRoleAdmin(ADMIN_ROLE), DEFAULT_ADMIN_ROLE);
        assertEq(cbt.getRoleAdmin(DEFAULT_ADMIN_ROLE), DEFAULT_ADMIN_ROLE);

        // revoke role
        cbt.revokeRole(ADMIN_ROLE, bob);
        assertEq(cbt.hasRole(ADMIN_ROLE, bob), false);
    }

    function testNewbieRenounceRole() public {
        // grant role to bob
        cbt.grantRole(ADMIN_ROLE, bob);
        assertEq(cbt.hasRole(ADMIN_ROLE, bob), true);
        assertEq(cbt.getRoleMemberCount(ADMIN_ROLE), 1);
        assertEq(cbt.getRoleMember(ADMIN_ROLE, 0), bob);

        // renounce role
        vm.prank(bob);
        cbt.renounceRole(ADMIN_ROLE, bob);
        assertEq(cbt.hasRole(ADMIN_ROLE, bob), false);
        assertEq(cbt.getRoleMemberCount(ADMIN_ROLE), 0);
    }
}
