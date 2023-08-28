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
        expectEmit(CheckAll);
        emit Events.CharacterCreated(1, bob, bob, CHARACTER_HANDLE, block.timestamp);
        vm.prank(bob);
        uint256 characterId = web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE, bob));

        // check state
        assertEq(web3Entry.ownerOf(characterId), bob);
        assertEq(web3Entry.totalSupply(), 1);
        // check character
        _matchCharacter(
            web3Entry.getCharacterByHandle(CHARACTER_HANDLE),
            characterId,
            CHARACTER_HANDLE,
            CHARACTER_URI,
            0,
            address(0),
            address(0)
        );
        assertEq(web3Entry.getHandle(characterId), CHARACTER_HANDLE);
        // get character by calling `getCharacter`
        _matchCharacter(
            web3Entry.getCharacter(FIRST_CHARACTER_ID),
            characterId,
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
        vm.stopPrank();
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
            vm.expectRevert(abi.encodeWithSelector(ErrHandleContainsInvalidCharacters.selector));
            vm.prank(bob);
            web3Entry.setHandle(1, handles[i]);
        }
    }

    function testCreateCharacterWithBurnedHandle() public {
        uint256 characterId = _createCharacter(CHARACTER_HANDLE, alice);

        // burn character
        vm.prank(alice);
        web3Entry.burn(characterId);

        // create character with a burned handle
        characterId = _createCharacter(CHARACTER_HANDLE, bob);
        // check handle
        assertEq(CHARACTER_HANDLE, web3Entry.getHandle(characterId));
        assertEq(web3Entry.getCharacterByHandle(CHARACTER_HANDLE).characterId, characterId);
    }

    // test for ERC721Enumerable
    function testCreateCharactersWithBurn() public {
        uint256 firstCharacter = _createCharacter("alice", alice);
        uint256 secondCharacter = _createCharacter("bob", alice);
        uint256 thirdCharacter = _createCharacter("carol", alice);
        uint256 fourthCharacter = _createCharacter("dick", alice);

        // burn tokenId 3
        vm.prank(alice);
        web3Entry.burn(thirdCharacter);

        // check owner
        assertEq(web3Entry.ownerOf(firstCharacter), alice);
        assertEq(web3Entry.ownerOf(secondCharacter), alice);
        assertEq(web3Entry.ownerOf(fourthCharacter), alice);
        // check total supply
        assertEq(web3Entry.totalSupply(), 3);
        // check tokenOfOwnerByIndex
        assertEq(web3Entry.tokenOfOwnerByIndex(alice, 0), firstCharacter);
        assertEq(web3Entry.tokenOfOwnerByIndex(alice, 1), secondCharacter);
        assertEq(web3Entry.tokenOfOwnerByIndex(alice, 2), fourthCharacter);
        // check tokenByIndex
        assertEq(web3Entry.tokenByIndex(0), firstCharacter);
        assertEq(web3Entry.tokenByIndex(1), secondCharacter);
        assertEq(web3Entry.tokenByIndex(2), fourthCharacter);
    }

    function testBurnFailWithTokenNotExists() public {
        vm.expectRevert("ERC721: operator query for nonexistent token");
        web3Entry.burn(3);
    }
}
