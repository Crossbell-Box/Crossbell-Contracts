// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {Test} from "forge-std/Test.sol";
import {Web3Entry} from "../../contracts/Web3Entry.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {OP} from "../../contracts/libraries/OP.sol";
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
import {CommonTest} from "../helpers/CommonTest.sol";

contract CharacterSettingsTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
        web3Entry.createCharacter(makeCharacterData(Const.CHARACTER_HANDLE, alice));
    }

    /// Character Setting 1: Set Handle
    function testSetHandleByOwner() public {
        // owner can set character uri
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetHandle(address(alice), Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);
        // check old handle is removed
        _checkHandle(0, Const.CHARACTER_HANDLE);
    }

    function testSetHandleByOwnerBehindPeriphery() public {
        // owner behind periphery can set handle
        vm.prank(address(periphery), alice);
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);
        // check old handle is removed
        _checkHandle(0, Const.CHARACTER_HANDLE);
    }

    function testSetHandleByOperator() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_NOTE_ID, bob, OP.OWNER_PERMISSION_BITMAP);
        // bob can set alice's handle
        vm.prank(bob);
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);
        // check old handle is removed
        _checkHandle(0, Const.CHARACTER_HANDLE);
    }

    function testSetHandleByOperatorBehindPeriphery() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_NOTE_ID, bob, OP.OWNER_PERMISSION_BITMAP);
        // bob can set alice's handle
        vm.prank(address(periphery), bob);
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);
        // check old handle is removed
        _checkHandle(0, Const.CHARACTER_HANDLE);
    }

    // solhint-disable-next-line function-max-lines
    function testSetHandleFail() public {
        // not owner can't set handle
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);

        // operator without enough permission can't set handle
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);

        vm.prank(address(periphery), bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE2);

        // handle exists
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrHandleExists.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.CHARACTER_HANDLE);

        // handle length > 31
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, "da2423cea4f1047556e7a142f81a7eda");

        // empty handle
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, "");

        // handle length < 3
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, "a");
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, "ab");

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

        for (uint256 i = 0; i < handles.length; i++) {
            // set handle fail
            vm.expectRevert(abi.encodeWithSelector(ErrHandleContainsInvalidCharacters.selector));
            web3Entry.setHandle(Const.FIRST_CHARACTER_ID, handles[i]);
        }
    }

    /// setSocialToken
    function testSetSocialTokenByOwner() public {
        // owner can set social token
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetSocialToken(address(alice), Const.FIRST_CHARACTER_ID, address(token));
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));
    }

    function testSetSocialTokenByOwnerBehindPeriphery() public {
        // users behind periphery can set social token
        vm.prank(address(periphery), alice);
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));
    }

    function testSetSocialTokenByOperator() public {
        // operator can set social token
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OWNER_PERMISSION_BITMAP
        );
        // bob can set alice's social token
        vm.prank(bob);
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));
    }

    function testSetSocialTokenByOperatorBehindPeriphery() public {
        // operator can set social token
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OWNER_PERMISSION_BITMAP
        );
        // operator behind periphery can set social token
        vm.prank(address(periphery), bob);
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));
    }

    function testSetSocialTokenFail() public {
        // not owner can't set social token
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));

        // operator without enough permission can't set social token
        // alice grant bob POST_NOTE_DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));

        //  operator behind periphery without enough permission can't set social token
        vm.prank(address(periphery), bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setCharacterUri(1, Const.MOCK_URI);
    }

    // Character Setting 2: Set uri
    function testSetCharacterUriByOwner() public {
        expectEmit(CheckAll);
        emit Events.SetCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);
        vm.prank(alice);
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);
        _checkCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);
    }

    function testSetCharacterUriByOwnerBehindPeriphery() public {
        vm.prank(address(periphery), alice);
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);
        _checkCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);
    }

    function testSetCharacterUriByOperator() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_NOTE_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        // bob can set alice's handle
        vm.prank(bob);
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);
        _checkCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);
    }

    function testSetCharacterUriByOperatorBehindPeriphery() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_NOTE_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        // bob can set alice's handle
        vm.prank(address(periphery), bob);
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);
        _checkCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);
    }

    function testSetCharacterUriFail() public {
        // not owner can't set character uri
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);

        // operator without enough permission can't set character uri
        // alice grant bob POST_NOTE_DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);

        //  operator behind periphery without enough permission can't set character uri
        vm.prank(address(periphery), bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.CHARACTER_URI);
    }

    function _checkHandle(uint256 characterId, string memory handle) internal {
        // query character by handle
        DataTypes.Character memory character = web3Entry.getCharacterByHandle(handle);
        assertEq(character.characterId, characterId);

        // query handle by characterId
        if (characterId != 0) {
            assertEq(handle, web3Entry.getHandle(characterId));
        }
    }

    function _checkCharacterUri(uint256 characterId, string memory characterUri) internal {
        assertEq(web3Entry.getCharacterUri(characterId), characterUri);

        assertEq(web3Entry.tokenURI(Const.FIRST_CHARACTER_ID), Const.CHARACTER_URI);
    }
}
