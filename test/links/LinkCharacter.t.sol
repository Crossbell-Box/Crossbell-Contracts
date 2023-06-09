// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Events} from "../../contracts/libraries/Events.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote,
    ErrCharacterNotExists,
    ErrHandleExists
} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract LinkCharacterTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testLinkCharacter() public {
        vm.startPrank(alice);
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkCharacter(
            alice,
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            FollowLinkType,
            1
        );
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // link twice
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );
        vm.stopPrank();

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // check state
        assertEq(linklist.getOwnerCharacterId(1), FIRST_CHARACTER_ID);
        assertEq(linklist.getLinkingCharacterIds(1).length, 1);
        assertEq(linklist.getLinkingCharacterIds(1)[0], 2);
        assertEq(linklist.getLinkingCharacterListLength(1), 1);
    }

    function testLinkCharacterFail() public {
        // case 1: NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // case 2: CharacterNotExists
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrCharacterNotExists.selector, THIRD_CHARACTER_ID));
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                THIRD_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // case 3: link a burned character
        vm.prank(bob);
        web3Entry.burn(SECOND_CHARACTER_ID);
        vm.expectRevert(
            abi.encodeWithSelector(ErrCharacterNotExists.selector, SECOND_CHARACTER_ID)
        );
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );
    }

    function testUnlinkCharacter() public {
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.UnlinkCharacter(alice, FIRST_CHARACTER_ID, SECOND_CHARACTER_ID, FollowLinkType);
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID, FollowLinkType)
        );

        // unlink twice
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID, FollowLinkType)
        );

        // unlink a non-existing character
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(FIRST_CHARACTER_ID, 99999, FollowLinkType)
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        assertEq(linklist.getOwnerCharacterId(1), FIRST_CHARACTER_ID);
        assertEq(linklist.getLinkingCharacterIds(1).length, 0);
        assertEq(linklist.getLinkingCharacterListLength(1), 0);
    }

    function testUnlinkCharacterFail() public {
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID, FollowLinkType)
        );
    }

    function testLinklistTotalSupply() public {
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.characterOwnerOf(1), 1);
        assertEq(linklist.totalSupply(), 1);

        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                LikeLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(2), alice);
        assertEq(linklist.characterOwnerOf(2), 1);
        assertEq(linklist.totalSupply(), 2);

        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                bytes32("LinkTypeAB"),
                new bytes(0)
            )
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
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
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
