// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../Web3Entry.sol";
import "../../libraries/DataTypes.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract CreateCharacterTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);

    function setUp() public {
        _setUp();
    }

    function testCreateCharacter() public {
        DataTypes.CreateCharacterData memory characterData = makeCharacterData(
            Const.MOCK_CHARACTER_HANDLE,
            bob
        );

        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        // The event we expect
        emit Events.CharacterCreated(1, bob, bob, Const.MOCK_CHARACTER_HANDLE, block.timestamp);
        // The event we get
        vm.prank(bob);
        web3Entry.createCharacter(characterData);

        // "User should fail to create character with invalid handle"
        string memory handle = "da2423cea4f1047556e7a142f81a7eda";
        DataTypes.CreateCharacterData memory characterData1 = makeCharacterData(handle, bob);
        vm.expectRevert(abi.encodePacked("HandleLengthInvalid"));
        vm.prank(bob);
        web3Entry.createCharacter(characterData1);

        string memory handle2 = "";
        DataTypes.CreateCharacterData memory characterData2 = makeCharacterData(handle2, bob);
        vm.expectRevert(abi.encodePacked("HandleLengthInvalid"));
        vm.prank(bob);
        web3Entry.createCharacter(characterData2);

        string memory handle3 = "a";
        DataTypes.CreateCharacterData memory characterData3 = makeCharacterData(handle3, bob);
        vm.expectRevert(abi.encodePacked("HandleLengthInvalid"));
        vm.prank(bob);
        web3Entry.createCharacter(characterData3);

        string memory handle4 = "ab";
        DataTypes.CreateCharacterData memory characterData4 = makeCharacterData(handle4, bob);
        vm.expectRevert(abi.encodePacked("HandleLengthInvalid"));
        vm.prank(bob);
        web3Entry.createCharacter(characterData4);

        address owner = web3Entry.ownerOf(Const.FIRST_CHARACTER_ID);
        uint256 totalSupply = web3Entry.totalSupply();
        DataTypes.Character memory character = web3Entry.getCharacterByHandle(
            Const.MOCK_CHARACTER_HANDLE
        );

        assertEq(owner, bob);
        assertEq(totalSupply, 1);
        assertEq(character.characterId, Const.FIRST_CHARACTER_ID);
        assertEq(character.handle, Const.MOCK_CHARACTER_HANDLE);
        assertEq(character.uri, Const.MOCK_CHARACTER_URI);
    }
}
