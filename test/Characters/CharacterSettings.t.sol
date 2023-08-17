// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
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
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract CharacterSettingsTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
        web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE, alice));
    }

    /// Character Setting 1: Set Handle
    function testSetHandleByOwner() public {
        // owner can set character uri
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetHandle(address(alice), FIRST_CHARACTER_ID, CHARACTER_HANDLE2);
        web3Entry.setHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);
        // check old handle is removed
        _checkHandle(0, CHARACTER_HANDLE);
    }

    function testSetHandleByOwnerBehindPeriphery() public {
        // owner behind periphery can set handle
        vm.prank(address(periphery), alice);
        web3Entry.setHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);
        // check old handle is removed
        _checkHandle(0, CHARACTER_HANDLE);
    }

    function testSetHandleByOperator() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_NOTE_ID, bob, OP.OWNER_PERMISSION_BITMAP);
        // bob can set alice's handle
        vm.prank(bob);
        web3Entry.setHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);
        // check old handle is removed
        _checkHandle(0, CHARACTER_HANDLE);
    }

    function testSetHandleByOperatorBehindPeriphery() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_NOTE_ID, bob, OP.OWNER_PERMISSION_BITMAP);
        // bob can set alice's handle
        vm.prank(address(periphery), bob);
        web3Entry.setHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);

        // check alice's handle
        _checkHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);
        // check old handle is removed
        _checkHandle(0, CHARACTER_HANDLE);
    }

    // solhint-disable-next-line function-max-lines
    function testSetHandleFail() public {
        // not owner can't set handle
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);

        // operator without enough permission can't set handle
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);

        vm.prank(address(periphery), bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE2);

        // handle exists
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrHandleExists.selector));
        web3Entry.setHandle(FIRST_CHARACTER_ID, CHARACTER_HANDLE);

        // handle length > 31
        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(FIRST_CHARACTER_ID, "da2423cea4f1047556e7a142f81a7eda");

        // empty handle
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(FIRST_CHARACTER_ID, "");

        // handle length < 3
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(FIRST_CHARACTER_ID, "a");
        vm.expectRevert(abi.encodeWithSelector(ErrHandleLengthInvalid.selector));
        web3Entry.setHandle(FIRST_CHARACTER_ID, "ab");

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
            web3Entry.setHandle(FIRST_CHARACTER_ID, handles[i]);
        }
    }

    /// setSocialToken
    function testSetSocialTokenByOwner() public {
        // owner can set social token
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetSocialToken(address(alice), FIRST_CHARACTER_ID, address(token));
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(token));

        _checkSocialToken(CHARACTER_HANDLE, address(token));
    }

    function testSetSocialTokenByOwnerBehindPeriphery() public {
        // users behind periphery can set social token
        vm.prank(address(periphery), alice);
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(token));

        _checkSocialToken(CHARACTER_HANDLE, address(token));
    }

    function testSetSocialTokenByOperator() public {
        // operator can set social token
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.OWNER_PERMISSION_BITMAP);
        // bob can set alice's social token
        vm.prank(bob);
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(token));

        _checkSocialToken(CHARACTER_HANDLE, address(token));
    }

    function testSetSocialTokenByOperatorBehindPeriphery() public {
        // operator can set social token
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.OWNER_PERMISSION_BITMAP);
        // operator behind periphery can set social token
        vm.prank(address(periphery), bob);
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(token));

        _checkSocialToken(CHARACTER_HANDLE, address(token));
    }

    function testSetSocialTokenFailWithoutPermission() public {
        // case 1: not owner can't set social token
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(token));

        // case 2: operator without enough permission can't set social token
        // alice grant bob POST_NOTE_DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(token));

        //  case 3: operator behind periphery without enough permission can't set social token
        vm.prank(address(periphery), bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(token));
    }

    function testSetSocialTokenFailAlreadySet() public {
        vm.startPrank(alice);
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(token));
        // set social token again
        vm.expectRevert(abi.encodePacked(ErrSocialTokenExists.selector));
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(token));
        vm.stopPrank();
    }

    // Character Setting 2: Set uri
    function testSetCharacterUriByOwner() public {
        expectEmit(CheckAll);
        emit Events.SetCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);
        vm.prank(alice);
        web3Entry.setCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);
        _checkCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);
    }

    function testSetCharacterUriByOwnerBehindPeriphery() public {
        vm.prank(address(periphery), alice);
        web3Entry.setCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);
        _checkCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);
    }

    function testSetCharacterUriByOperator() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_NOTE_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        // bob can set alice's handle
        vm.prank(bob);
        web3Entry.setCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);
        _checkCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);
    }

    function testSetCharacterUriByOperatorBehindPeriphery() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_NOTE_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        // bob can set alice's handle
        vm.prank(address(periphery), bob);
        web3Entry.setCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);
        _checkCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);
    }

    function testSetCharacterUriFail() public {
        // not owner can't set character uri
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);

        // operator without enough permission can't set character uri
        // alice grant bob POST_NOTE_DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);

        //  operator behind periphery without enough permission can't set character uri
        vm.prank(address(periphery), bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setCharacterUri(FIRST_CHARACTER_ID, CHARACTER_URI);
    }

    function testTransferCharacterWithApproval() public {
        // alice approve bob to transfer NFT to bob
        vm.prank(alice);
        web3Entry.approve(bob, FIRST_CHARACTER_ID);
        assertEq(web3Entry.getApproved(FIRST_CHARACTER_ID), bob);
        vm.prank(bob);
        web3Entry.transferFrom(alice, bob, FIRST_CHARACTER_ID);
        assertEq(web3Entry.ownerOf(FIRST_CHARACTER_ID), bob);
        assertEq(web3Entry.getApproved(FIRST_CHARACTER_ID), address(0));

        // bob approve alice to transfer NFT to carol
        vm.prank(bob);
        web3Entry.setApprovalForAll(alice, true);
        assertEq(web3Entry.isApprovedForAll(bob, alice), true);
        vm.prank(alice);
        web3Entry.transferFrom(bob, carol, FIRST_CHARACTER_ID);
        assertEq(web3Entry.ownerOf(FIRST_CHARACTER_ID), carol);
        assertEq(web3Entry.getApproved(FIRST_CHARACTER_ID), address(0));
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
        assertEq(web3Entry.tokenURI(FIRST_CHARACTER_ID), CHARACTER_URI);
    }

    function _checkSocialToken(string memory handle, address socialToken) internal {
        DataTypes.Character memory character = web3Entry.getCharacterByHandle(handle);
        assertEq(character.socialToken, socialToken);
    }
}
