// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "src/libraries/DataTypes.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract PrimaryCharacterTest is Test, Utils, SetUp {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    function setUp() public {
        _setUp();
    }

    function testPrimaryCharacter() public {
        DataTypes.CreateCharacterData memory characterData = makeCharacterData(
            Const.MOCK_CHARACTER_HANDLE,
            bob
        );
        vm.prank(bob);
        web3Entry.createCharacter(characterData);

        // User's first character should be the primary character
        uint256 primaryCharacter = web3Entry.getPrimaryCharacterId(bob);
        assertEq(primaryCharacter, Const.FIRST_CHARACTER_ID);

        // UserTwo should fail to set the primary character as a character owned by user 1
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        vm.prank(carol);
        web3Entry.setPrimaryCharacterId(Const.FIRST_CHARACTER_ID);

        // User should set the new primary character
        DataTypes.CreateCharacterData memory characterData2 = makeCharacterData("handle2", bob);
        vm.prank(bob);
        web3Entry.createCharacter(characterData2);
        vm.prank(bob);
        web3Entry.setPrimaryCharacterId(2);
        uint256 primaryCharacter2 = web3Entry.getPrimaryCharacterId(bob);
        assertEq(primaryCharacter2, 2);

        // User should set the primary character
        vm.prank(bob);
        web3Entry.setPrimaryCharacterId(1);
        uint256 primaryCharacter3 = web3Entry.getPrimaryCharacterId(bob);
        assertEq(primaryCharacter3, 1);

        // User should transfer the primary character, and then their primary character and operator should be unset
        vm.startPrank(bob);
        web3Entry.setOperator(Const.FIRST_CHARACTER_ID, carol);
        address operator = web3Entry.getOperator(Const.FIRST_NOTE_ID);
        assertEq(operator, carol);
        web3Entry.transferFrom(bob, alice, Const.FIRST_NOTE_ID);
        uint256 primaryCharacter4 = web3Entry.getPrimaryCharacterId(bob);
        address operator2 = web3Entry.getOperator(Const.FIRST_NOTE_ID);
        assertEq(primaryCharacter4, 0);
        assertEq(operator2, address(0));
        vm.stopPrank();
    }

    function testTransferLinkedCharacter() public {
        // User should transfer the primary character, and the linklist
        vm.startPrank(bob);
        DataTypes.CreateCharacterData memory characterDataCarol = makeCharacterData(
            "handleforcarol",
            bob
        );
        web3Entry.createCharacter(characterDataCarol);
        DataTypes.CreateCharacterData memory characterDataCarol2 = makeCharacterData(
            "handleforcarol2",
            bob
        );
        web3Entry.createCharacter(characterDataCarol2);
        // link character
        bytes memory data = new bytes(0);
        DataTypes.linkCharacterData memory linkCharacterData = DataTypes.linkCharacterData(
            1,
            2,
            Const.FollowLinkType,
            data
        );
        web3Entry.linkCharacter(linkCharacterData);
        uint256 linklistid = web3Entry.getLinklistId(1, Const.FollowLinkType);
        assertEq(linklistid, Const.FIRST_LINKLIST_ID);
        // transfer
        web3Entry.transferFrom(bob, alice, Const.FIRST_CHARACTER_ID);
        address CharacterOwner = web3Entry.ownerOf(1);
        address linklistOwner = linklist.ownerOf(1);
        assertEq(CharacterOwner, alice);
        assertEq(linklistOwner, alice);

        // User without a character, and then receives a character, it should be unset
        web3Entry.transferFrom(bob, carol, 2);
        uint256 primaryCharactercarol = web3Entry.getPrimaryCharacterId(carol);
        assertEq(primaryCharactercarol, 0);
        vm.stopPrank();

        // UserTwo set primary character
        vm.startPrank(carol);
        web3Entry.setPrimaryCharacterId(2);
        uint256 primaryCharactercarol2 = web3Entry.getPrimaryCharacterId(carol);
        assertEq(primaryCharactercarol2, 2);

        // UserTwo should fail to set handle as a character owned by user 1
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setPrimaryCharacterId(1);

        //UserTwo should burn primary character
        web3Entry.burn(2);
        uint256 userCharacterID = web3Entry.getPrimaryCharacterId(carol);
        assertEq(userCharacterID, 0);
        string memory userHandel = web3Entry.getHandle(2);
        assertEq(userHandel, "");
        address userOperator = web3Entry.getOperator(2);
        assertEq(userOperator, address(0));
        DataTypes.Character memory userCharacter = web3Entry.getCharacter(2);
        assertEq(userCharacter.noteCount, 0);
        assertEq(userCharacter.characterId, 0);
    }
}