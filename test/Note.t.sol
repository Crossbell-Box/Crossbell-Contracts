// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {Test} from "forge-std/Test.sol";
import {IWeb3Entry} from "../contracts/interfaces/IWeb3Entry.sol";
import {DataTypes} from "../contracts/libraries/DataTypes.sol";
import {Events} from "../contracts/libraries/Events.sol";
import {OP} from "../contracts/libraries/OP.sol";
import {Constants} from "../contracts/libraries/Constants.sol";
import {
    ErrNotAddressOwner,
    ErrNotCharacterOwner,
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote,
    ErrCharacterNotExists,
    ErrNoteIsDeleted,
    ErrNoteNotExists,
    ErrNoteLocked
} from "../contracts/libraries/Error.sol";
import "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import {Const} from "./helpers/Const.sol";
import {Utils} from "./helpers/Utils.sol";
import {SetUp} from "./helpers/SetUp.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NoteTest is Test, SetUp, Utils {
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testPostNoteFail() public {
        //  bob should fail to post note at a character owned by alice
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
    }

    function testPostNote() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.PostNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.bytes32Zero,
            Const.bytes32Zero,
            new bytes(0)
        );
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Const.bytes32Zero,
            Const.bytes32Zero,
            Const.MOCK_NOTE_URI,
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
            makePostNoteData(Const.FIRST_CHARACTER_ID)
        );
        data[1] = abi.encodeWithSelector(
            IWeb3Entry.postNote.selector,
            makePostNoteData(Const.FIRST_CHARACTER_ID)
        );

        // multicall
        vm.prank(alice);
        web3Entry.multicall(data);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Const.bytes32Zero,
            Const.bytes32Zero,
            Const.MOCK_NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
        note = web3Entry.getNote(Const.FIRST_CHARACTER_ID, Const.SECOND_NOTE_ID);
        matchNote(
            note,
            Const.bytes32Zero,
            Const.bytes32Zero,
            Const.MOCK_NOTE_URI,
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
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // update note
        expectEmit(CheckTopic1 | CheckData);
        emit Events.SetNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Const.bytes32Zero,
            Const.bytes32Zero,
            Const.MOCK_NEW_NOTE_URI,
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
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );

        vm.startPrank(alice);
        // NoteNotExists
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );

        // NoteLocked
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteLocked.selector));
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );

        // NoteIsDeleted
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.SECOND_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
        vm.stopPrank();
    }

    function testLockNote() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        expectEmit(CheckTopic1 | CheckData);
        emit Events.LockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Const.bytes32Zero,
            Const.bytes32Zero,
            Const.MOCK_NOTE_URI,
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
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        vm.startPrank(alice);
        // case 2: NoteNotExists
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        // case 3: NoteIsDeleted
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        vm.stopPrank();
    }

    function testDeleteNote() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        expectEmit(CheckTopic1 | CheckData);
        emit Events.DeleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Const.bytes32Zero,
            Const.bytes32Zero,
            Const.MOCK_NOTE_URI,
            address(0),
            address(0),
            address(0),
            true,
            false
        );
    }

    function testDeleteLockedNote() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Const.bytes32Zero,
            Const.bytes32Zero,
            Const.MOCK_NOTE_URI,
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
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        // case 2: NoteNotExists
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        vm.prank(alice);
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        vm.startPrank(alice);
        uint256 noteId = web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, noteId);
        // case 3: NoteIsDeleted
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, noteId);
        vm.stopPrank();
    }

    function testPostNote4Character() public {
        vm.prank(alice);
        web3Entry.postNote4Character(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            Const.SECOND_CHARACTER_ID
        );

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Constants.LINK_ITEM_TYPE_CHARACTER,
            bytes32(Const.SECOND_CHARACTER_ID),
            Const.MOCK_NOTE_URI,
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
        web3Entry.postNote4Character(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            Const.SECOND_CHARACTER_ID
        );
    }

    function testPostNote4Address() public {
        address toAddress = address(0x123456789);

        vm.prank(alice);
        web3Entry.postNote4Address(makePostNoteData(Const.FIRST_CHARACTER_ID), toAddress);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Constants.LINK_ITEM_TYPE_ADDRESS,
            bytes32(uint256(uint160(toAddress))),
            Const.MOCK_NOTE_URI,
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
        web3Entry.postNote4Address(makePostNoteData(Const.FIRST_CHARACTER_ID), toAddress);
    }

    function testPostNote4Linklist() public {
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        web3Entry.postNote4Linklist(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            Const.FIRST_LINKLIST_ID
        );
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Constants.LINK_ITEM_TYPE_LINKLIST,
            bytes32(Const.FIRST_LINKLIST_ID),
            Const.MOCK_NOTE_URI,
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
        web3Entry.postNote4Linklist(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            Const.FIRST_LINKLIST_ID
        );
    }

    function testPostNote4Note() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        vm.prank(bob);
        web3Entry.postNote4Note(
            makePostNoteData(Const.SECOND_CHARACTER_ID),
            DataTypes.NoteStruct(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID)
        );

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.SECOND_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Constants.LINK_ITEM_TYPE_NOTE,
            keccak256(abi.encodePacked("Note", Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID)),
            Const.MOCK_NOTE_URI,
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
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            DataTypes.NoteStruct(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID)
        );
    }

    function testPostNote4ERC721() public {
        nft.mint(bob);

        vm.prank(alice);
        web3Entry.postNote4ERC721(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            DataTypes.ERC721Struct(address(nft), 1)
        );

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Constants.LINK_ITEM_TYPE_ERC721,
            keccak256(abi.encodePacked("ERC721", address(nft), uint256(1))),
            Const.MOCK_NOTE_URI,
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
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            DataTypes.ERC721Struct(address(nft), 1)
        );
    }

    function testPostNote4AnyUri() public {
        string memory uri = "ipfs://abcdefg";

        vm.prank(alice);
        web3Entry.postNote4AnyUri(makePostNoteData(Const.FIRST_CHARACTER_ID), uri);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        matchNote(
            note,
            Constants.LINK_ITEM_TYPE_ANYURI,
            keccak256(abi.encodePacked("AnyUri", uri)),
            Const.MOCK_NOTE_URI,
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
        web3Entry.postNote4AnyUri(makePostNoteData(Const.FIRST_CHARACTER_ID), "ipfs://anyURI");
    }

    function testMintNote() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // bob mints a note
        vm.prank(bob);
        web3Entry.mintNote(
            DataTypes.MintNoteData(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, bob, new bytes(0))
        );

        vm.prank(alice);
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        // bob mints a locked note
        vm.prank(bob);
        web3Entry.mintNote(
            DataTypes.MintNoteData(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, bob, new bytes(0))
        );

        // check state
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
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
            DataTypes.MintNoteData(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, bob, new bytes(0))
        );

        // case 2: note is deleted
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.stopPrank();
        // mint a deleted note
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.mintNote(
            DataTypes.MintNoteData(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, bob, new bytes(0))
        );

        // check state
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        assertEq(note.mintNFT, address(0));
    }

    function testMintNoteTotalSupply() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        vm.startPrank(bob);
        for (uint256 i = 0; i < 10; i++) {
            web3Entry.mintNote(
                DataTypes.MintNoteData(
                    Const.FIRST_CHARACTER_ID,
                    Const.FIRST_NOTE_ID,
                    bob,
                    new bytes(0)
                )
            );
        }
        vm.stopPrank();

        // check mint note
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        address nftAddress = note.mintNFT;
        assertEq(IERC721Enumerable(nftAddress).totalSupply(), 10);
    }

    // solhint-disable-next-line function-max-lines
    function testSetMintModule4Note() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // owner can setMintModule4Note
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetMintModule4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            address(approvalMintModule),
            new bytes(0),
            block.timestamp
        );
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // operator can setMintModule4Note
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        vm.prank(bob);
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // owner behind periphery can
        vm.prank(address(periphery), alice);
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // operator behind periphery can
        vm.prank(address(periphery), bob);
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );
    }

    // solhint-disable-next-line function-max-lines
    function testSetMintModule4NoteFail() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // not owner nor operator can't
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // can't setMintModule4Note for notes don't exist
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // can't setMintModule4Note for notes that's locked
        vm.startPrank(alice);
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteLocked.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );

        // can't setMintModule4Note for notes that's deleted
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                address(approvalMintModule),
                new bytes(0)
            )
        );
    }
}
