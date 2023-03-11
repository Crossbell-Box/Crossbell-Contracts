// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {CommonTest} from "./helpers/CommonTest.sol";
import {OP} from "../contracts/libraries/OP.sol";
import {Events} from "../contracts/libraries/Events.sol";
import {Constants} from "../contracts/libraries/Constants.sol";
import {NewbieVilla} from "../contracts/misc/NewbieVilla.sol";
import {DataTypes} from "../contracts/libraries/DataTypes.sol";
import {
    ErrNotCharacterOwner,
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote,
    ErrNoteIsDeleted,
    ErrNoteNotExists,
    ErrNoteLocked
} from "../contracts/libraries/Error.sol";
import {
    ApprovalLinkModule4Character
} from "../contracts/modules/link/ApprovalLinkModule4Character.sol";

contract OperatorTest is CommonTest {
    address[] public blocklist = [bob];
    address[] public allowlist = [carol, dick];

    address public constant migrateOwner = 0xda2423ceA4f1047556e7a142F81a7ED50e93e160;

    function setUp() public {
        _setUp();

        // create character
        _createCharacter(MOCK_CHARACTER_HANDLE, alice);
        _createCharacter(MOCK_CHARACTER_HANDLE2, bob);
    }

    function testGrantOperatorPermissions() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.GrantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);

        // alice set bob as her operator with OP.DEFAULT_PERMISSION_BITMAP
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        assertEq(
            web3Entry.getOperatorPermissions(FIRST_CHARACTER_ID, bob),
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // grant operator sync permission
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.POST_NOTE_PERMISSION_BITMAP);
        assertEq(
            web3Entry.getOperatorPermissions(FIRST_CHARACTER_ID, bob),
            OP.POST_NOTE_PERMISSION_BITMAP
        );

        // test bitmap is correctly filtered
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, UINT256_MAX);
        assertEq(
            web3Entry.getOperatorPermissions(FIRST_CHARACTER_ID, bob),
            OP.ALLOWED_PERMISSION_BITMAP_MASK
        );
        vm.stopPrank();
    }

    function testGrantOperatorPermissionsFail() public {
        // bob is not the owner of FIRST_CHARACTER_ID, he can't grant
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
    }

    // solhint-disable-next-line function-max-lines
    function testGrantOperators4Note() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.GrantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, allowlist);

        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, allowlist);

        (address[] memory blocklist_, address[] memory allowlist_) = web3Entry.getOperators4Note(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID
        );

        assertEq(blocklist_, blocklist);
        assertEq(allowlist_, allowlist);

        // blocklist and allowlist are overwritten correctly
        // i swap blocklist and allowlist here for convenience.
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, allowlist, blocklist);
        (blocklist_, allowlist_) = web3Entry.getOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID);

        assertEq(blocklist_, allowlist);
        assertEq(allowlist_, blocklist);
        // check operator note permission
        for (uint256 i = 0; i < allowlist_.length; i++) {
            assertTrue(
                web3Entry.isOperatorAllowedForNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, allowlist_[i])
            );
        }
        for (uint256 i = 0; i < blocklist_.length; i++) {
            assertFalse(
                web3Entry.isOperatorAllowedForNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist_[i])
            );
        }
    }

    function testGrantOperators4NoteFail() public {
        // bob is not owner of FIRST_CHARACTER_ID, can't grant
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, allowlist);

        // note doesn't exist
        vm.expectRevert(abi.encodeWithSelector(ErrNoteNotExists.selector));
        vm.prank(alice);
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, SECOND_NOTE_ID, blocklist, allowlist);
    }

    function testGetOperatorPermissions() public {
        // alice grant bob OP.DEFAULT_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        assertEq(
            web3Entry.getOperatorPermissions(FIRST_CHARACTER_ID, bob),
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // alice grant bob OP.POST_NOTE_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.POST_NOTE_PERMISSION_BITMAP);
        assertEq(
            web3Entry.getOperatorPermissions(FIRST_CHARACTER_ID, bob),
            OP.POST_NOTE_PERMISSION_BITMAP
        );
    }

    function testOperatorsWithTransfer() public {
        // case 1: alice transfer its character
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        web3Entry.safeTransferFrom(alice, carol, FIRST_CHARACTER_ID);
        vm.stopPrank();

        // check operator permission
        assertEq(web3Entry.getOperatorPermissions(FIRST_CHARACTER_ID, bob), 0);
        address[] memory operators = web3Entry.getOperators(FIRST_CHARACTER_ID);
        assertEq(operators.length, 0);
    }

    function testOperatorsWithTransferFromNewbieVilla() public {
        // case 2: alice withdraw its character from newbieVilla contract
        uint256 characterId;
        uint256 nonce = 1;
        uint256 expires = block.timestamp + 10 minutes;

        // create and transfer web3Entry nft to newbieVilla
        characterId = web3Entry.createCharacter(
            makeCharacterData(MOCK_CHARACTER_HANDLE3, newbieAdmin)
        );
        vm.prank(newbieAdmin);
        web3Entry.safeTransferFrom(newbieAdmin, address(newbieVilla), characterId);
        // generate proof for withdrawal
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(address(newbieVilla), characterId, nonce, expires))
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(newbieAdminPrivateKey, digest);
        // withdraw character from newbieVilla
        vm.prank(alice);
        newbieVilla.withdraw(alice, characterId, nonce, expires, abi.encodePacked(r, s, v));

        // check operator permission
        assertEq(
            web3Entry.getOperatorPermissions(characterId, xsyncOperator),
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(characterId, newbieAdmin),
            OP.DEFAULT_PERMISSION_BITMAP
        );
        address[] memory operators = web3Entry.getOperators(characterId);
        assertEq(operators.length, 2);
    }

    // solhint-disable-next-line function-max-lines
    function testEdgeCases() public {
        // make sure that note permissions always go before operator permissions
        // case 1. grant operator permissions first, then grant note permissions
        // grant operator permission first
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        vm.stopPrank();

        // now bob has permissions for all notes
        vm.prank(bob);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI);
        vm.prank(bob);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, MOCK_NEW_NOTE_URI);

        // then put bob into blocklist of note 1
        vm.prank(alice);
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, allowlist);
        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermissionForThisNote.selector));
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI);
        // but bob still can do other things for this note
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        // and bob still have permissions for note 2
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, MOCK_NEW_NOTE_URI);
        vm.stopPrank();

        // case 2. put carol into allowlist, then disable carol's operator permission
        vm.prank(alice);
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, SECOND_NOTE_ID, blocklist, allowlist);

        // now carol is in allowlist for note 2
        vm.prank(carol);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, MOCK_NEW_NOTE_URI);

        // then disable carol's operator permissions
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, carol, 0);
        // but carol can still edit note 2(cuz note validation goes first)
        vm.prank(carol);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, MOCK_NEW_NOTE_URI);
    }

    // solhint-disable-next-line function-max-lines
    function testOperatorCan() public {
        // alice grant bob as OP.POST_NOTE_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.POST_NOTE_PERMISSION_BITMAP);

        vm.prank(bob);
        // operatorSync can post note(id = 236)
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // alice grant bob as OP.DEFAULT_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);

        vm.startPrank(bob);
        // bob can postNote
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        // bob can setCharacterUri
        web3Entry.setCharacterUri(FIRST_CHARACTER_ID, "https://example.com/character");
        // bob can linkCharacter
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                LikeLinkType,
                new bytes(0)
            )
        );
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID, LikeLinkType)
        );
        web3Entry.createThenLinkCharacter(
            DataTypes.createThenLinkCharacterData(
                FIRST_CHARACTER_ID,
                MOCK_TO_ADDRESS,
                Constants.LINK_ITEM_TYPE_CHARACTER
            )
        );
        // bob can setlinklisturi
        web3Entry.setLinklistUri(1, MOCK_URI);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType,
                new bytes(0)
            )
        );
        // unlinkNote
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(
                FIRST_CHARACTER_ID,
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                FollowLinkType
            )
        );
        // linkERC721
        nft.mint(bob);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                FIRST_CHARACTER_ID,
                address(nft),
                1,
                LikeLinkType,
                new bytes(0)
            )
        );
        // unlinkERC721
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(FIRST_CHARACTER_ID, address(nft), 1, LikeLinkType)
        );
        // linkAddress
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                FIRST_CHARACTER_ID,
                address(0x1232414),
                LikeLinkType,
                new bytes(0)
            )
        );
        // unlinkAddress
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(FIRST_CHARACTER_ID, address(0x1232414), LikeLinkType)
        );
        // linkAnyUri
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                LikeLinkType,
                new bytes(0)
            )
        );
        // unlinkAnyUri
        web3Entry.unlinkAnyUri(
            DataTypes.unlinkAnyUriData(FIRST_CHARACTER_ID, "ipfs://anyURI", LikeLinkType)
        );
        // linkLinklist
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(FIRST_CHARACTER_ID, 1, LikeLinkType, new bytes(0))
        );
        // unlinkLinklist
        web3Entry.unlinkLinklist(DataTypes.unlinkLinklistData(FIRST_CHARACTER_ID, 1, LikeLinkType));
        ApprovalLinkModule4Character linkModule4Character = new ApprovalLinkModule4Character(
            address(web3Entry)
        );
        // setLinkModule4Character
        //        web3Entry.setLinkModule4Character(
        //            DataTypes.setLinkModule4CharacterData(
        //                FIRST_CHARACTER_ID,
        //                address(linkModule4Character),
        //                new bytes(0)
        //            )
        //        );
        // setLinkModule4Linklist
        // i use the address(linkModule4Character) for link module(cuz the logic here is the same)
        web3Entry.setLinkModule4Linklist(
            DataTypes.setLinkModule4LinklistData(
                FIRST_LINKLIST_ID,
                address(linkModule4Character),
                new bytes(0)
            )
        );

        // postNote4Character
        web3Entry.postNote4Character(makePostNoteData(FIRST_CHARACTER_ID), FIRST_CHARACTER_ID);
        // postNote4Address
        web3Entry.postNote4Address(makePostNoteData(FIRST_CHARACTER_ID), address(0x328));
        // postNote4Linklist
        web3Entry.postNote4Linklist(makePostNoteData(FIRST_CHARACTER_ID), FIRST_LINKLIST_ID);
        // postNote4Note
        web3Entry.postNote4Note(
            makePostNoteData(FIRST_CHARACTER_ID),
            DataTypes.NoteStruct(FIRST_CHARACTER_ID, FIRST_NOTE_ID)
        );
        // postNote4ERC721
        nft.mint(bob);
        web3Entry.postNote4ERC721(
            makePostNoteData(FIRST_CHARACTER_ID),
            DataTypes.ERC721Struct(address(nft), 1)
        );
        // postNote4AnyUri
        web3Entry.postNote4AnyUri(makePostNoteData(FIRST_CHARACTER_ID), "ipfs://anyURI");
        vm.stopPrank();

        // operator with owner permissions can:
        // alice grant bob all permissions including owner permissions
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            FIRST_CHARACTER_ID,
            bob,
            OP.ALLOWED_PERMISSION_BITMAP_MASK
        );
        vm.startPrank(bob);
        web3Entry.setHandle(FIRST_CHARACTER_ID, "mynewhandle");
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(0x1234567));
        web3Entry.grantOperatorPermissions(
            FIRST_CHARACTER_ID,
            carol,
            OP.ALLOWED_PERMISSION_BITMAP_MASK
        );
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, allowlist);
        vm.stopPrank();
    }

    // solhint-disable-next-line function-max-lines
    function testOperatorFail() public {
        // alice set bob as her operator with OP.DEFAULT_PERMISSION_BITMAP (access to all notes
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        vm.stopPrank();

        // default operator can't setHandle
        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setHandle(FIRST_CHARACTER_ID, "new-handle");

        // can't set primary character id
        // user can only set primary character id to himself
        vm.expectRevert(abi.encodeWithSelector(ErrNotCharacterOwner.selector));
        web3Entry.setPrimaryCharacterId(FIRST_CHARACTER_ID);

        // can't set social token
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setSocialToken(FIRST_CHARACTER_ID, address(0x132414));

        // can't grant operator
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, carol, OP.DEFAULT_PERMISSION_BITMAP);

        // can't add operator for note
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, allowlist);
        vm.stopPrank();

        // fail after canceling grant
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.POST_NOTE_PERMISSION_BITMAP);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, 0);
        vm.stopPrank();

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // operator with sync permission can't sign
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.POST_NOTE_PERMISSION_BITMAP);
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermissionForThisNote.selector));
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI);
    }

    function testOperator4NoteCan() public {
        // alice grant bob as OP.OPERATOR_SIGN_PERMISSION_BITMAP permission
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        vm.stopPrank();

        vm.startPrank(bob);
        // setNoteUri
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI);
        // lockNote
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        // delete note
        web3Entry.deleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.stopPrank();

        vm.prank(alice);
        // add carol as allowlist
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, SECOND_NOTE_ID, blocklist, allowlist);

        vm.prank(carol);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, MOCK_NEW_NOTE_URI);
    }

    function testOperator4NoteFail() public {
        // case 1. bob's operator permission is on, but bob is in blocklist
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, allowlist);
        vm.stopPrank();

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermissionForThisNote.selector));
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI);
        vm.stopPrank();

        // case 2. bob's in blocklist and also allowlist
        vm.prank(alice);
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, blocklist);
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermissionForThisNote.selector));
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI);
    }

    function testGetOperators() public {
        address[4] memory accounts = [bob, carol, dick, erik];

        vm.startPrank(alice);
        for (uint256 i = 0; i < accounts.length; i++) {
            web3Entry.grantOperatorPermissions(
                FIRST_CHARACTER_ID,
                accounts[i],
                OP.DEFAULT_PERMISSION_BITMAP
            );
        }
        _checkOperators(FIRST_CHARACTER_ID, accounts, OP.DEFAULT_PERMISSION_BITMAP);

        // remove all operators
        for (uint256 i = 0; i < accounts.length; i++) {
            web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, accounts[i], 0);
        }
        address[] memory operators = web3Entry.getOperators(FIRST_CHARACTER_ID);
        assertEq(operators.length, 0);

        vm.stopPrank();
    }

    function testGetOperators4Note() public {
        // alice grant bob OP.DEFAULT_PERMISSION_BITMAP permission
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, allowlist);
        address[] memory blocklist_;
        address[] memory allowlist_;
        (blocklist_, allowlist_) = web3Entry.getOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        assertEq(blocklist_, blocklist);
        assertEq(allowlist_, allowlist);
    }

    function testValidateCallerPermission() public {
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);

        // owner can
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // owner behind periphery can
        vm.prank(address(periphery), alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // operator behind periphery can
        vm.prank(address(periphery), bob);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // bob can
        vm.prank(bob);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));
    }

    function testValidateCallerPermissionFail() public {
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.POST_NOTE_PERMISSION_BITMAP);

        // carol can not
        vm.prank(carol);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // bob can not
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermissionForThisNote.selector));
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI);
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
        }
    }
}
