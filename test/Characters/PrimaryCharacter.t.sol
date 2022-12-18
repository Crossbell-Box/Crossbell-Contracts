// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "contracts/libraries/DataTypes.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/libraries/OP.sol";

contract PrimaryCharacterTest is Test, Utils, SetUp {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    function setUp() public {
        _setUp();
    }

    function testPrimaryCharacter() public {
        vm.startPrank(bob);
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, bob));

        // User's first character should be the primary character
        uint256 primaryCharacter = web3Entry.getPrimaryCharacterId(bob);
        assertEq(primaryCharacter, Const.FIRST_CHARACTER_ID);

        // User should set the new primary character
        web3Entry.createCharacter(makeCharacterData("handle2", bob));
        web3Entry.setPrimaryCharacterId(2);
        assertEq(web3Entry.getPrimaryCharacterId(bob), 2);

        // User should set the primary character
        web3Entry.setPrimaryCharacterId(1);
        assertEq(web3Entry.getPrimaryCharacterId(bob), 1);

        // User should transfer the primary character, and then their primary character and operator should be unset
        // web3Entry.setOperator(Const.FIRST_CHARACTER_ID, carol);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            carol,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, carol),
            OP.DEFAULT_PERMISSION_BITMAP
        );
        web3Entry.transferFrom(bob, alice, Const.FIRST_NOTE_ID);
        assertEq(web3Entry.getPrimaryCharacterId(bob), 0);
        assertEq(web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, carol), 0);
        assertEq(web3Entry.getOperators(Const.FIRST_CHARACTER_ID).length, 0);
        vm.stopPrank();
    }

    function testSetPrimaryCharacterIdFail() public {
        vm.prank(bob);
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, bob));

        // UserTwo should fail to set the primary character as a character owned by user 1
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        vm.prank(carol);
        web3Entry.setPrimaryCharacterId(Const.FIRST_CHARACTER_ID);
    }

    function testTransferLinkedCharacter() public {
        // User should transfer the primary character, and the linklist
        vm.startPrank(bob);
        web3Entry.createCharacter(makeCharacterData("handleforcarol", bob));
        web3Entry.createCharacter(makeCharacterData("handleforcarol2", bob));
        // link character
        bytes memory data = new bytes(0);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, Const.FollowLinkType, data));
        assertEq(web3Entry.getLinklistId(1, Const.FollowLinkType), Const.FIRST_LINKLIST_ID);
        // transfer
        web3Entry.transferFrom(bob, alice, Const.FIRST_CHARACTER_ID);
        assertEq(web3Entry.ownerOf(1), alice);
        assertEq(linklist.ownerOf(1), alice);

        // User without a character, and then receives a character, it should be unset
        web3Entry.transferFrom(bob, carol, 2);
        assertEq(web3Entry.getPrimaryCharacterId(carol), 0);
        vm.stopPrank();

        // UserTwo set primary character
        vm.startPrank(carol);
        web3Entry.setPrimaryCharacterId(2);
        assertEq(web3Entry.getPrimaryCharacterId(carol), 2);

        // UserTwo should fail to set handle as a character owned by user 1
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setPrimaryCharacterId(1);

        //UserTwo should burn primary character
        web3Entry.burn(2);
        assertEq(web3Entry.getPrimaryCharacterId(carol), 0);
        assertEq(web3Entry.getHandle(2), "");
        // assertEq(web3Entry.getOperator(2), address(0));
        // TODO get operators
        DataTypes.Character memory userCharacter = web3Entry.getCharacter(2);
        assertEq(userCharacter.noteCount, 0);
        assertEq(userCharacter.characterId, 0);
    }
}
