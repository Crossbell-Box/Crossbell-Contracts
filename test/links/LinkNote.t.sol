// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/Web3Entry.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../../contracts/libraries/Error.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract LinkNoteTest is Test, SetUp, Utils {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
    }

    // solhint-disable-next-line function-max-lines
    function testLinkNote() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.FollowLinkType,
            Const.FIRST_LINKLIST_ID
        );
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        vm.prank(alice);
        // link twice
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // check state
        DataTypes.NoteStruct[] memory linkingNotes = linklist.getLinkingNotes(1);
        assertEq(linkingNotes.length, 1);
        DataTypes.NoteStruct memory linkingNote = linkingNotes[0];
        assertEq(linkingNote.characterId, 1);
        assertEq(linkingNote.noteId, 1);
        bytes32 linkKey = keccak256(
            abi.encodePacked("Note", Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID)
        );
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
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // case 2: link a nonexistent note
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // case 3: link a deleted note
        vm.prank(alice);
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
    }

    // solhint-disable-next-line function-max-lines
    function testUnLinkNote() public {
        vm.startPrank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.UnlinkNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.FollowLinkType,
            Const.FIRST_LINKLIST_ID
        );
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType
            )
        );

        // unlink twice
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType
            )
        );

        // unlink a non-existing character
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType
            )
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        DataTypes.NoteStruct[] memory linkingNotes = linklist.getLinkingNotes(1);
        assertEq(linkingNotes.length, 0);
        bytes32 linkKey = keccak256(
            abi.encodePacked("Note", Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID)
        );
        DataTypes.NoteStruct memory linkingNote = linklist.getLinkingNote(linkKey);
        assertEq(linkingNote.characterId, 1);
        assertEq(linkingNote.noteId, 1);
        assertEq(linklist.getLinkingNoteListLength(1), 0);
    }

    function testUnLinkNoteFail() public {
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType
            )
        );
    }
}
