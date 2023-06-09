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
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkNote(
            FIRST_CHARACTER_ID,
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            FollowLinkType,
            FIRST_LINKLIST_ID
        );
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        vm.prank(alice);
        // link twice
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // check state
        DataTypes.NoteStruct[] memory linkingNotes = linklist.getLinkingNotes(1);
        assertEq(linkingNotes.length, 1);
        DataTypes.NoteStruct memory linkingNote = linkingNotes[0];
        assertEq(linkingNote.characterId, 1);
        assertEq(linkingNote.noteId, 1);
        bytes32 linkKey = keccak256(abi.encodePacked("Note", FIRST_CHARACTER_ID, FIRST_NOTE_ID));
        linkingNote = linklist.getLinkingNote(linkKey);
        assertEq(linkingNote.characterId, 1);
        assertEq(linkingNote.noteId, 1);
        assertEq(linklist.getLinkingNoteListLength(1), 1);
    }

    function testLinkNoteFail() public {
        // case 1: NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // case 2: link a nonexistent note
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                SECOND_NOTE_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // case 3: link a deleted note
        vm.prank(alice);
        web3Entry.deleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType,
                new bytes(0)
            )
        );
    }

    // solhint-disable-next-line function-max-lines
    function testUnLinkNote() public {
        vm.startPrank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.UnlinkNote(
            FIRST_CHARACTER_ID,
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            FollowLinkType,
            FIRST_LINKLIST_ID
        );
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType
            )
        );

        // unlink twice
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType
            )
        );

        // unlink a non-existing character
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType
            )
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        DataTypes.NoteStruct[] memory linkingNotes = linklist.getLinkingNotes(1);
        assertEq(linkingNotes.length, 0);
        bytes32 linkKey = keccak256(abi.encodePacked("Note", FIRST_CHARACTER_ID, FIRST_NOTE_ID));
        DataTypes.NoteStruct memory linkingNote = linklist.getLinkingNote(linkKey);
        assertEq(linkingNote.characterId, 1);
        assertEq(linkingNote.noteId, 1);
        assertEq(linklist.getLinkingNoteListLength(1), 0);
    }

    function testUnLinkNoteFail() public {
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType
            )
        );
    }
}
