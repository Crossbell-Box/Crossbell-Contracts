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
        // alice set bob as her operator with DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
    }

    function testGrantNoteOpertorPermissionsFail() public {
        // only only owner can grant operator
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
    }

    function testGrantNoteOpertorPermission() public {
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            bob,
            OP.DEFAULT_NOTE_PERMISSION_BITMAP
        );
    }

    function testcheckPermissionByPermissionId() public {
        // alice grant bob DEFAULT_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        bool permission = web3Entry.checkPermissionByPermissionId(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.SET_HANDLE
        );
        assert(!permission);

        // check [0, 20] is set to false, which means `default` doesn't hava owner permission
        for (uint256 i = 0; i < 20; i++) {
            assert(!web3Entry.checkPermissionByPermissionId(Const.FIRST_CHARACTER_ID, bob, i));
        }

        // check [21, 255] is set to true
        for (uint256 i = 20; i < 256; i++) {
            assert(web3Entry.checkPermissionByPermissionId(Const.FIRST_CHARACTER_ID, bob, i));
        }

        // alice grant bob OPERATORSIGN_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATORSIGN_PERMISSION_BITMAP
        );

        // check [0, 174] is set to false, which means `operator-sign` doesn't have owner permission or future permission
        for (uint256 i = 0; i < 176; i++) {
            assert(!web3Entry.checkPermissionByPermissionId(Const.FIRST_CHARACTER_ID, bob, i));
        }

        // check [175, 255] is set to true, which means `operator-sign` has both operator-sign and operator-sync permission
        for (uint256 i = 176; i < 256; i++) {
            assert(web3Entry.checkPermissionByPermissionId(Const.FIRST_CHARACTER_ID, bob, i));
        }

        // alice grant bob OPERATORSYNC_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATORSYNC_PERMISSION_BITMAP
        );

        // check [0, 174] is set to false, which means `operator-sign` doesn't have owner permission or future permission
        for (uint256 i = 0; i < 236; i++) {
            assert(!web3Entry.checkPermissionByPermissionId(Const.FIRST_CHARACTER_ID, bob, i));
        }

        // check [175, 255] is set to true, which means `operator-sign` has both operator-sign and operator-sync permission
        for (uint256 i = 236; i < 256; i++) {
            assert(web3Entry.checkPermissionByPermissionId(Const.FIRST_CHARACTER_ID, bob, i));
        }
    }

    function testOperatorSyncCan() public {
        // alice grant bob as OPERATORSYNC_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATORSYNC_PERMISSION_BITMAP
        );

        vm.startPrank(bob);
        // operatorSync can post note(id = 236)
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
    }

    function testOperatorSignCan() public {
        // alice grant bob as OPERATORSIGN_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATORSIGN_PERMISSION_BITMAP
        );

        vm.startPrank(bob);
        // operatorSign can postNote(id = 236)
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // operatorSign can setCharacterUri(id = 176)
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, "https://example.com/profile");
        // TODO setlinklisturi
        // operatorSign can linkCharacter(id = 176)
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
        web3Entry.setLinkModule4Character(
            DataTypes.setLinkModule4CharacterData(
                Const.FIRST_CHARACTER_ID,
                address(linkModule4Character),
                new bytes(0)
            )
        );

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
    }

    function testOperatorFail() public {
        // alice set bob as her operator with DEFAULT_PERMISSION_BITMAP
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // default operator can't setHandle
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, "new-handle");

        // set primary character id
        // user can only set primary character id to himself
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setPrimaryCharacterId(Const.FIRST_CHARACTER_ID);

        // add operator
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, address(0x444));

        // remove operator
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.removeOperator(Const.FIRST_CHARACTER_ID, address(0x444));

        // set social token
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(0x132414));

        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
    }

    function testOperator4NoteCan() public {
        // alice grant bob as OPERATORSIGN_PERMISSION_BITMAP permission
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        ApprovalLinkModule4Note linkModule4Note = new ApprovalLinkModule4Note(address(web3Entry));

        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATORSIGN_PERMISSION_BITMAP
        );
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            bob,
            OP.DEFAULT_NOTE_PERMISSION_BITMAP
        );
        vm.stopPrank();

        // setLinkModule4Note
        vm.startPrank(bob);
        web3Entry.setLinkModule4Note(
            DataTypes.setLinkModule4NoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                address(linkModule4Note),
                new bytes(0)
            )
        );

        // TODO SET_MINT_MODULE_FOR_NOTE

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
    }

    function testOperator4NoteFail() public {
        // alice grant bob as OPERATORSIGN_PERMISSION_BITMAP permission
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        ApprovalLinkModule4Note linkModule4Note = new ApprovalLinkModule4Note(address(web3Entry));

        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.OPERATORSIGN_PERMISSION_BITMAP
        );
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            bob,
            OP.DEFAULT_NOTE_PERMISSION_BITMAP
        );

        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID, 
            Const.FIRST_NOTE_ID, 
            carol, 
            OP.DEFAULT_NOTE_PERMISSION_BITMAP
        );
        vm.stopPrank();

        // operator can't operate note without grant
        // operate note 2
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NotEnoughPerssionForThisNote"));
        // setNoteUri
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );

        // granted operator can't operator without note permission
        vm.prank(carol);
        vm.expectRevert(abi.encodePacked("NotEnoughPerssion"));
        // setNoteUri
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );

        // can't deleteNote if the permission is set as false
        vm.prank(alice);
        web3Entry.grantOperatorPermissions4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            bob,
            ~(~uint256(0) << 4)
        );
        
        vm.expectRevert(abi.encodePacked("NotEnoughPerssionForThisNote"));
        vm.prank(bob);
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);
    }
}
