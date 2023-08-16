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

    function testCreateCharacterWithBurnedHandle() public {
        _createCharacter(CHARACTER_HANDLE, alice);

        // burn character
        vm.prank(alice);
        web3Entry.burn(FIRST_CHARACTER_ID);

        // create character with a burned handle
        uint256 characterId = _createCharacter(CHARACTER_HANDLE, bob);
        // check handle
        assertEq(CHARACTER_HANDLE, web3Entry.getHandle(characterId));
    }

    // test for ERC721Enumerable
    function testCreateCharactersWithBurn() public {
        _createCharacter("alice", alice);
        _createCharacter("bob", alice);
        _createCharacter("carol", alice);
        _createCharacter("dick", alice);

        // burn tokenId 3
        vm.prank(alice);
        web3Entry.burn(3);

        // check owner
        assertEq(web3Entry.ownerOf(1), alice);
        assertEq(web3Entry.ownerOf(2), alice);
        assertEq(web3Entry.ownerOf(4), alice);
        // check total supply
        assertEq(web3Entry.totalSupply(), 3);
        // check tokenOfOwnerByIndex
        assertEq(web3Entry.tokenOfOwnerByIndex(alice, 0), FIRST_CHARACTER_ID);
        assertEq(web3Entry.tokenOfOwnerByIndex(alice, 1), SECOND_CHARACTER_ID);
        assertEq(web3Entry.tokenOfOwnerByIndex(alice, 2), 4);
        // check tokenByIndex
        assertEq(web3Entry.tokenByIndex(0), FIRST_CHARACTER_ID);
        assertEq(web3Entry.tokenByIndex(1), SECOND_CHARACTER_ID);
        assertEq(web3Entry.tokenByIndex(2), 4);
    }
}
