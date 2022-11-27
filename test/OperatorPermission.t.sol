// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/libraries/DataTypes.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "../contracts/modules/link/ApprovalLinkModule4Character.sol";
import "../contracts/modules/link/ApprovalLinkModule4Note.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../contracts/libraries/OP.sol";

contract OperatorTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);
    address public dick = address(0x4444);
    address public erik = address(0x5555);

    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testGrantOperatorPermissions() public {
        // alice set bob as her operator with DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // only only owner can grant operator
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
    }

    function testCheckPermissionAtPosition() public {
        // alice set bob as her operator with DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        bool permission = web3Entry.checkPermissionAtPosition(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.SET_HANDLE
        );
        assert(!permission);

        // check [0, 20] is set to false, which means default permission doesn't hava owner permission
        for (uint256 i = 0; i < 20; i++) {
            assert(!web3Entry.checkPermissionAtPosition(Const.FIRST_CHARACTER_ID, bob, i));
        }

        // check [21, 255] is set to true
        for (uint256 i = 20; i < 256; i++) {
            assert(web3Entry.checkPermissionAtPosition(Const.FIRST_CHARACTER_ID, bob, i));
        }
    }
}
