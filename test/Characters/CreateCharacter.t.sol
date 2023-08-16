// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {Events} from "../../contracts/libraries/Events.sol";
import {
    ErrHandleLengthInvalid,
    ErrHandleContainsInvalidCharacters
} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract CreateCharacterTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
    }

    function testCreateCharacter() public {
        DataTypes.CreateCharacterData memory characterData = makeCharacterData(
            CHARACTER_HANDLE,
            bob
        );

        expectEmit(CheckAll);
        // The event we expect
        emit Events.CharacterCreated(1, bob, bob, CHARACTER_HANDLE, block.timestamp);
        // The event we get
        vm.prank(bob);
        web3Entry.createCharacter(characterData);

        // check state
        assertEq(web3Entry.ownerOf(FIRST_CHARACTER_ID), bob);
        assertEq(web3Entry.totalSupply(), 1);
        // check character
        _matchCharacter(
            web3Entry.getCharacterByHandle(CHARACTER_HANDLE),
            FIRST_CHARACTER_ID,
            CHARACTER_HANDLE,
            CHARACTER_URI,
            0,
            address(0),
            address(0)
        );
        assertEq(web3Entry.getHandle(FIRST_CHARACTER_ID), CHARACTER_HANDLE);
        // get character by calling `getCharacter`
        _matchCharacter(
            web3Entry.getCharacter(FIRST_CHARACTER_ID),
            FIRST_CHARACTER_ID,
            CHARACTER_HANDLE,
            CHARACTER_URI,
            0,
            address(0),
            address(0)
        );
    }

    function testCreateCharacterWithInvalidHandleFail() public {
        vm.startPrank(bob);
        // case 1: handle length > 31
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.createCharacter(makeCharacterData("da2423cea4f1047556e7a142f81a7eda", bob));

        // case 2: empty handle
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.createCharacter(makeCharacterData("", bob));

        // case 3: handle length < 3
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.createCharacter(makeCharacterData("ab", bob));
    }

    // solhint-disable-next-line function-max-lines
    function testCreateCharacterAndSetHandleFail() public {
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
            vm.prank(bob);
            vm.expectRevert(abi.encodeWithSelector(ErrHandleContainsInvalidCharacters.selector));
            web3Entry.setHandle(1, handles[i]);
        }
    }

    // test for ERC721Enumerable
    function testCreateCharacters() public {
        _createCharacter("alice", alice);
        _createCharacter("bob", alice);
        _createCharacter("carol", alice);

        // check owner
        assertEq(web3Entry.ownerOf(FIRST_CHARACTER_ID), alice);
        assertEq(web3Entry.ownerOf(SECOND_CHARACTER_ID), alice);
        assertEq(web3Entry.ownerOf(THIRD_CHARACTER_ID), alice);
        // check total supply
        assertEq(web3Entry.totalSupply(), 3);
        // check tokenOfOwnerByIndex
        assertEq(web3Entry.tokenOfOwnerByIndex(alice, 0), FIRST_CHARACTER_ID);
        assertEq(web3Entry.tokenOfOwnerByIndex(alice, 1), SECOND_CHARACTER_ID);
        assertEq(web3Entry.tokenOfOwnerByIndex(alice, 2), THIRD_CHARACTER_ID);
        // check tokenByIndex
        assertEq(web3Entry.tokenByIndex(0), FIRST_CHARACTER_ID);
        assertEq(web3Entry.tokenByIndex(1), SECOND_CHARACTER_ID);
        assertEq(web3Entry.tokenByIndex(2), THIRD_CHARACTER_ID);
    }
}
