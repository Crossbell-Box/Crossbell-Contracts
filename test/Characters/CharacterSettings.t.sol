// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../../contracts/Web3Entry.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/libraries/OP.sol";

contract CharacterSettingsTest is Test, SetUp, Utils {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
    }

    /// setHandle
    function testSetHandle() public {
        // owner can set character uri
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetHandle(
            address(alice),
            Const.FIRST_CHARACTER_ID,
            Const.MOCK_CHARACTER_HANDLE2
        );
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_HANDLE2);

        // users behind periphery can set handle
        vm.prank(address(periphery), alice);
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_HANDLE3);

        // operator can set handle
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_NOTE_ID, bob, OP.OWNER_PERMISSION_BITMAP);
        // bob can set alice's handle
        vm.prank(bob);
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_HANDLE4);

        // operator behind periphery can set handle
        vm.prank(address(periphery), bob);
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_HANDLE5);

        // check state
        string memory handle = web3Entry.getHandle(Const.FIRST_CHARACTER_ID);
        assertEq(handle, Const.MOCK_CHARACTER_HANDLE5);
        DataTypes.Character memory character = web3Entry.getCharacterByHandle(
            Const.MOCK_CHARACTER_HANDLE5
        );
        assertEq(character.characterId, Const.FIRST_CHARACTER_ID);
        // check previous handle
        character = web3Entry.getCharacterByHandle(Const.MOCK_CHARACTER_HANDLE4);
        assertEq(character.characterId, 0);
    }

    function testSetHandleFail() public {
        // not owner can't set handle
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_HANDLE2);

        // operator without enough permission can't set handle
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_HANDLE2);

        // handle exists
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrHandleExists.selector));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_HANDLE);
    }

    /// setSocialToken
    function testSetSocialToken1() public {
        // owner can set social token
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetSocialToken(address(alice), Const.FIRST_CHARACTER_ID, address(token));
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));
    }

    function testSetSocialToken2() public {
        // users behind periphery can set social token
        vm.prank(address(periphery), alice);
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));
    }

    function testSetSocialToken3() public {
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

    function testSetSocialToken4() public {
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
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));

        // can't set twice
        vm.startPrank(alice);
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));
        vm.expectRevert(abi.encodeWithSelector(ErrSocialTokenExists.selector));
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(token));
    }

    function testSetPrimaryCharacterId() public {
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, alice));
        // alice's primary character should be its first character
        uint256 characterId = web3Entry.getPrimaryCharacterId(alice);
        assertEq(characterId, Const.FIRST_CHARACTER_ID);

        // owner can set primary character
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetPrimaryCharacterId(
            alice,
            Const.SECOND_CHARACTER_ID,
            Const.FIRST_CHARACTER_ID
        );
        web3Entry.setPrimaryCharacterId(Const.SECOND_CHARACTER_ID);

        // owner behind periphery can
        vm.prank(address(periphery), alice);
        web3Entry.setPrimaryCharacterId(Const.SECOND_CHARACTER_ID);

        // check state
        characterId = web3Entry.getPrimaryCharacterId(alice);
        assertEq(characterId, Const.SECOND_CHARACTER_ID);
    }

    function testSetPrimaryCharacterIdFail() public {
        // not owner can't set primary character
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotCharacterOwner.selector));
        web3Entry.setPrimaryCharacterId(Const.FIRST_CHARACTER_ID);
    }

    /// setCharacterUri
    function testSetCharacterUri() public {
        // owner can set character uri
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetCharacterUri(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_URI);
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_URI);

        // users behind periphery can set character uri
        vm.prank(address(periphery), alice);
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_URI);

        // operator can set character uri
        // alice grant bob DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_NOTE_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        // bob can set alice's character uri
        vm.prank(bob);
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_URI);

        // operator behind periphery can set character uri
        vm.prank(address(periphery), bob);
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_URI);

        // check state
        string memory uri = web3Entry.getCharacterUri(Const.FIRST_CHARACTER_ID);
        assertEq(uri, Const.MOCK_CHARACTER_URI);
        string memory tokenUri = web3Entry.tokenURI(Const.FIRST_CHARACTER_ID);
        assertEq(tokenUri, Const.MOCK_CHARACTER_URI);
    }

    function testSetCharacterUriFail() public {
        // not owner can't set character uri
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_URI);

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
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_URI);

        //  operator behind periphery without enough permission can't set character uri
        vm.prank(address(periphery), bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, Const.MOCK_CHARACTER_URI);
    }
}
