// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {Test} from "forge-std/Test.sol";
import {Web3Entry} from "../../contracts/Web3Entry.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {Events} from "../../contracts/libraries/Events.sol";
import {
    ErrSocialTokenExists,
    ErrNotAddressOwner,
    ErrHandleExists,
    ErrNotCharacterOwner,
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote,
    ErrCharacterNotExists,
    ErrNoteIsDeleted,
    ErrNoteNotExists,
    ErrNoteLocked,
    ErrHandleLengthInvalid,
    ErrHandleContainsInvalidCharacters
} from "../../contracts/libraries/Error.sol";
import {Const} from "../helpers/Const.sol";
import {Utils} from "../helpers/Utils.sol";
import {SetUp} from "../helpers/SetUp.sol";

contract CreateCharacterTest is Test, SetUp, Utils {
    /* solhint-disable comprehensive-interface */
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

        // check state
        assertEq(web3Entry.ownerOf(Const.FIRST_CHARACTER_ID), bob);
        assertEq(web3Entry.totalSupply(), 1);
        DataTypes.Character memory character = web3Entry.getCharacterByHandle(
            Const.MOCK_CHARACTER_HANDLE
        );
        assertEq(character.characterId, Const.FIRST_CHARACTER_ID);
        assertEq(character.handle, Const.MOCK_CHARACTER_HANDLE);
        assertEq(character.uri, Const.MOCK_CHARACTER_URI);
        assertEq(web3Entry.getHandle(Const.FIRST_CHARACTER_ID), Const.MOCK_CHARACTER_HANDLE);
        // get character by calling `getCharacter`
        DataTypes.Character memory character2 = web3Entry.getCharacter(Const.FIRST_CHARACTER_ID);
        assertEq(character2.characterId, character.characterId);
        assertEq(character2.handle, character.handle);
        assertEq(character2.uri, character.uri);
        assertEq(character2.noteCount, character.noteCount);
        assertEq(character2.socialToken, character.socialToken);
        assertEq(character2.linkModule, character.linkModule);
    }

    // solhint-disable-next-line function-max-lines
    function testCreateCharacterAndSetHandleFail() public {
        vm.startPrank(bob);

        // handle length > 31
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.createCharacter(makeCharacterData("da2423cea4f1047556e7a142f81a7eda", bob));

        // empty handle
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.createCharacter(makeCharacterData("", bob));

        // handle length < 3
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.createCharacter(makeCharacterData("a", bob));
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
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
            vm.expectRevert(abi.encodeWithSelector(ErrHandleContainsInvalidCharacters.selector));
            web3Entry.createCharacter(makeCharacterData(handles[i], bob));

            // set handle fail
            vm.expectRevert(abi.encodeWithSelector(ErrHandleContainsInvalidCharacters.selector));
            web3Entry.setHandle(1, handles[i]);
        }
    }
}
