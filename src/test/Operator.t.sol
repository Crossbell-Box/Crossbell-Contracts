// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../Web3Entry.sol";
import "../libraries/DataTypes.sol";
import "../Web3Entry.sol";
import "../upgradeability/TransparentUpgradeableProxy.sol";
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

        vm.stopPrank();
    }

    function testOperatorActionsFail() public {}
}
