// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

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
import {CommonTest} from "./helpers/CommonTest.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NoteTest is CommonTest {
    uint256 public firstCharacter;
    uint256 public secondCharacter;

    function setUp() public {
        _setUp();

        // create character
        firstCharacter = _createCharacter(CHARACTER_HANDLE, alice);
        secondCharacter = _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testPostNoteFail() public {
        //  bob should fail to post note at a character owned by alice
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.postNote(makePostNoteData(firstCharacter));
    }

    function testPostNote() public {
        expectEmit(CheckAll);
        emit Events.PostNote(firstCharacter, FIRST_NOTE_ID, 0, 0, "");
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
        _matchNote(note, 0, 0, NOTE_URI, address(0), address(0), address(0), false, false);
    }

    function testPostNoteWithMulticall() public {
        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSelector(
            IWeb3Entry.postNote.selector,
            makePostNoteData(firstCharacter)
        );
        data[1] = abi.encodeWithSelector(
            IWeb3Entry.postNote.selector,
            makePostNoteData(firstCharacter)
        );

        // multicall
        vm.prank(alice);
        web3Entry.multicall(data);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, 1);
        _matchNote(note, 0, 0, NOTE_URI, address(0), address(0), address(0), false, false);
        note = web3Entry.getNote(firstCharacter, 2);
        _matchNote(note, 0, 0, NOTE_URI, address(0), address(0), address(0), false, false);
    }

    function testSetNoteUri() public {
        // post note
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // update note
        expectEmit(CheckAll);
        emit Events.SetNoteUri(firstCharacter, 1, NEW_NOTE_URI);
        web3Entry.setNoteUri(firstCharacter, 1, NEW_NOTE_URI);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, 1);
        _matchNote(note, 0, 0, NEW_NOTE_URI, address(0), address(0), address(0), false, false);
    }

    function testSetNoteUriFail() public {
        // case 1: NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermissionForThisNote.selector));
        vm.prank(bob);
        web3Entry.setNoteUri(firstCharacter, FIRST_NOTE_ID, NEW_NOTE_URI);

        vm.startPrank(alice);
        // case 2: NoteNotExists
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.setNoteUri(firstCharacter, FIRST_NOTE_ID, NEW_NOTE_URI);

        // case 3: NoteLocked
        web3Entry.postNote(makePostNoteData(firstCharacter));
        web3Entry.lockNote(firstCharacter, FIRST_NOTE_ID);

        vm.expectRevert(abi.encodeWithSelector(ErrNoteLocked.selector));
        web3Entry.setNoteUri(firstCharacter, FIRST_NOTE_ID, NEW_NOTE_URI);

        // case 4: NoteIsDeleted
        web3Entry.postNote(makePostNoteData(firstCharacter));
        web3Entry.deleteNote(firstCharacter, SECOND_NOTE_ID);

        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.setNoteUri(firstCharacter, SECOND_NOTE_ID, NEW_NOTE_URI);
        vm.stopPrank();
    }

    function testSetNoteUriByOperator() public {
        // post note
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // grant operator
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.SET_NOTE_URI);

        // set note uri by operator
        expectEmit(CheckAll);
        emit Events.SetNoteUri(firstCharacter, FIRST_NOTE_ID, NEW_NOTE_URI);
        vm.prank(bob);
        web3Entry.setNoteUri(firstCharacter, FIRST_NOTE_ID, NEW_NOTE_URI);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
        _matchNote(note, 0, 0, NEW_NOTE_URI, address(0), address(0), address(0), false, false);
    }

    function testSetNoteUriByOperatorByPeriphery() public {
        // post note
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // grant operator
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.SET_NOTE_URI);

        // set note uri by operator through periphery contract
        expectEmit(CheckAll);
        emit Events.SetNoteUri(firstCharacter, FIRST_NOTE_ID, NEW_NOTE_URI);
        vm.prank(address(periphery), bob);
        web3Entry.setNoteUri(firstCharacter, FIRST_NOTE_ID, NEW_NOTE_URI);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
        _matchNote(note, 0, 0, NEW_NOTE_URI, address(0), address(0), address(0), false, false);
    }

    function testLockNote() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        expectEmit(CheckAll);
        emit Events.LockNote(firstCharacter, FIRST_NOTE_ID);
        web3Entry.lockNote(firstCharacter, FIRST_NOTE_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
        _matchNote(note, 0, 0, NOTE_URI, address(0), address(0), address(0), false, true);
    }

    function testLockNoteFail() public {
        // case 1: NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.lockNote(firstCharacter, FIRST_NOTE_ID);

        vm.startPrank(alice);
        // case 2: NoteNotExists
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.lockNote(firstCharacter, FIRST_NOTE_ID);

        // case 3: NoteIsDeleted
        web3Entry.postNote(makePostNoteData(firstCharacter));
        web3Entry.deleteNote(firstCharacter, FIRST_NOTE_ID);

        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.lockNote(firstCharacter, FIRST_NOTE_ID);

        vm.stopPrank();
    }

    function testDeleteNote() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        expectEmit(CheckAll);
        emit Events.DeleteNote(firstCharacter, FIRST_NOTE_ID);
        web3Entry.deleteNote(firstCharacter, FIRST_NOTE_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
        _matchNote(note, 0, 0, NOTE_URI, address(0), address(0), address(0), true, false);
    }

    function testDeleteLockedNote() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));
        web3Entry.lockNote(firstCharacter, FIRST_NOTE_ID);
        web3Entry.deleteNote(firstCharacter, FIRST_NOTE_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
        _matchNote(note, 0, 0, NOTE_URI, address(0), address(0), address(0), true, true);
    }

    function testDeleteNoteFail() public {
        // case 1: NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.deleteNote(firstCharacter, FIRST_NOTE_ID);

        // case 2: NoteNotExists
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        vm.prank(alice);
        web3Entry.deleteNote(firstCharacter, FIRST_NOTE_ID);

        vm.startPrank(alice);
        uint256 noteId = web3Entry.postNote(makePostNoteData(firstCharacter));
        web3Entry.deleteNote(firstCharacter, noteId);
        // case 3: NoteIsDeleted
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.deleteNote(firstCharacter, noteId);
        vm.stopPrank();
    }

    function testPostNote4Character() public {
        vm.prank(alice);
        web3Entry.postNote4Character(makePostNoteData(firstCharacter), secondCharacter);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
        _matchNote(
            note,
            Constants.LINK_ITEM_TYPE_CHARACTER,
            bytes32(secondCharacter),
            NOTE_URI,
            address(0),
            address(0),
            address(0),
            false,
            false
        );
    }

    function testPostNote4CharacterFail() public {
        // NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.postNote4Character(makePostNoteData(firstCharacter), secondCharacter);
    }

    function testPostNote4Address() public {
        address toAddress = address(0x123456789);

        vm.prank(alice);
        web3Entry.postNote4Address(makePostNoteData(firstCharacter), toAddress);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
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
        web3Entry.postNote4Address(makePostNoteData(firstCharacter), toAddress);
    }

    function testPostNote4Linklist() public {
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, LikeLinkType, "")
        );

        web3Entry.postNote4Linklist(makePostNoteData(firstCharacter), FIRST_LINKLIST_ID);
        vm.stopPrank();

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
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
        web3Entry.postNote4Linklist(makePostNoteData(firstCharacter), FIRST_LINKLIST_ID);
    }

    function testPostNote4Note() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        vm.prank(bob);
        web3Entry.postNote4Note(
            makePostNoteData(secondCharacter),
            DataTypes.NoteStruct(firstCharacter, FIRST_NOTE_ID)
        );

        // check note
        DataTypes.Note memory note = web3Entry.getNote(secondCharacter, FIRST_NOTE_ID);
        _matchNote(
            note,
            Constants.LINK_ITEM_TYPE_NOTE,
            keccak256(abi.encodePacked("Note", firstCharacter, FIRST_NOTE_ID)),
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
            makePostNoteData(firstCharacter),
            DataTypes.NoteStruct(firstCharacter, FIRST_NOTE_ID)
        );
    }

    function testPostNote4ERC721() public {
        nft.mint(bob);

        vm.prank(alice);
        web3Entry.postNote4ERC721(
            makePostNoteData(firstCharacter),
            DataTypes.ERC721Struct(address(nft), 1)
        );

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
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
            makePostNoteData(firstCharacter),
            DataTypes.ERC721Struct(address(nft), 1)
        );
    }

    function testPostNote4AnyUri() public {
        string memory uri = "ipfs://abcdefg";

        vm.prank(alice);
        web3Entry.postNote4AnyUri(makePostNoteData(firstCharacter), uri);

        // check note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
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
        web3Entry.postNote4AnyUri(makePostNoteData(firstCharacter), "ipfs://anyURI");
    }

    function testMintNote() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // bob mints a note
        vm.prank(bob);
        web3Entry.mintNote(DataTypes.MintNoteData(firstCharacter, FIRST_NOTE_ID, bob, ""));

        vm.prank(alice);
        web3Entry.lockNote(firstCharacter, FIRST_NOTE_ID);
        // bob mints a locked note
        vm.prank(bob);
        web3Entry.mintNote(DataTypes.MintNoteData(firstCharacter, FIRST_NOTE_ID, bob, ""));

        // check state
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
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
        web3Entry.mintNote(DataTypes.MintNoteData(firstCharacter, FIRST_NOTE_ID, bob, ""));

        // case 2: note is deleted
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));
        web3Entry.deleteNote(firstCharacter, FIRST_NOTE_ID);
        vm.stopPrank();
        // mint a deleted note
        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.mintNote(DataTypes.MintNoteData(firstCharacter, FIRST_NOTE_ID, bob, ""));

        // check state
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
        assertEq(note.mintNFT, address(0));
    }

    function testMintNoteTotalSupply() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        vm.startPrank(bob);
        for (uint256 i = 0; i < 10; i++) {
            web3Entry.mintNote(DataTypes.MintNoteData(firstCharacter, FIRST_NOTE_ID, bob, ""));
        }
        vm.stopPrank();

        // check mint note
        DataTypes.Note memory note = web3Entry.getNote(firstCharacter, FIRST_NOTE_ID);
        address nftAddress = note.mintNFT;
        assertEq(IERC721Enumerable(nftAddress).totalSupply(), 10);
    }

    function testSetMintModule4NoteByOwner() public {
        bytes memory mintModuleInitData = abi.encode(array(carol, dick), 1);

        // post note
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // owner can setMintModule4Note
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.SetMintModule4Note(
            firstCharacter,
            FIRST_NOTE_ID,
            address(approvalMintModule),
            mintModuleInitData,
            mintModuleInitData // returnData
        );
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                firstCharacter,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                mintModuleInitData
            )
        );

        // check mint module
        _checkMintModule(firstCharacter, FIRST_NOTE_ID, address(approvalMintModule));
    }

    function testSetMintModule4NoteByOperator() public {
        bytes memory mintModuleInitData = abi.encode(array(carol, dick), 1);

        // alice posts a note
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // alice sets bob as operator
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, OP.DEFAULT_PERMISSION_BITMAP);

        // operator bob can setMintModule4Note for alice
        vm.prank(bob);
        expectEmit(CheckAll);
        emit Events.SetMintModule4Note(
            firstCharacter,
            FIRST_NOTE_ID,
            address(approvalMintModule),
            mintModuleInitData,
            mintModuleInitData // returnData
        );
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                firstCharacter,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                mintModuleInitData
            )
        );

        // check mint module
        _checkMintModule(firstCharacter, FIRST_NOTE_ID, address(approvalMintModule));
    }

    function testSetMintModule4NoteByOwnerWithPeriphery() public {
        bytes memory mintModuleInitData = abi.encode(array(carol, dick), 1);

        // alice posts a note
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // alice can setMintModule4Note, through the periphery contract
        expectEmit(CheckAll);
        emit Events.SetMintModule4Note(
            firstCharacter,
            FIRST_NOTE_ID,
            address(approvalMintModule),
            mintModuleInitData,
            mintModuleInitData
        );
        vm.prank(address(periphery), alice);
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                firstCharacter,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                mintModuleInitData
            )
        );

        // check mint module
        _checkMintModule(firstCharacter, FIRST_NOTE_ID, address(approvalMintModule));
    }

    function testSetMintModule4NoteByOperatorWithPeriphery() public {
        bytes memory mintModuleInitData = abi.encode(array(carol, dick), 1);

        // alice posts a note
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // alice sets bob as operator
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, OP.DEFAULT_PERMISSION_BITMAP);

        // operator bob can setMintModule4Note for alice, through the periphery contract
        expectEmit(CheckAll);
        emit Events.SetMintModule4Note(
            firstCharacter,
            FIRST_NOTE_ID,
            address(approvalMintModule),
            mintModuleInitData,
            mintModuleInitData
        );
        vm.prank(address(periphery), bob);
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                firstCharacter,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                mintModuleInitData
            )
        );

        // check mint module
        _checkMintModule(firstCharacter, FIRST_NOTE_ID, address(approvalMintModule));
    }

    function testSetMintModule4NoteNotOwnerFail() public {
        vm.prank(alice);
        // alice posts a note
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // not owner nor operator can't
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                firstCharacter,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                ""
            )
        );
    }

    function testSetMintModule4NoteNotExistNoteFail() public {
        vm.startPrank(alice);
        // alice posts a note
        web3Entry.postNote(makePostNoteData(firstCharacter));

        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                firstCharacter,
                SECOND_NOTE_ID,
                address(approvalMintModule),
                ""
            )
        );
        vm.stopPrank();
    }

    function testSetMintModule4NoteLockedNoteFail() public {
        vm.startPrank(alice);
        // alice posts a note
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // alice locks the note
        web3Entry.lockNote(firstCharacter, FIRST_NOTE_ID);

        vm.expectRevert(abi.encodeWithSelector(ErrNoteLocked.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                firstCharacter,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                ""
            )
        );
        vm.stopPrank();
    }

    function testSetMintModule4NoteDeletedNoteFail() public {
        vm.startPrank(alice);
        // alice posts a note
        web3Entry.postNote(makePostNoteData(firstCharacter));

        // alice deletes the note
        web3Entry.deleteNote(firstCharacter, FIRST_NOTE_ID);

        vm.expectRevert(abi.encodeWithSelector(ErrNoteIsDeleted.selector));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                firstCharacter,
                FIRST_NOTE_ID,
                address(approvalMintModule),
                ""
            )
        );
        vm.stopPrank();
    }

    function _checkMintModule(
        uint256 characterId,
        uint256 noteId,
        address expectedMintModule
    ) internal {
        DataTypes.Note memory note = web3Entry.getNote(characterId, noteId);
        assertEq(note.mintModule, expectedMintModule);
    }
}
