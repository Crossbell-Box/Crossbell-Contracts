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
import "../../contracts/libraries/OP.sol";

contract LinkProfileTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));

        // bob post note
        vm.prank(bob);
        web3Entry.postNote(makePostNoteData(Const.SECOND_CHARACTER_ID));
    }

    function testLinkNote() public {
        vm.startPrank(alice);
        expectEmit(CheckAll);
        emit Events.LinkNote(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.LikeLinkType,
            Const.FIRST_LINKLIST_ID
        );
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // link twice
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
        vm.stopPrank();

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(alice, address(periphery));
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // operators can link
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        vm.prank(bob);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
    }

    function testLinkNoteWithUri() public {
        vm.startPrank(alice);
        // link with uri
        web3Entry.linkNoteWithUri(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            ),
            Const.MOCK_CONTENT_URI
        );

        // link with uri twice
        web3Entry.linkNoteWithUri(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            ),
            Const.MOCK_CONTENT_URI
        );
        vm.stopPrank();

        // periphery can link with uri
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(alice, address(periphery));
        web3Entry.linkNoteWithUri(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            ),
            Const.MOCK_CONTENT_URI
        );

        // operators can link with uri
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        vm.prank(bob);
        web3Entry.linkNoteWithUri(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            ),
            Const.MOCK_CONTENT_URI
        );
    }

    function testLinkNoteFail() public {
        // case 1: Not character owner
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // case 2: NotEnoughOperatorPermission
        vm.prank(alice);
        // alice grant bob as operator with post note permission, so bob is a operator without linkNote permission
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_PERMISSION_BITMAP
        );
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // case 3: NoteNotExists
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.SECOND_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // case 4: Link a deleted note
        vm.prank(bob);
        web3Entry.deleteNote(Const.SECOND_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.prank((alice));
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
    }

    function testLinkNoteWithUriFail() public {
        // case 1: Not character owner
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkNoteWithUri(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            ),
            Const.MOCK_CONTENT_URI
        );
        // case 2: Not enough permission
        vm.prank(alice);
        // alice grant bob as operator with post note permission, so bob is a operator without linkNote permission
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_PERMISSION_BITMAP
        );
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkNoteWithUri(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            ),
            Const.MOCK_CONTENT_URI
        );
        // case 3: NoteNotExists
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.linkNoteWithUri(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.SECOND_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            ),
            Const.MOCK_CONTENT_URI
        );

        // case 4: Link a deleted note
        vm.prank(bob);
        web3Entry.deleteNote(Const.SECOND_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.linkNoteWithUri(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            ),
            Const.MOCK_CONTENT_URI
        );
    }

    function testUnlinkNote() public {
        // case 1: unlink an none-exist link
        vm.startPrank(alice);
        expectEmit(CheckAll);
        emit Events.UnlinkNote(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.LikeLinkType,
            0
        );
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType
            )
        );

        // case 2: unlink a link
        // create a link first
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
        // unlink
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType
            )
        );

        // case 3:  unlink a non-existing note
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.SECOND_NOTE_ID,
                Const.LikeLinkType
            )
        );
        vm.stopPrank();
    }

    function testUnlinkNoteFail() public {
        // case 1: Not character owner
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType
            )
        );

        // case 2: NotEnoughPermission
        // alice grant bob post note permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_PERMISSION_BITMAP
        );
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.LikeLinkType
            )
        );
    }
}
