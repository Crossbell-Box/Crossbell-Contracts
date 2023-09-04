// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {OP} from "../../contracts/libraries/OP.sol";
import {Events} from "../../contracts/libraries/Events.sol";
import {
    ErrSocialTokenExists,
    ErrHandleExists,
    ErrNotEnoughPermission,
    ErrHandleLengthInvalid,
    ErrHandleContainsInvalidCharacters
} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract CharacterSettingsTest is CommonTest {
    uint256 public firstCharacter;

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        firstCharacter = _createCharacter(CHARACTER_HANDLE, alice);
    }

    /// Character Setting 1: Set Handle
    function testSetHandleByOwner() public {
        // owner can set character uri
        expectEmit(CheckAll);
        emit Events.SetHandle(alice, firstCharacter, CHARACTER_HANDLE2);
        vm.prank(alice);
        web3Entry.setHandle(firstCharacter, CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(firstCharacter, CHARACTER_HANDLE2);
        // check old handle is removed
        assertEq(web3Entry.getCharacterByHandle(CHARACTER_HANDLE).characterId, 0);
    }

    function testSetHandleByOwnerBehindPeriphery() public {
        // owner behind periphery can set handle
        vm.prank(address(periphery), alice);
        web3Entry.setHandle(firstCharacter, CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(firstCharacter, CHARACTER_HANDLE2);
        // check old handle is removed
        assertEq(web3Entry.getCharacterByHandle(CHARACTER_HANDLE).characterId, 0);
    }

    function testSetHandleByOperator() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.SET_HANDLE);
        // bob can set alice's handle
        vm.prank(bob);
        web3Entry.setHandle(firstCharacter, CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(firstCharacter, CHARACTER_HANDLE2);
        // check old handle is removed
        assertEq(web3Entry.getCharacterByHandle(CHARACTER_HANDLE).characterId, 0);
    }

    function testSetHandleByOperatorBehindPeriphery() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.SET_HANDLE);
        // bob can set alice's handle
        vm.prank(address(periphery), bob);
        web3Entry.setHandle(firstCharacter, CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(firstCharacter, CHARACTER_HANDLE2);
        // check old handle is removed
        assertEq(web3Entry.getCharacterByHandle(CHARACTER_HANDLE).characterId, 0);
    }

    function testSetHandleFail() public {
        // case 1: not owner can't set handle
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setHandle(firstCharacter, CHARACTER_HANDLE2);

        // case 2: operator without enough permission can't set handle
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.SET_SOCIAL_TOKEN);

        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setHandle(firstCharacter, CHARACTER_HANDLE2);

        // case 3: operator behind periphery without enough permission can't set handle
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(address(periphery), bob);
        web3Entry.setHandle(firstCharacter, CHARACTER_HANDLE2);

        // case 4: handle exists
        vm.expectRevert(abi.encodeWithSelector(ErrHandleExists.selector));
        vm.prank(alice);
        web3Entry.setHandle(firstCharacter, CHARACTER_HANDLE);

        // case 5: handle length > 31
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(firstCharacter, "da2423cea4f1047556e7a142f81a7eda");

        // cast 6: empty handle
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(firstCharacter, "");

        // case 7: handle length < 3
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(firstCharacter, "a");
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(firstCharacter, "ab");
    }

    // solhint-disable-next-line function-max-lines
    function testSetHandleFailWithInvalidChar() public {
        // cast 8: invalid character handle
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
            vm.prank(alice);
            web3Entry.setHandle(firstCharacter, handles[i]);
        }
    }

    /// setSocialToken
    function testSetSocialTokenByOwner() public {
        // owner can set social token
        expectEmit(CheckAll);
        emit Events.SetSocialToken(alice, firstCharacter, address(token));
        vm.prank(alice);
        web3Entry.setSocialToken(firstCharacter, address(token));

        _checkSocialToken(firstCharacter, address(token));
    }

    function testSetSocialTokenByOwnerBehindPeriphery() public {
        // users behind periphery can set social token
        vm.prank(address(periphery), alice);
        web3Entry.setSocialToken(firstCharacter, address(token));

        _checkSocialToken(firstCharacter, address(token));
    }

    function testSetSocialTokenByOperator() public {
        // operator can set social token
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.SET_SOCIAL_TOKEN);
        // bob can set alice's social token
        vm.prank(bob);
        web3Entry.setSocialToken(firstCharacter, address(token));

        _checkSocialToken(firstCharacter, address(token));
    }

    function testSetSocialTokenByOperatorBehindPeriphery() public {
        // operator can set social token
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.SET_SOCIAL_TOKEN);
        // operator behind periphery can set social token
        vm.prank(address(periphery), bob);
        web3Entry.setSocialToken(firstCharacter, address(token));

        _checkSocialToken(firstCharacter, address(token));
    }

    function testSetSocialTokenFailWithoutPermission() public {
        // case 1: not owner can't set social token
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setSocialToken(firstCharacter, address(token));

        // case 2: operator without enough permission can't set social token
        // alice grant bob POST_NOTE_DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            firstCharacter,
            bob,
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );

        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setSocialToken(firstCharacter, address(token));

        //  case 3: operator behind periphery without enough permission can't set social token
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(address(periphery), bob);
        web3Entry.setSocialToken(firstCharacter, address(token));
    }

    function testSetSocialTokenFailAlreadySet() public {
        vm.startPrank(alice);
        web3Entry.setSocialToken(firstCharacter, address(token));

        // set social token again
        vm.expectRevert(abi.encodePacked(ErrSocialTokenExists.selector));
        web3Entry.setSocialToken(firstCharacter, address(token));
        vm.stopPrank();
    }

    // Character Setting 2: Set uri
    function testSetCharacterUriByOwner() public {
        expectEmit(CheckAll);
        emit Events.SetCharacterUri(firstCharacter, CHARACTER_URI);
        vm.prank(alice);
        web3Entry.setCharacterUri(firstCharacter, CHARACTER_URI);

        _checkCharacterUri(firstCharacter, CHARACTER_URI);
    }

    function testSetCharacterUriByOwnerBehindPeriphery() public {
        vm.prank(address(periphery), alice);
        web3Entry.setCharacterUri(firstCharacter, CHARACTER_URI);

        _checkCharacterUri(firstCharacter, CHARACTER_URI);
    }

    function testSetCharacterUriByOperator() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, OP.DEFAULT_PERMISSION_BITMAP);

        // bob can set alice's handle
        vm.prank(bob);
        web3Entry.setCharacterUri(firstCharacter, CHARACTER_URI);

        _checkCharacterUri(firstCharacter, CHARACTER_URI);
    }

    function testSetCharacterUriByOperatorBehindPeriphery() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.SET_CHARACTER_URI);

        // bob can set alice's handle
        vm.prank(address(periphery), bob);
        web3Entry.setCharacterUri(firstCharacter, CHARACTER_URI);

        _checkCharacterUri(firstCharacter, CHARACTER_URI);
    }

    function testSetCharacterUriFail() public {
        // case 1: not owner can't set character uri
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setCharacterUri(firstCharacter, CHARACTER_URI);

        // case 2: operator without enough permission can't set character uri
        // alice grant bob POST_NOTE_DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.SET_LINKLIST_URI);

        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setCharacterUri(firstCharacter, CHARACTER_URI);

        //  case 3: operator behind periphery without enough permission can't set character uri
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(address(periphery), bob);
        web3Entry.setCharacterUri(firstCharacter, CHARACTER_URI);
    }

    function _checkHandle(uint256 characterId, string memory handle) internal {
        assertEq(web3Entry.getCharacterByHandle(handle).characterId, characterId);
        assertEq(web3Entry.getHandle(characterId), handle);
    }

    function _checkCharacterUri(uint256 characterId, string memory characterUri) internal {
        assertEq(web3Entry.getCharacterUri(characterId), characterUri);
        assertEq(web3Entry.tokenURI(characterId), characterUri);
    }

    function _checkSocialToken(uint256 characterId, address socialToken) internal {
        assertEq(web3Entry.getCharacter(characterId).socialToken, socialToken);
    }
}
