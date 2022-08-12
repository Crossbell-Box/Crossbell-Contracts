// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/Web3Entry.sol";
import "../../contracts/libraries/DataTypes.sol";
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

    function testCreateCharacterAndSetHandleFail() public {
        vm.startPrank(bob);

        // handle length > 31
        vm.expectRevert(abi.encodePacked("HandleLengthInvalid"));
        web3Entry.createCharacter(makeCharacterData("da2423cea4f1047556e7a142f81a7eda", bob));

        // empty handle
        vm.expectRevert(abi.encodePacked("HandleLengthInvalid"));
        web3Entry.createCharacter(makeCharacterData("", bob));

        // handle length < 3
        vm.expectRevert(abi.encodePacked("HandleLengthInvalid"));
        web3Entry.createCharacter(makeCharacterData("a", bob));
        vm.expectRevert(abi.encodePacked("HandleLengthInvalid"));
        web3Entry.createCharacter(makeCharacterData("ab", bob));

        // invalid character handle
        // string memory s = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()+|[]:,";
        string[42] memory handles = [
            "abA",
            "abB",
            "abC",
            "abD",
            "abE",
            "abF",
            "abG",
            "abH",
            "abI",
            "abJ",
            "abK",
            "abL",
            "abM",
            "abN",
            "abO",
            "abP",
            "abQ",
            "abR",
            "abS",
            "abT",
            "abU",
            "abV",
            "abW",
            "abX",
            "abY",
            "abZ",
            "ab!",
            "ab@",
            "ab#",
            "ab$",
            "ab%",
            "ab^",
            "ab&",
            "ab*",
            "ab(",
            "ab)",
            "ab+",
            "ab|",
            "ab[",
            "ab]",
            "ab:",
            "ab,"
        ];
        web3Entry.createCharacter(makeCharacterData("abcd", bob));

        for (uint256 i = 0; i < handles.length; i++) {
            vm.expectRevert(abi.encodePacked("HandleContainsInvalidCharacters"));
            web3Entry.createCharacter(makeCharacterData(handles[i], bob));

            // set handle fail
            vm.expectRevert(abi.encodePacked("HandleContainsInvalidCharacters"));
            web3Entry.setHandle(1, handles[i]);
        }
    }
}
