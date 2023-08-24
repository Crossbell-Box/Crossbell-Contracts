// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Events} from "../../contracts/libraries/Events.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {
    ErrNotEnoughPermission,
    ErrCharacterNotExists,
    ErrHandleExists
} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract LinkCharacterTest is CommonTest {
    uint256 public firstCharacter;
    uint256 public secondCharacter;

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        firstCharacter = _createCharacter(CHARACTER_HANDLE, alice);
        secondCharacter = _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testLinkCharacter() public {
        expectEmit(CheckAll);
        emit Events.LinkCharacter(alice, firstCharacter, secondCharacter, FollowLinkType, 1);
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, FollowLinkType, "")
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.getOwnerCharacterId(1), firstCharacter);
        assertEq(web3Entry.getLinklistType(1), FollowLinkType);
        assertEq(linklist.getLinkingCharacterIds(1).length, 1);
        assertEq(linklist.getLinkingCharacterIds(1)[0], secondCharacter);
        assertEq(linklist.getLinkingCharacterListLength(1), 1);
    }

    function testLinkCharacterWithPeriphery() public {
        expectEmit(CheckAll);
        emit Events.LinkCharacter(alice, firstCharacter, secondCharacter, FollowLinkType, 1);
        vm.prank(address(periphery), alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, FollowLinkType, "")
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.getOwnerCharacterId(1), firstCharacter);
        assertEq(web3Entry.getLinklistType(1), FollowLinkType);
        assertEq(linklist.getLinkingCharacterIds(1).length, 1);
        assertEq(linklist.getLinkingCharacterIds(1)[0], secondCharacter);
        assertEq(linklist.getLinkingCharacterListLength(1), 1);
    }

    function testLinkCharacterFail() public {
        // case 1: NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, FollowLinkType, "")
        );

        // case 2: link a non-existing character
        vm.expectRevert(abi.encodeWithSelector(ErrCharacterNotExists.selector, 3));
        vm.prank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(firstCharacter, 3, FollowLinkType, ""));

        // case 3: link a burned character
        vm.prank(bob);
        web3Entry.burn(secondCharacter);
        vm.expectRevert(abi.encodeWithSelector(ErrCharacterNotExists.selector, secondCharacter));
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, FollowLinkType, "")
        );
    }

    function testUnlinkCharacter() public {
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, FollowLinkType, "")
        );

        // unlink
        expectEmit(CheckAll);
        emit Events.UnlinkCharacter(alice, firstCharacter, secondCharacter, FollowLinkType);
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(firstCharacter, secondCharacter, FollowLinkType)
        );

        // unlink twice
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(firstCharacter, secondCharacter, FollowLinkType)
        );

        // unlink a non-existing character
        web3Entry.unlinkCharacter(DataTypes.unlinkCharacterData(firstCharacter, 9, FollowLinkType));
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);
        // check state
        assertEq(linklist.getOwnerCharacterId(1), firstCharacter);
        assertEq(linklist.getLinkingCharacterIds(1).length, 0);
        assertEq(linklist.getLinkingCharacterListLength(1), 0);
    }

    function testUnlinkCharacterFail() public {
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, FollowLinkType, "")
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(firstCharacter, secondCharacter, FollowLinkType)
        );
    }

    function testLinklistTotalSupply() public {
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, FollowLinkType, "")
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.characterOwnerOf(1), 1);
        assertEq(linklist.totalSupply(), 1);

        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, LikeLinkType, "")
        );

        // check linklist
        assertEq(linklist.ownerOf(2), alice);
        assertEq(linklist.characterOwnerOf(2), 1);
        assertEq(linklist.totalSupply(), 2);

        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, bytes32("LinkTypeAB"), "")
        );

        // check linklist
        assertEq(linklist.ownerOf(3), alice);
        assertEq(linklist.characterOwnerOf(3), 1);
        assertEq(linklist.totalSupply(), 3);
        vm.stopPrank();
    }

    function testCreateThenLinkCharacter() public {
        address to = address(0x56789);

        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.LinkCharacter(alice, FIRST_CHARACTER_ID, 3, FollowLinkType, 1);
        web3Entry.createThenLinkCharacter(
            DataTypes.createThenLinkCharacterData(FIRST_CHARACTER_ID, to, FollowLinkType)
        );

        // check state
        assertEq(linklist.getOwnerCharacterId(1), FIRST_CHARACTER_ID);
        assertEq(linklist.getLinkingCharacterIds(1).length, 1);
        assertEq(linklist.getLinkingCharacterIds(1)[0], THIRD_CHARACTER_ID);
        assertEq(linklist.getLinkingCharacterListLength(1), 1);
        // check new character
        DataTypes.Character memory character = web3Entry.getCharacter(THIRD_CHARACTER_ID);
        assertEq(character.handle, Strings.toHexString(to));
        assertEq(character.characterId, THIRD_CHARACTER_ID);
        assertEq(web3Entry.getHandle(3), Strings.toHexString(to));
        assertEq(web3Entry.getPrimaryCharacterId(to), THIRD_CHARACTER_ID);
    }

    function testCreateThenLinkCharacterFail() public {
        vm.startPrank(alice);
        web3Entry.createThenLinkCharacter(
            DataTypes.createThenLinkCharacterData(
                FIRST_CHARACTER_ID,
                address(0x56789),
                FollowLinkType
            )
        );

        // link twice fail
        vm.expectRevert(abi.encodeWithSelector(ErrHandleExists.selector));
        web3Entry.createThenLinkCharacter(
            DataTypes.createThenLinkCharacterData(
                FIRST_CHARACTER_ID,
                address(0x56789),
                FollowLinkType
            )
        );

        vm.stopPrank();
    }
}
