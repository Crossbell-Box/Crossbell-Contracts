// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/libraries/DataTypes.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "../contracts/modules/link/ApprovalLinkModule4Character.sol";
import "../contracts/modules/link/ApprovalLinkModule4Note.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../contracts/libraries/OP.sol";
import "./helpers/DefaultOP.sol";

contract OperatorTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);
    address public dick = address(0x4444);
    address public erik = address(0x5555);

    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testGrantOperatorPermissions() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.GrantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // alice set bob as her operator with OP.DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // test bitmap is correctly filtered
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_CHARACTER_ID, bob, ~uint256(0));
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.ALLOWED_PERMISSION_BITMAP_MASK
        );
    }

    function testGrantNoteOperatorPermission() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.GrantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.GrantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            bob,
            DefaultOP.DEFAULT_NOTE_PERMISSION_BITMAP
        );
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            bob,
            DefaultOP.DEFAULT_NOTE_PERMISSION_BITMAP
        );
    }

    function testGetOperatorPermissions() public {
        // alice grant bob OP.DEFAULT_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // alice grant bob OP.OPERATOR_SIGN_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );

        // alice grant bob OP.OPERATOR_SYNC_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATOR_SYNC_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.OPERATOR_SYNC_PERMISSION_BITMAP
        );
    }

    function testEdgeCases() public {
        // make sure that note permissions always go before operator permissions
        // case 1. grant operator permissions first, then grant note permissions
        // grant operator permission first
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        vm.stopPrank();

        // now bob has permissions for all notes
        vm.prank(bob);
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
        vm.prank(bob);
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );

        // then grant bob a note bitmap with less permissons (all default note permissions except setNoteUri)
        vm.prank(alice);
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            bob,
            (1 << 192) | (1 << 194) | (1 << 196) | (1 << 197)
        );
        vm.startPrank(bob);
        vm.expectRevert("NotEnoughPermissionForThisNote");
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
        // but bob still can do other things for this note
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        // and bob still have permissions for note 2
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
        vm.stopPrank();

        // case 2. grant note permissions first, then grant operator permissions
        // grant bob a note bitmap with some permissons (all default note permissions except DELETE_NOTE) for note 2
        vm.prank(alice);
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            bob,
            (1 << 192) | (1 << 194) | (1 << 196) | (1 << 195)
        );

        // now bob has some note permission for note 2
        vm.startPrank(bob);
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
        // but bob can't delete note 2
        vm.expectRevert("NotEnoughPermissionForThisNote");
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.SECOND_NOTE_ID);
        vm.stopPrank();

        // then grant bob operator permissions
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        vm.startPrank(bob);
        // now bob has permissions for all notes
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, 3);
        // but bob still can't delete note 2
        vm.expectRevert("NotEnoughPermissionForThisNote");
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.SECOND_NOTE_ID);
    }

    function testGetOperatorPermissions4Note() public {
        // alice grant bob OP.DEFAULT_PERMISSION_BITMAP permission
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            bob,
            DefaultOP.DEFAULT_NOTE_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions4Note(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                bob
            ),
            DefaultOP.DEFAULT_NOTE_PERMISSION_BITMAP
        );
    }

    function testOperatorSyncCan() public {
        // alice grant bob as OP.OPERATOR_SYNC_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATOR_SYNC_PERMISSION_BITMAP
        );

        vm.startPrank(bob);
        // operatorSync can post note(id = 236)
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
    }

    function testOperatorSignCan() public {
        // alice grant bob as OP.OPERATOR_SIGN_PERMISSION_BITMAP permission
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            carol,
            OP.OPERATOR_SYNC_PERMISSION_BITMAP
        );

        vm.stopPrank();

        vm.startPrank(bob);
        // operatorSign can postNote
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // operatorSign can setCharacterUri
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, "https://example.com/profile");

        // operatorSign can linkCharacter
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType
            )
        );

        web3Entry.createThenLinkCharacter(
            DataTypes.createThenLinkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.MOCK_TO_ADDRESS,
                Const.LinkItemTypeCharacter
            )
        );

        // operatorSign can setlinklisturi
        web3Entry.setLinklistUri(1, Const.MOCK_URI);

        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        // unlinkNote
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType
            )
        );
        // linkERC721
        nft.mint(bob);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // unlinkERC721
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType
            )
        );
        // linkAddress
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // unlinkAddress
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.LikeLinkType
            )
        );
        // linkAnyUri
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // unlinkAnyUri
        web3Entry.unlinkAnyUri(
            DataTypes.unlinkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.LikeLinkType
            )
        );

        // linkLinklist
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                Const.FIRST_CHARACTER_ID,
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // unlinkLinklist
        web3Entry.unlinkLinklist(
            DataTypes.unlinkLinklistData(Const.FIRST_CHARACTER_ID, 1, Const.LikeLinkType)
        );

        ApprovalLinkModule4Character linkModule4Character = new ApprovalLinkModule4Character(
            address(web3Entry)
        );

        // setLinkModule4Character
        //        web3Entry.setLinkModule4Character(
        //            DataTypes.setLinkModule4CharacterData(
        //                Const.FIRST_CHARACTER_ID,
        //                address(linkModule4Character),
        //                new bytes(0)
        //            )
        //        );

        // setLinkModule4Linklist
        // i use the address(linkModule4Character) for link module(cuz the logic here is the same)
        web3Entry.setLinkModule4Linklist(
            DataTypes.setLinkModule4LinklistData(
                Const.FIRST_LINKLIST_ID,
                address(linkModule4Character),
                new bytes(0)
            )
        );

        // postNote4Character
        web3Entry.postNote4Character(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            Const.FIRST_CHARACTER_ID
        );

        // postNote4Address
        web3Entry.postNote4Address(makePostNoteData(Const.FIRST_CHARACTER_ID), address(0x328));

        // postNote4Linklist
        web3Entry.postNote4Linklist(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            Const.FIRST_LINKLIST_ID
        );

        // postNote4Note
        web3Entry.postNote4Note(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            DataTypes.NoteStruct(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID)
        );

        // postNote4ERC721
        nft.mint(bob);
        web3Entry.postNote4ERC721(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            DataTypes.ERC721Struct(address(nft), 1)
        );

        // postNote4AnyUri
        web3Entry.postNote4AnyUri(makePostNoteData(Const.FIRST_CHARACTER_ID), "ipfs://anyURI");

        vm.stopPrank();

        // operator with owner permissions can:
        // alice grant bob all permissions including owner permissions
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.ALLOWED_PERMISSION_BITMAP_MASK
        );
        vm.startPrank(bob);
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, "mynewhandle");
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(0x1234567));
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            carol,
            OP.ALLOWED_PERMISSION_BITMAP_MASK
        );
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            carol,
            OP.DEFAULT_PERMISSION_BITMAP
        );
    }

    function testOperatorFail() public {
        // alice set bob as her operator with OP.DEFAULT_PERMISSION_BITMAP (access to all notes
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        vm.stopPrank();

        // default operator can't setHandle
        vm.startPrank(bob);
        vm.expectRevert(abi.encodePacked("NotEnoughPermission"));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, "new-handle");

        // can't set primary character id
        // user can only set primary character id to himself
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setPrimaryCharacterId(Const.FIRST_CHARACTER_ID);

        // can't set social token
        vm.expectRevert(abi.encodePacked("NotEnoughPermission"));
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(0x132414));

        // can't grant operator
        vm.expectRevert(abi.encodePacked("NotEnoughPermission"));
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            carol,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // can't grant operator for note
        vm.expectRevert(abi.encodePacked("NotEnoughPermission"));
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            carol,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        vm.stopPrank();

        // fail after canceling grant
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATOR_SYNC_PERMISSION_BITMAP
        );
        web3Entry.grantOperatorPermissions(Const.FIRST_CHARACTER_ID, bob, 0);
        vm.stopPrank();
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NotEnoughPermission"));
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // operator with sync permission can't sign
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATOR_SYNC_PERMISSION_BITMAP
        );
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NotEnoughPermissionForThisNote"));
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
    }

    function testOperator4NoteCan() public {
        // alice grant bob as OP.OPERATOR_SIGN_PERMISSION_BITMAP permission
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        // ApprovalLinkModule4Note linkModule4Note = new ApprovalLinkModule4Note(address(web3Entry));

        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            carol,
            DefaultOP.DEFAULT_NOTE_PERMISSION_BITMAP
        );
        vm.stopPrank();

        // setLinkModule4Note
        vm.startPrank(bob);
        /*
      web3Entry.setLinkModule4Note(
          DataTypes.setLinkModule4NoteData(
              Const.FIRST_CHARACTER_ID,
              Const.FIRST_NOTE_ID,
              address(linkModule4Note),
              new bytes(0)
          )
      );
      */

        // setMintModule4Note
        ApprovalMintModule mintModule = new ApprovalMintModule(address(web3Entry));
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                address(mintModule),
                new bytes(0)
            )
        );

        // setNoteUri
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );

        // lockNote
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        // delete note
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        vm.stopPrank();

        vm.startPrank(carol);

        // setNoteUri
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );

        // setMintModule4Note
        web3Entry.setMintModule4Note(
            DataTypes.setMintModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_NOTE_ID,
                address(mintModule),
                new bytes(0)
            )
        );

        // lockNote
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.SECOND_NOTE_ID);

        // delete note
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.SECOND_NOTE_ID);

        vm.stopPrank();

        // alice grant all permission to bob(including owner permissions)
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.ALLOWED_PERMISSION_BITMAP_MASK
        );
        vm.startPrank(bob);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            carol,
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            3,
            carol,
            DefaultOP.DEFAULT_NOTE_PERMISSION_BITMAP
        );
    }

    function testOperator4NoteFail() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // alice grant bob all note permission except DELETE_NOTE permission (access to all notes)
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            (1 << 192) | (1 << 194) | (1 << 195) | (1 << 196)
        );

        // alice grant carol all note permission except LOCK_NOTE permission (access to the first note only)
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            carol,
            (1 << 192) | (1 << 194) | (1 << 195) | (1 << 197)
        );
        vm.stopPrank();

        // bob doesn't have delete permission
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NotEnoughPermissionForThisNote"));
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        // carol has no access to note 2
        vm.prank(carol);
        vm.expectRevert(abi.encodePacked("NotEnoughPermissionForThisNote"));
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );

        // carol can't lock note
        vm.prank(carol);
        vm.expectRevert(abi.encodePacked("NotEnoughPermissionForThisNote"));
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        // grant carol with operator permission will not be effective until you revoke the previous note permissions.
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            carol,
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );
        // now carol has permission to all notes
        vm.prank(carol);
        vm.expectRevert(abi.encodePacked("NotEnoughPermissionForThisNote"));
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
        // but carol still have no access to lock note 1, because note permissions always go first before operator permissions
        vm.prank(carol);
        vm.expectRevert(abi.encodePacked("NotEnoughPermissionForThisNote"));
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
    }

    function testMigrate() public {
        // TODO how to test migrate?
        // vm.startPrank(alice);
        // web3Entry.setOperator(Const.FIRST_CHARACTER_ID, bob);
        // web3Entry.addOperator(Const.FIRST_CHARACTER_ID, carol);
        // web3Entry.addOperator(Const.FIRST_CHARACTER_ID, dick);
        // web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        // vm.stopPrank();
        // uint256[] memory characters = new uint256[](1);
        // characters[0] = 1;
        // web3Entry.migrateOperator(characters);
        // vm.startPrank(bob);
        // web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, "https://example.com/profile");
    }

    function testSetOperator() public {
        vm.startPrank(alice);
        // expect event GrantOperatorPermissions
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.GrantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );

        // expect event SetOperator
        expectEmit(CheckTopic1 | CheckTopic2 | CheckData);
        emit Events.SetOperator(Const.FIRST_CHARACTER_ID, bob, block.timestamp);

        // add an operator
        web3Entry.setOperator(Const.FIRST_CHARACTER_ID, bob);
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );

        // users can't remove an operator by setOperator
        web3Entry.setOperator(Const.FIRST_CHARACTER_ID, address(0));
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );
        vm.stopPrank();
    }

    function testSetOperatorFail() public {
        vm.startPrank(carol);
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setOperator(Const.FIRST_CHARACTER_ID, bob);
        vm.stopPrank();
    }

    function testAddOperator() public {
        vm.startPrank(alice);

        // expect event GrantOperatorPermissions
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.GrantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            carol,
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );

        // expect event SetOperator
        expectEmit(CheckTopic1 | CheckTopic2 | CheckData);
        emit Events.AddOperator(Const.FIRST_CHARACTER_ID, carol, block.timestamp);

        // add operator
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, carol);
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, carol),
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );
        vm.stopPrank();
    }

    function testAddOperatorFail() public {
        vm.startPrank(carol);
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, bob);
        vm.stopPrank();
    }

    function testRemoveOperator() public {
        vm.startPrank(alice);

        // add operator
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, bob);
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.OPERATOR_SIGN_PERMISSION_BITMAP
        );

        // remove operator
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.GrantOperatorPermissions(Const.FIRST_CHARACTER_ID, bob, uint256(0));
        expectEmit(CheckTopic1 | CheckTopic2 | CheckData);
        emit Events.RemoveOperator(Const.FIRST_CHARACTER_ID, bob, block.timestamp);
        web3Entry.removeOperator(Const.FIRST_CHARACTER_ID, bob);
        assertEq(web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob), uint256(0));
        vm.stopPrank();
    }

    function testRemoveOperatorFail() public {
        vm.startPrank(carol);
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.removeOperator(Const.FIRST_CHARACTER_ID, bob);
        vm.stopPrank();
    }

    function testGetOperators() public {
        address[4] memory accounts = [bob, carol, dick, erik];

        // case 1. use addOperator to test getOperators
        vm.startPrank(alice);
        for (uint256 i = 0; i < accounts.length; i++) {
            web3Entry.addOperator(Const.FIRST_CHARACTER_ID, accounts[i]);
        }

        //  check operators
        _checkOperators(Const.FIRST_CHARACTER_ID, accounts, OP.OPERATOR_SIGN_PERMISSION_BITMAP);

        // remove all operators
        for (uint256 i = 0; i < accounts.length; i++) {
            web3Entry.removeOperator(Const.FIRST_CHARACTER_ID, accounts[i]);
        }
        address[] memory operators = web3Entry.getOperators(Const.FIRST_CHARACTER_ID);
        assertEq(operators.length, 0);

        // case 2. use setOperator to test getOperators
        for (uint256 i = 0; i < accounts.length; i++) {
            web3Entry.setOperator(Const.FIRST_CHARACTER_ID, accounts[i]);
        }

        //  check operators
        _checkOperators(Const.FIRST_CHARACTER_ID, accounts, OP.OPERATOR_SIGN_PERMISSION_BITMAP);

        // remove all operators
        for (uint256 i = 0; i < accounts.length; i++) {
            web3Entry.removeOperator(Const.FIRST_CHARACTER_ID, accounts[i]);
        }
        operators = web3Entry.getOperators(Const.FIRST_CHARACTER_ID);
        assertEq(operators.length, 0);

        // case 3. use grantOperatorPermissions to test getOperators
        for (uint256 i = 0; i < accounts.length; i++) {
            web3Entry.grantOperatorPermissions(
                Const.FIRST_CHARACTER_ID,
                accounts[i],
                OP.OPERATOR_SIGN_PERMISSION_BITMAP
            );
        }
        _checkOperators(Const.FIRST_CHARACTER_ID, accounts, OP.OPERATOR_SIGN_PERMISSION_BITMAP);

        // remove all operators
        for (uint256 i = 0; i < accounts.length; i++) {
            web3Entry.grantOperatorPermissions(Const.FIRST_CHARACTER_ID, accounts[i], 0);
        }
        operators = web3Entry.getOperators(Const.FIRST_CHARACTER_ID);
        assertEq(operators.length, 0);

        vm.stopPrank();
    }

    function _checkOperators(
        uint256 characterId,
        address[4] memory expectedOperators,
        uint256 expectedPermission
    ) internal {
        address[] memory operators = web3Entry.getOperators(characterId);
        for (uint256 i = 0; i < operators.length; i++) {
            assertEq(operators[i], expectedOperators[i]);
            // check Operator permission
            assertEq(
                web3Entry.getOperatorPermissions(characterId, expectedOperators[i]),
                expectedPermission
            );
            // check isOperator
            assertTrue(web3Entry.isOperator(characterId, expectedOperators[i]));
        }
    }

    function testValidate() public {
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // owner can
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // periphery can
        vm.prank(address(periphery), alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // bob can
        vm.prank(bob);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
    }

    function testValidateFail() public {
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATOR_SYNC_PERMISSION_BITMAP
        );

        // carol can not
        vm.prank(carol);
        vm.expectRevert("NotEnoughPermission");
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // bob can not
        vm.prank(bob);
        vm.expectRevert("NotEnoughPermissionForThisNote");
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
    }
}
