// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";
import "../contracts/libraries/OP.sol";
import "../contracts/misc/NewbieVilla.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/libraries/DataTypes.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "../contracts/modules/link/ApprovalLinkModule4Character.sol";
import "../contracts/modules/link/ApprovalLinkModule4Note.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract OperatorTest is Test, SetUp, Utils {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    address public xsyncOperator = address(0x6666);

    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);
    address public dick = address(0x4444);
    address public erik = address(0x5555);

    address[] public blacklist = [bob];
    address[] public whitelist = [carol, dick];

    NewbieVilla public newbieVilla;
    address public migrateOwner = 0xda2423ceA4f1047556e7a142F81a7ED50e93e160;

    function setUp() public {
        _setUp();

        // setup newbieVilla
        newbieVilla = new NewbieVilla();
        newbieVilla.initialize(address(web3Entry), xsyncOperator);
        // grant mint role
        newbieVilla.grantRole(ADMIN_ROLE, alice);
        newbieVilla.grantRole(ADMIN_ROLE, bob);

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
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // grant operator sync permission
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.POST_NOTE_PERMISSION_BITMAP
        );

        // test bitmap is correctly filtered
        web3Entry.grantOperatorPermissions(Const.FIRST_CHARACTER_ID, bob, UINT256_MAX);
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.ALLOWED_PERMISSION_BITMAP_MASK
        );
        vm.stopPrank();
    }

    function testGrantOperatorPermissionsFail() public {
        // bob is not the owner of FIRST_CHARACTER_ID, he can't grant
        vm.prank(bob);
        vm.expectRevert("NotEnoughPermission");
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
    }

    function testAddOperators4Note() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.AddOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        address[] memory _blacklist;
        address[] memory _whitelist;

        (_blacklist, _whitelist) = web3Entry.getOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );

        assertEq(_blacklist, blacklist);
        assertEq(_whitelist, whitelist);
    }

    function testAddOperators4NoteFail() public {
        // bob is not owner of FIRST_CHARACTER_ID, can't grant
        vm.prank(bob);
        vm.expectRevert("NotEnoughPermission");
        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        // note doesn't exist
        vm.prank(alice);
        vm.expectRevert("NoteNotExists");
        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            blacklist,
            whitelist
        );
    }

    function removeOperators4Note() public {
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.RemoveOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        web3Entry.removeOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        address[] memory _blacklist;
        address[] memory _whitelist;

        (_blacklist, _whitelist) = web3Entry.getOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );

        assertEq(_blacklist.length, 0);
        assertEq(_whitelist.length, 0);
    }

    function testRemoveOperators4NoteFail() public {
        // bob is not owner of FIRST_CHARACTER_ID, can't grant
        vm.prank(bob);
        vm.expectRevert("NotEnoughPermission");
        web3Entry.removeOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        // note doesn't exist
        vm.prank(alice);
        vm.expectRevert("NoteNotExists");
        web3Entry.removeOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
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

        // alice grant bob OP.POST_NOTE_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, bob),
            OP.POST_NOTE_PERMISSION_BITMAP
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

        // then put bob into blacklist of note 1
        vm.prank(alice);
        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
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

        // case 2. put carol into whitelist, then disable carol's operator permission
        vm.prank(alice);
        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            blacklist,
            whitelist
        );

        // now carol is in whitelist for note 2
        vm.prank(carol);
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );

        // then disable carol's operator permissions
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_CHARACTER_ID, carol, 0);
        // but carol can still edit note 2(cuz note validation goes first)
        vm.prank(carol);
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
    }

    function testOperatorCan() public {
        // alice grant bob as OP.POST_NOTE_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_PERMISSION_BITMAP
        );

        vm.prank(bob);
        // operatorSync can post note(id = 236)
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // alice grant bob as OP.DEFAULT_PERMISSION_BITMAP permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        vm.startPrank(bob);
        // bob can postNote
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        // bob can setCharacterUri
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, "https://example.com/profile");
        // bob can linkCharacter
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
        // bob can setlinklisturi
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
        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );
        web3Entry.removeOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );
        vm.stopPrank();
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

        // can't add operator for note
        vm.expectRevert(abi.encodePacked("NotEnoughPermission"));
        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        // can't remove operator for note
        vm.expectRevert(abi.encodePacked("NotEnoughPermission"));
        web3Entry.removeOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );
        vm.stopPrank();

        // fail after canceling grant
        vm.startPrank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_PERMISSION_BITMAP
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
            OP.POST_NOTE_PERMISSION_BITMAP
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
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        vm.stopPrank();

        vm.startPrank(bob);
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

        vm.prank(alice);
        // add carol as whitelist
        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            blacklist,
            whitelist
        );

        vm.prank(carol);
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
    }

    function testOperator4NoteFail() public {
        // case 1. bob's operator permission is on, but bob is in blacklist
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );
        vm.stopPrank();

        vm.prank(bob);
        vm.expectRevert("NotEnoughPermissionForThisNote");
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
        vm.stopPrank();

        // case 2. bob's in blacklist and also whitelist
        vm.prank(alice);
        // i just switch whitelist and blacklist here for convenience
        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            whitelist,
            blacklist
        );
        vm.prank(bob);
        vm.expectRevert("NotEnoughPermissionForThisNote");
        web3Entry.setNoteUri(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            Const.MOCK_NEW_NOTE_URI
        );
    }

    function testMigrate() public {
        // alice sets carol as operator
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(Const.FIRST_CHARACTER_ID, carol, UINT256_MAX);

        // bob transfers character to newbieVilla
        vm.prank(bob);
        Web3Entry(address(web3Entry)).safeTransferFrom(
            address(bob),
            address(newbieVilla),
            Const.SECOND_CHARACTER_ID
        );

        // migrate
        uint256[] memory characterIds = new uint256[](2);
        characterIds[0] = Const.FIRST_CHARACTER_ID;
        characterIds[1] = Const.SECOND_CHARACTER_ID;
        vm.prank(migrateOwner);
        web3Entry.migrateOperator(address(newbieVilla), characterIds);

        // check Operator permission
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, carol),
            OP.POST_NOTE_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.SECOND_CHARACTER_ID, bob),
            OP.DEFAULT_PERMISSION_BITMAP
        );
    }

    function testGetOperators() public {
        address[4] memory accounts = [bob, carol, dick, erik];

        vm.startPrank(alice);
        for (uint256 i = 0; i < accounts.length; i++) {
            web3Entry.grantOperatorPermissions(
                Const.FIRST_CHARACTER_ID,
                accounts[i],
                OP.DEFAULT_PERMISSION_BITMAP
            );
        }
        _checkOperators(Const.FIRST_CHARACTER_ID, accounts, OP.DEFAULT_PERMISSION_BITMAP);

        // remove all operators
        for (uint256 i = 0; i < accounts.length; i++) {
            web3Entry.grantOperatorPermissions(Const.FIRST_CHARACTER_ID, accounts[i], 0);
        }
        address[] memory operators = web3Entry.getOperators(Const.FIRST_CHARACTER_ID);
        assertEq(operators.length, 0);

        vm.stopPrank();
    }

    function testGetOperators4Note() public {
        // alice grant bob OP.DEFAULT_PERMISSION_BITMAP permission
        vm.startPrank(alice);
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        web3Entry.addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        address[] memory _blacklist;
        address[] memory _whitelist;

        (_blacklist, _whitelist) = web3Entry.getOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );

        assertEq(_blacklist, blacklist);
        assertEq(_whitelist, whitelist);
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

    function testValidateCallerPermission() public {
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

    function testValidateCallerPermissionFail() public {
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.POST_NOTE_PERMISSION_BITMAP
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
