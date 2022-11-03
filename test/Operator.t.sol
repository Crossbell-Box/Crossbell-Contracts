// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/libraries/DataTypes.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract OperatorTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);
    address public dick = address(0x4444);

    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testSetOperator() public {
        // add operator
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.AddOperator(Const.FIRST_CHARACTER_ID, carol, block.timestamp);
        vm.prank(alice);
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, carol);
        // carol is operator now
        assert(web3Entry.isOperator(Const.FIRST_CHARACTER_ID, carol));

        // remove operator
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.RemoveOperator(Const.FIRST_CHARACTER_ID, carol, block.timestamp);
        vm.prank(alice);
        web3Entry.removeOperator(Const.FIRST_CHARACTER_ID, carol);
        // carol is not operator now
        assert(!web3Entry.isOperator(Const.FIRST_CHARACTER_ID, carol));
    }

    function testSetOperatorFail() public {
        // only owner can add operator
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        vm.prank(bob);
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, bob);

        // only owner can remove operator
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        vm.prank(bob);
        web3Entry.removeOperator(Const.FIRST_CHARACTER_ID, bob);
    }

    function testIsOperator() public {
        vm.prank(alice);
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, bob);
        assert(web3Entry.isOperator(Const.FIRST_CHARACTER_ID, bob));
        assert(!web3Entry.isOperator(Const.FIRST_CHARACTER_ID, carol));
    }

    function testGetOperators() public {
        // getOperators returns correct values
        vm.startPrank(alice);
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, bob);
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, carol);
        address[] memory prevOperators = web3Entry.getOperators(Const.FIRST_CHARACTER_ID);
        assertEq(prevOperators[0], bob);
        assertEq(prevOperators[1], carol);
        assertEq(prevOperators.length, 2);

        // getOperators returns correct values after removeOperator
        web3Entry.removeOperator(Const.FIRST_CHARACTER_ID, bob);
        address[] memory newOperators = web3Entry.getOperators(Const.FIRST_CHARACTER_ID);
        assertEq(newOperators[0], carol);
        assertEq(newOperators.length, 1);
    }

    function testOperatorActions() public {
        vm.startPrank(alice);
        web3Entry.setOperator(Const.FIRST_CHARACTER_ID, bob);

        // link character
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        vm.stopPrank();

        vm.startPrank(bob);
        // setCharacterUri
        web3Entry.setCharacterUri(Const.FIRST_CHARACTER_ID, "https://example.com/profile");

        // link character
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // unlink character
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType
            )
        );

        // postNote4Address
        web3Entry.postNote4Address(makePostNoteData(Const.FIRST_CHARACTER_ID), address(0x1232414));

        // postNote4Linklist
        web3Entry.postNote4Linklist(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            Const.FIRST_LINKLIST_ID
        );

        // postNote
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

        // setNoteUri
        web3Entry.setNoteUri(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, Const.MOCK_NEW_NOTE_URI);

        // lockNote
        web3Entry.lockNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        // postNote4Character
        web3Entry.postNote4Character(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            Const.FIRST_CHARACTER_ID
        );

        // postNote4Address
        web3Entry.postNote4Address(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            address(0x328)
        );

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

        // linkNote
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

        vm.stopPrank();
    }

    function testOperatorActionsFail() public {
        vm.prank(alice);
        web3Entry.setOperator(Const.FIRST_CHARACTER_ID, bob);

        vm.startPrank(bob);

        // set handle
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setHandle(Const.FIRST_CHARACTER_ID, "new-handle");

        // set social token
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setSocialToken(Const.FIRST_CHARACTER_ID, address(0x132414));

        // set primary character id
        // user can only set primary character id to himself
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setPrimaryCharacterId(Const.FIRST_CHARACTER_ID);

        // set operator
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setOperator(Const.FIRST_CHARACTER_ID, address(0x444));

        // add operator
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, address(0x444));

        // remove operator
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.removeOperator(Const.FIRST_CHARACTER_ID, address(0x444));

        // create then link character
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.createThenLinkCharacter(DataTypes.createThenLinkCharacterData(Const.FIRST_CHARACTER_ID, Const.MOCK_TO_ADDRESS, Const.LinkItemTypeCharacter));

        // delete note
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.deleteNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        vm.stopPrank();
    }

    function testOperatorAfterTransfer() public {
        vm.startPrank(alice);
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, carol);
        web3Entry.addOperator(Const.FIRST_CHARACTER_ID, dick);
        vm.stopPrank();
        assert(web3Entry.isOperator(Const.FIRST_CHARACTER_ID, carol));
        assert(web3Entry.isOperator(Const.FIRST_CHARACTER_ID, dick));

        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, Const.FIRST_CHARACTER_ID);

        // operator should be reset after transfer
        assert(!web3Entry.isOperator(Const.FIRST_CHARACTER_ID, dick));
        assert(!web3Entry.isOperator(Const.FIRST_CHARACTER_ID, carol));
    }
}
