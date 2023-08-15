// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {Events} from "../../contracts/libraries/Events.sol";
import {
    ErrNoteNotExists,
    ErrNoteIsDeleted,
    ErrNotEnoughPermission
} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract LinkNoteTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
    }

    // solhint-disable-next-line function-max-lines
    function testLinkNote() public {
        uint256 fromCharacterId = 1;
        uint256 toCharacterId = 1;
        uint256 toNoteId = 1;

        expectEmit(CheckAll);
        emit Events.LinkNote(fromCharacterId, toCharacterId, toNoteId, FollowLinkType, 1);
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType, "")
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        vm.prank(alice);
        // link twice
        web3Entry.linkNote(
            DataTypes.linkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType, "")
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType, "")
        );

        // check state
        DataTypes.NoteStruct[] memory linkingNotes = linklist.getLinkingNotes(1);
        assertEq(linkingNotes.length, 1);
        DataTypes.NoteStruct memory linkingNote = linkingNotes[0];
        assertEq(linkingNote.characterId, 1);
        assertEq(linkingNote.noteId, 1);
        bytes32 linkKey = keccak256(abi.encodePacked("Note", toCharacterId, toNoteId));
        linkingNote = linklist.getLinkingNote(linkKey);
        assertEq(linkingNote.characterId, toCharacterId);
        assertEq(linkingNote.noteId, toNoteId);
        assertEq(linklist.getLinkingNoteListLength(1), 1);
    }

    function testLinkNoteFail() public {
        uint256 fromCharacterId = 1;
        uint256 toCharacterId = 1;
        uint256 toNoteId = 1;

        // case 1: NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.linkNote(
            DataTypes.linkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType, "")
        );

        // case 2: link a nonexistent note
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(fromCharacterId, toCharacterId, 2, FollowLinkType, "")
        );

        // case 3: link a deleted note
        vm.prank(alice);
        web3Entry.deleteNote(toCharacterId, toNoteId);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType, "")
        );
    }

    // solhint-disable-next-line function-max-lines
    function testUnLinkNote() public {
        uint256 fromCharacterId = 1;
        uint256 toCharacterId = 1;
        uint256 toNoteId = 1;

        vm.startPrank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType, "")
        );

        // unlink
        expectEmit(CheckAll);
        emit Events.UnlinkNote(fromCharacterId, toCharacterId, toNoteId, FollowLinkType, 1);
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType)
        );

        // unlink twice
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType)
        );

        // unlink a non-existing character
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType)
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        DataTypes.NoteStruct[] memory linkingNotes = linklist.getLinkingNotes(1);
        assertEq(linkingNotes.length, 0);
        bytes32 linkKey = keccak256(abi.encodePacked("Note", toCharacterId, toNoteId));
        DataTypes.NoteStruct memory linkingNote = linklist.getLinkingNote(linkKey);
        assertEq(linkingNote.characterId, toCharacterId);
        assertEq(linkingNote.noteId, toNoteId);
        assertEq(linklist.getLinkingNoteListLength(1), 0);
    }

    function testUnLinkNoteFail() public {
        uint256 fromCharacterId = 1;
        uint256 toCharacterId = 1;
        uint256 toNoteId = 1;

        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType, "")
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(fromCharacterId, toCharacterId, toNoteId, FollowLinkType)
        );
    }
}
