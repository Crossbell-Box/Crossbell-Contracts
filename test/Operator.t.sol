// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/Web3Entry.sol";
import "../src/libraries/DataTypes.sol";
import "../src/Web3Entry.sol";
import "../src/upgradeability/TransparentUpgradeableProxy.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";

contract OperatorTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);

    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testSetOperator() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.SetOperator(Const.FIRST_CHARACTER_ID, bob, block.timestamp);
        vm.prank(alice);
        web3Entry.setOperator(Const.FIRST_CHARACTER_ID, bob);
    }

    function testSetOperatorFail() public {
        // bob can't set operator for alice
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        vm.prank(bob);
        web3Entry.setOperator(Const.FIRST_CHARACTER_ID, bob);
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
        // setProfileUri
        web3Entry.setProfileUri(Const.FIRST_CHARACTER_ID, "https://example.com/profile");

        // postNote4Address
        web3Entry.postNote4Address(makePostNoteData(Const.FIRST_CHARACTER_ID), address(0x1232414));

        // postNote4Linklist
        web3Entry.postNote4Linklist(
            makePostNoteData(Const.FIRST_CHARACTER_ID),
            Const.FIRST_LINKLIST_ID
        );

        // postNote
        web3Entry.postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));

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
        // vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        // web3Entry.setPrimaryCharacterId(Const.SECOND_CHARACTER_ID);

        // set operator
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.setOperator(Const.FIRST_CHARACTER_ID, address(0x444));

        // link character
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // unlink character
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType
            )
        );

        // linkERC721
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
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
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType
            )
        );

        // linkAddress
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // unlinkAddress
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.LikeLinkType
            )
        );

        // linkAnyUri
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // unlinkAnyUri
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.unlinkAnyUri(
            DataTypes.unlinkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.LikeLinkType
            )
        );

        // linkLinklist
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                Const.FIRST_CHARACTER_ID,
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
        // unlinkLinklist
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.unlinkLinklist(
            DataTypes.unlinkLinklistData(Const.FIRST_CHARACTER_ID, 1, Const.LikeLinkType)
        );
        vm.stopPrank();
    }
}
