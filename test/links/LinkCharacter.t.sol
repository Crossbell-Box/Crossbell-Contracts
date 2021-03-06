// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../src/Web3Entry.sol";
import "../../src/libraries/DataTypes.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract LinkProfileTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testLinkCharacter() public {
        vm.startPrank(alice);
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkCharacter(
            alice,
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CHARACTER_ID,
            Const.FollowLinkType,
            1
        );
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // link twice
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        vm.stopPrank();
    }

    function testLinkCharacterFail() public {
        // NotCharacterOwner
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // CharacterNotExists
        vm.prank(alice);
        vm.expectRevert(abi.encodePacked("CharacterNotExists"));
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                3,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // link a burned character
        vm.prank(bob);
        web3Entry.burn(Const.SECOND_CHARACTER_ID);
        vm.expectRevert(abi.encodePacked("CharacterNotExists"));
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
    }

    function testUnlinkCharacter() public {
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.UnlinkCharacter(
            alice,
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CHARACTER_ID,
            Const.FollowLinkType
        );
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType
            )
        );

        // unlink twice
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType
            )
        );

        // unlink a non-existing character
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(Const.FIRST_CHARACTER_ID, 99999, Const.FollowLinkType)
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);
    }

    function testUnlinkCharacterFail() public {
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        vm.prank(bob);
        web3Entry.unlinkCharacter(
            DataTypes.unlinkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType
            )
        );
    }

    function testCreateThenLinkCharacter() public {
        vm.prank(alice);
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkCharacter(alice, Const.FIRST_CHARACTER_ID, 3, Const.FollowLinkType, 1);
        web3Entry.createThenLinkCharacter(
            DataTypes.createThenLinkCharacterData(
                Const.FIRST_CHARACTER_ID,
                address(0x56789),
                Const.FollowLinkType
            )
        );
    }
}
