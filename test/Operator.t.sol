// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {CommonTest} from "./helpers/CommonTest.sol";
import {OP} from "../contracts/libraries/OP.sol";
import {Events} from "../contracts/libraries/Events.sol";
import {DataTypes} from "../contracts/libraries/DataTypes.sol";
import {
    ErrNotCharacterOwner,
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote,
    ErrNoteNotExists,
    ErrSignatureExpired,
    ErrSignatureInvalid
} from "../contracts/libraries/Error.sol";
import {ERC1271WalletMock, ERC1271MaliciousMock} from "../contracts/mocks/ERC1271WalletMock.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract OperatorTest is CommonTest {
    address[] public blocklist = [bob];
    address[] public allowlist = [carol, dick];

    address public constant migrateOwner = 0xda2423ceA4f1047556e7a142F81a7ED50e93e160;

    ERC1271WalletMock public erc1271wallet;
    ERC1271MaliciousMock public erc1271Malicious;

    // solhint-disable-next-line private-vars-leading-underscore, var-name-mixedcase
    bytes32 internal constant TYPEHASH =
        keccak256( // solhint-disable-next-line max-line-length
            "grantOperatorPermissions(uint256 characterId,address operator,uint256 permissionBitMap,uint256 nonce,uint256 deadline)"
        );

    function setUp() public {
        _setUp();

        erc1271wallet = new ERC1271WalletMock(alice);
        erc1271Malicious = new ERC1271MaliciousMock();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testGrantOperatorPermissions() public {
        expectEmit(CheckAll);
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

    function testGrantOperatorPermissionsWithSig() public {
        uint256 characterId = FIRST_CHARACTER_ID;
        address operator = bob;
        uint256 permissionBitMap = OP.DEFAULT_PERMISSION_BITMAP;
        uint256 deadline = block.timestamp + 10;
        uint256 nonce = web3Entry.nonces(alice);

        bytes32 hashedMessage = keccak256(
            abi.encode(TYPEHASH, characterId, operator, permissionBitMap, nonce, deadline)
        );
        DataTypes.EIP712Signature memory sig = _getEIP712Signature(alicePrivateKey, hashedMessage);
        sig.deadline = deadline;

        web3Entry.grantOperatorPermissionsWithSig(
            FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP,
            sig
        );

        // check operator permission
        assertEq(
            web3Entry.getOperatorPermissions(FIRST_CHARACTER_ID, bob),
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(web3Entry.nonces(alice), 1);
    }

    function testGrantOperatorPermissionsWithSigWithERC1271Wallet() public {
        uint256 characterId = FIRST_CHARACTER_ID;
        address operator = bob;
        uint256 permissionBitMap = OP.DEFAULT_PERMISSION_BITMAP;
        uint256 deadline = block.timestamp + 10;
        address signer = address(erc1271wallet);
        uint256 nonce = web3Entry.nonces(signer);

        // transfer character to erc1271wallet
        vm.prank(alice);
        web3Entry.safeTransferFrom(alice, signer, characterId);

        // generate signature
        bytes32 hashedMessage = keccak256(
            abi.encode(TYPEHASH, characterId, operator, permissionBitMap, nonce, deadline)
        );
        DataTypes.EIP712Signature memory sig = _getEIP712Signature(alicePrivateKey, hashedMessage);
        sig.deadline = deadline;
        sig.signer = signer;

        // call grantOperatorPermissionsWithSig
        web3Entry.grantOperatorPermissionsWithSig(characterId, bob, permissionBitMap, sig);

        // check operator permission
        assertEq(web3Entry.getOperatorPermissions(characterId, bob), permissionBitMap);
        assertEq(web3Entry.nonces(signer), 1);
    }

    function testGrantOperatorPermissionsWithSigFailSignatureExpired() public {
        uint256 characterId = FIRST_CHARACTER_ID;
        address operator = bob;
        uint256 permissionBitMap = OP.DEFAULT_PERMISSION_BITMAP;
        uint256 deadline = block.timestamp + 10;
        uint256 nonce = web3Entry.nonces(alice);

        bytes32 hashedMessage = keccak256(
            abi.encode(TYPEHASH, characterId, operator, permissionBitMap, nonce, deadline)
        );
        DataTypes.EIP712Signature memory sig = _getEIP712Signature(alicePrivateKey, hashedMessage);
        sig.deadline = block.timestamp - 1;

        // case 1: signature expired
        vm.expectRevert(abi.encodeWithSelector(ErrSignatureExpired.selector));
        web3Entry.grantOperatorPermissionsWithSig(characterId, operator, permissionBitMap, sig);

        // check operator permission
        assertEq(web3Entry.getOperatorPermissions(characterId, bob), 0);
    }

    function testGrantOperatorPermissionsWithSigFailSignatureInvalid() public {
        uint256 characterId = FIRST_CHARACTER_ID;
        address operator = bob;
        uint256 permissionBitMap = OP.DEFAULT_PERMISSION_BITMAP;
        uint256 deadline = block.timestamp + 10;
        uint256 nonce = web3Entry.nonces(alice);

        bytes32 hashedMessage = keccak256(
            abi.encode(TYPEHASH, characterId, operator, permissionBitMap, nonce, deadline)
        );
        DataTypes.EIP712Signature memory sig = _getEIP712Signature(alicePrivateKey, hashedMessage);
        sig.deadline = deadline;
        sig.v = sig.v + 1;

        // case 2: signature invalid
        vm.expectRevert(abi.encodeWithSelector(ErrSignatureInvalid.selector));
        web3Entry.grantOperatorPermissionsWithSig(characterId, operator, permissionBitMap, sig);

        // check operator permission
        assertEq(web3Entry.getOperatorPermissions(characterId, bob), 0);
    }

    function testGrantOperatorPermissionsWithSigFailSignatureInvalid2() public {
        uint256 characterId = FIRST_CHARACTER_ID;
        address operator = bob;
        uint256 permissionBitMap = OP.DEFAULT_PERMISSION_BITMAP;
        uint256 deadline = block.timestamp + 10;
        uint256 nonce = web3Entry.nonces(alice);

        bytes32 hashedMessage = keccak256(
            abi.encode(TYPEHASH, characterId, operator, permissionBitMap, nonce, deadline)
        );
        DataTypes.EIP712Signature memory sig = _getEIP712Signature(alicePrivateKey, hashedMessage);
        sig.deadline = deadline;
        web3Entry.grantOperatorPermissionsWithSig(characterId, operator, permissionBitMap, sig);

        // case 3: signature invalid(invalid nonce)
        vm.expectRevert(abi.encodeWithSelector(ErrSignatureInvalid.selector));
        web3Entry.grantOperatorPermissionsWithSig(characterId, operator, permissionBitMap, sig);
    }

    function testGrantOperatorPermissionsWithSigFailWithMaliciousERC1271Wallet() public {
        uint256 characterId = FIRST_CHARACTER_ID;
        uint256 permissionBitMap = OP.DEFAULT_PERMISSION_BITMAP;
        uint256 deadline = block.timestamp + 10;
        address signer = address(erc1271Malicious);

        // transfer character to erc1271Malicious
        vm.prank(alice);
        web3Entry.safeTransferFrom(alice, signer, characterId);

        // generate signature
        DataTypes.EIP712Signature memory sig = _getEIP712Signature(alicePrivateKey, bytes32Zero);
        sig.deadline = deadline;
        sig.signer = signer;

        // call grantOperatorPermissionsWithSig
        vm.expectRevert(abi.encodeWithSelector(ErrSignatureInvalid.selector));
        web3Entry.grantOperatorPermissionsWithSig(characterId, bob, permissionBitMap, sig);

        // check operator permission
        assertEq(web3Entry.getOperatorPermissions(characterId, bob), 0);
    }

    function testGrantOperators4Note() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        expectEmit(CheckAll);
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

    function testOperatorsWithTransferCharacter() public {
        uint256 characterId = FIRST_CHARACTER_ID;

        // case 1: alice sets operators and then transfers its character
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(characterId, bob, OP.DEFAULT_PERMISSION_BITMAP);
        web3Entry.grantOperatorPermissions(characterId, carol, OP.POST_NOTE_PERMISSION_BITMAP);
        web3Entry.safeTransferFrom(alice, dick, characterId);
        vm.stopPrank();

        // check operator permission
        assertEq(web3Entry.getOperatorPermissions(characterId, bob), 0);
        assertEq(web3Entry.getOperatorPermissions(characterId, carol), 0);
        assertEq(web3Entry.getOperators(characterId).length, 0);
    }

    function testOperatorsWithTransferFromNewbieVilla() public {
        // case 2: alice withdraw its character from newbieVilla contract
        uint256 characterId;
        uint256 nonce = 1;
        uint256 expires = block.timestamp + 10 minutes;

        // create and transfer web3Entry nft to newbieVilla
        characterId = web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE3, newbieAdmin));
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
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);
        vm.prank(bob);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, NEW_NOTE_URI);

        // then put bob into blocklist of note 1
        vm.prank(alice);
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, allowlist);
        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermissionForThisNote.selector));
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);
        // but bob still can do other things for this note
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        // and bob still have permissions for note 2
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, NEW_NOTE_URI);
        vm.stopPrank();

        // case 2. put carol into allowlist, then disable carol's operator permission
        vm.prank(alice);
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, SECOND_NOTE_ID, blocklist, allowlist);

        // now carol is in allowlist for note 2
        vm.prank(carol);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, NEW_NOTE_URI);

        // then disable carol's operator permissions
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, carol, 0);
        // but carol can still edit note 2(cuz note validation goes first)
        vm.prank(carol);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, NEW_NOTE_URI);
    }

    // solhint-disable-next-line function-max-lines
    function testOperatorCan() public {
        uint256 characterId = FIRST_CHARACTER_ID;

        // case 1: post note
        // alice grant bob as OP.POST_NOTE_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(characterId, bob, OP.POST_NOTE_PERMISSION_BITMAP);
        vm.prank(bob);
        // bob can post note
        web3Entry.postNote(makePostNoteData(characterId));

        // case 2 : default permission
        // alice grant bob as OP.DEFAULT_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(characterId, bob, OP.DEFAULT_PERMISSION_BITMAP);
        vm.startPrank(bob);
        // bob can postNote
        web3Entry.postNote(makePostNoteData(characterId));
        // bob can setCharacterUri
        web3Entry.setCharacterUri(characterId, "https://example.com/character");
        // bob can linkCharacter
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(characterId, SECOND_CHARACTER_ID, LikeLinkType, "")
        );
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(characterId, SECOND_CHARACTER_ID, LikeLinkType)
        );
        web3Entry.createThenLinkCharacter(
            DataTypes.createThenLinkCharacterData(characterId, address(0x199), FollowLinkType)
        );
        // bob can set linklist uri
        web3Entry.setLinklistUri(1, MOCK_URI);
        web3Entry.linkNote(
            DataTypes.linkNoteData(characterId, characterId, FIRST_NOTE_ID, FollowLinkType, "")
        );
        // unlinkNote
        web3Entry.unlinkNote(
            DataTypes.unlinkNoteData(characterId, characterId, FIRST_NOTE_ID, FollowLinkType)
        );
        // linkERC721
        nft.mint(bob);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(characterId, address(nft), 1, LikeLinkType, "")
        );
        // unlinkERC721
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(FIRST_CHARACTER_ID, address(nft), 1, LikeLinkType)
        );
        // linkAddress
        web3Entry.linkAddress(
            DataTypes.linkAddressData(characterId, address(0x1232414), LikeLinkType, "")
        );
        // unlinkAddress
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(characterId, address(0x1232414), LikeLinkType)
        );
        // linkAnyUri
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(characterId, "ipfs://anyURI", LikeLinkType, new bytes(0))
        );
        // unlinkAnyUri
        web3Entry.unlinkAnyUri(
            DataTypes.unlinkAnyUriData(characterId, "ipfs://anyURI", LikeLinkType)
        );
        // linkLinklist
        web3Entry.linkLinklist(DataTypes.linkLinklistData(characterId, 1, LikeLinkType, ""));
        // unlinkLinklist
        web3Entry.unlinkLinklist(DataTypes.unlinkLinklistData(characterId, 1, LikeLinkType));

        // setLinkModule4Character
        web3Entry.setLinkModule4Character(
            DataTypes.setLinkModule4CharacterData(
                characterId,
                address(approvalLinkModule4Character),
                ""
            )
        );

        // postNote4Character
        web3Entry.postNote4Character(makePostNoteData(characterId), FIRST_CHARACTER_ID);
        // postNote4Address
        web3Entry.postNote4Address(makePostNoteData(characterId), address(0x328));
        // postNote4Linklist
        web3Entry.postNote4Linklist(makePostNoteData(characterId), FIRST_LINKLIST_ID);
        // postNote4Note
        web3Entry.postNote4Note(
            makePostNoteData(characterId),
            DataTypes.NoteStruct(characterId, FIRST_NOTE_ID)
        );
        // postNote4ERC721
        nft.mint(bob);
        web3Entry.postNote4ERC721(
            makePostNoteData(characterId),
            DataTypes.ERC721Struct(address(nft), 1)
        );
        // postNote4AnyUri
        web3Entry.postNote4AnyUri(makePostNoteData(characterId), "ipfs://anyURI");
        vm.stopPrank();

        // case 3: owner permission
        // operator with owner permissions can:
        // alice grant bob all permissions including owner permissions
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(characterId, bob, OP.ALLOWED_PERMISSION_BITMAP_MASK);
        vm.startPrank(bob);
        web3Entry.setHandle(characterId, "mynewhandle");
        web3Entry.setSocialToken(characterId, address(0x1234567));
        web3Entry.grantOperatorPermissions(characterId, carol, OP.ALLOWED_PERMISSION_BITMAP_MASK);
        web3Entry.grantOperators4Note(characterId, FIRST_NOTE_ID, blocklist, allowlist);
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
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);
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
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);
        // lockNote
        web3Entry.lockNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        // delete note
        web3Entry.deleteNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        vm.stopPrank();

        vm.prank(alice);
        // add carol as allowlist
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, SECOND_NOTE_ID, blocklist, allowlist);

        vm.prank(carol);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, SECOND_NOTE_ID, NEW_NOTE_URI);
    }

    function testOperator4NoteFail() public {
        vm.prank(alice);
        web3Entry.postNote(makePostNoteData(FIRST_CHARACTER_ID));

        // case 1. bob's operator permission is on, but bob is in blocklist
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, allowlist);
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermissionForThisNote.selector));
        vm.prank(bob);
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);

        // case 2. bob's in blocklist and also allowlist
        vm.prank(alice);
        web3Entry.grantOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID, blocklist, blocklist);
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermissionForThisNote.selector));
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);
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
        web3Entry.setNoteUri(FIRST_CHARACTER_ID, FIRST_NOTE_ID, NEW_NOTE_URI);
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

    function _getEIP712Signature(
        uint256 privateKey,
        bytes32 hashedMessage
    ) internal returns (DataTypes.EIP712Signature memory sig) {
        bytes32 domainSeparator = web3Entry.getDomainSeparator();
        bytes32 typedDataHash = ECDSA.toTypedDataHash(domainSeparator, hashedMessage);

        sig.signer = vm.addr(privateKey);
        sig.deadline = block.timestamp + 10;
        (sig.v, sig.r, sig.s) = vm.sign(privateKey, typedDataHash);
    }
}
