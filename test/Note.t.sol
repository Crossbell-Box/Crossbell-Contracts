// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {DataTypes} from "../contracts/libraries/DataTypes.sol";
import {Events} from "../contracts/libraries/Events.sol";
import {OP} from "../contracts/libraries/OP.sol";
import {Constants} from "../contracts/libraries/Constants.sol";
import {
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote,
    ErrNoteNotExists,
    ErrNoteLocked,
    ErrNoteIsDeleted
} from "../contracts/libraries/Error.sol";
import {IWeb3Entry} from "../contracts/interfaces/IWeb3Entry.sol";
import {
    TransparentUpgradeableProxy
} from "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import {CommonTest} from "./helpers/CommonTest.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NoteTest is CommonTest {
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testPostNoteFail() public {
        //  bob should fail to post note at a character owned by alice
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
    }

    function testPostNote() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.PostNote(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            bytes32Zero,
            bytes32Zero,
            new bytes(0)
        );
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            bytes32Zero,
            bytes32Zero,
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testPostNoteWithMulticall() public {
        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSelector(
            IWeb3Entry.postNote.selector,
            makePostNoteData(FIRST_CHARACTER_ID)
        );
        data[1] = abi.encodeWithSelector(
            IWeb3Entry.postNote.selector,
            makePostNoteData(FIRST_CHARACTER_ID)
        );

        // multicall
        vm.prank(alice);
        web3Entry.multicall(data);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            bytes32Zero,
            bytes32Zero,
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
        note = web3Entry.getNote(FIRST_CHARACTER_ID, SECOND_NOTE_ID);
        _matchNote(
            note,
            bytes32Zero,
            bytes32Zero,
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testUpdateNote() public {
        // post note
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // update note
        expectEmit(CheckTopic1 | CheckData);
        emit Events.SetNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            bytes32Zero,
            bytes32Zero,
            NEW_NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testUpdateNoteFail() public {
        // NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermissionForThisNote.selector));
        vm.prank(bob);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);

        vm.startPrank(alice);
        // NoteNotExists
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);

        // NoteLocked
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteLocked.selector));
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);

        // NoteIsDeleted
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.deleteNote(FIRST_CHARACTER_ID, SECOND_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, NEW_NOTE_URI);
        vm.stopPrank();
    }

    function testLockNote() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        expectEmit(CheckTopic1 | CheckData);
        emit Events.LockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            bytes32Zero,
            bytes32Zero,
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            true
        );
    }

    function testLockNoteFail() public {
        // case 1: NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);

        vm.startPrank(alice);
        // case 2: NoteNotExists
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);

        // case 3: NoteIsDeleted
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.deleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);

        vm.stopPrank();
    }

    function testDeleteNote() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        expectEmit(CheckTopic1 | CheckData);
        emit Events.DeleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        web3Entry.deleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            bytes32Zero,
            bytes32Zero,
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            true,
            false
        );
    }

    function testDeleteLockedNote() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        web3Entry.deleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            bytes32Zero,
            bytes32Zero,
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            true,
            true
        );
    }

    function testDeleteNoteFail() public {
        // case 1: NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.deleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);

        // case 2: NoteNotExists
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        vm.prank(alice);
        web3Entry.deleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);

        vm.startPrank(alice);
        uint256 noteId = web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.deleteNote(FIRST_CHARACTER_ID, noteId);
        // case 3: NoteIsDeleted
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.deleteNote(FIRST_CHARACTER_ID, noteId);
        vm.stopPrank();
    }

    function testPostNote4Character() public {
        vm.prank(alice);
        web3Entry.postNote4Character(makePostNoteData(FIRST_CHARACTER_ID), SECOND_CHARACTER_ID);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            Constants.LINK_ITEM_TYPE_CHARACTER,
            bytes32(SECOND_CHARACTER_ID),
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testPostNote4CharacterFail() public {
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.postNote4Character(makePostNoteData(FIRST_CHARACTER_ID), SECOND_CHARACTER_ID);
    }

    function testPostNote4Address() public {
        address toAddress = address(0x123456789);

        vm.prank(alice);
        web3Entry.postNote4Address(makePostNoteData(FIRST_CHARACTER_ID), toAddress);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            Constants.LINK_ITEM_TYPE_ADDRESS,
            bytes32(uint256(uint160(toAddress))),
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testPostNote4AddressFail() public {
        address toAddress = address(0x123456789);

        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.postNote4Address(makePostNoteData(FIRST_CHARACTER_ID), toAddress);
    }

    function testPostNote4Linklist() public {
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                LikeLinkType,
                new bytes(0)
            )
        );

        web3Entry.postNote4Linklist(makePostNoteData(FIRST_CHARACTER_ID), FIRST_LINKLIST_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            Constants.LINK_ITEM_TYPE_LINKLIST,
            bytes32(FIRST_LINKLIST_ID),
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testPostNote4LinklistFail() public {
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.postNote4Linklist(makePostNoteData(FIRST_CHARACTER_ID), FIRST_LINKLIST_ID);
    }

    function testPostNote4Note() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        vm.prank(bob);
        web3Entry.postNote4Note(
            makePostNoteData(SECOND_CHARACTER_ID),
            DataTypes.NoteStruct(FIRST_CHARACTER_ID, FIRST_NOTE_ID)
        );

        // check note
        DataTypes.Note memory note = web3Entry.getNote(SECOND_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            Constants.LINK_ITEM_TYPE_NOTE,
            keccak256(abi.encodePacked("Note", FIRST_CHARACTER_ID, FIRST_NOTE_ID)),
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testPostNote4NoteFail() public {
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.postNote4Note(
            makePostNoteData(FIRST_CHARACTER_ID),
            DataTypes.NoteStruct(FIRST_CHARACTER_ID, FIRST_NOTE_ID)
        );
    }

    function testPostNote4ERC721() public {
        nft.mint(bob);

        vm.prank(alice);
        web3Entry.postNote4ERC721(
            makePostNoteData(FIRST_CHARACTER_ID),
            DataTypes.ERC721Struct(address(nft), 1)
        );

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            Constants.LINK_ITEM_TYPE_ERC721,
            keccak256(abi.encodePacked("ERC721", address(nft), uint256(1))),
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testPostNote4ERC721Fail() public {
        // NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.postNote4ERC721(
            makePostNoteData(FIRST_CHARACTER_ID),
            DataTypes.ERC721Struct(address(nft), 1)
        );
    }

    function testPostNote4AnyUri() public {
        string memory uri = "ipfs://abcdefg";

        vm.prank(alice);
        web3Entry.postNote4AnyUri(makePostNoteData(FIRST_CHARACTER_ID), uri);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        _matchNote(
            note,
            Constants.LINK_ITEM_TYPE_ANYURI,
            keccak256(abi.encodePacked("AnyUri", uri)),
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testPostNote4AnyUriFail() public {
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.postNote4AnyUri(makePostNoteData(FIRST_CHARACTER_ID), "ipfs://anyURI");
    }

    function testMintNote() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // bob mints a note
        vm.prank(bob);
        web3Entry.mintNote(
            DataTypes.MintNoteData(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, new bytes(0))
        );

        vm.prank(alice);
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        // bob mints a locked note
        vm.prank(bob);
        web3Entry.mintNote(
            DataTypes.MintNoteData(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, new bytes(0))
        );

        // check state
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        address nftAddress = note.mintNFT;
        assertEq(IERC721(nftAddress).ownerOf(1), bob);
        assertEq(IERC721(nftAddress).ownerOf(2), bob);
        assertEq(IERC721Enumerable(nftAddress).totalSupply(), 2);
        // check note uri
        assertEq(note.contentUri, IERC721Metadata(nftAddress).tokenURI(1));
        assertEq(note.contentUri, IERC721Metadata(nftAddress).tokenURI(2));
    }

    function testMintNoteFail() public {
        // case 1: note not exists
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.mintNote(
            DataTypes.MintNoteData(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, new bytes(0))
        );

        // case 2: note is deleted
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.deleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.stopPrank();
        // mint a deleted note
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.mintNote(
            DataTypes.MintNoteData(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, new bytes(0))
        );

        // check state
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        assertEq(note.mintNFT, address(0));
    }

    function testMintNoteTotalSupply() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        vm.startPrank(bob);
        for (uint256 i = 0; i < 10; i++) {
            web3Entry.mintNote(
                DataTypes.MintNoteData(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, new bytes(0))
            );
        }
        vm.stopPrank();

        // check mint note
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        address nftAddress = note.mintNFT;
        assertEq(IERC721Enumerable(nftAddress).totalSupply(), 10);
    }

    // solhint-disable-next-line function-max-lines
    function testSetMintModule4Note() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // owner can setMintModule4Note
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetMintModule4Note(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            address(approvalMintModule),
            new bytes(0),
            block.timestamp
        );
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // operator can setMintModule4Note
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        vm.prank(bob);
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // owner behind periphery can
        vm.prank(address(periphery), alice);
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // operator behind periphery can
        vm.prank(address(periphery), bob);
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );
    }

    // solhint-disable-next-line function-max-lines
    function testSetMintModule4NoteFail() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // not owner nor operator can't
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // can't setMintModule4Note for notes don't exist
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                FIRST_CHARACTER_ID,
                SECOND_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // can't setMintModule4Note for notes that's locked
        vm.startPrank(alice);
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteLocked.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // can't setMintModule4Note for notes that's deleted
        web3Entry.deleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );
    }
}
