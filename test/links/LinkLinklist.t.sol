// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/Web3Entry.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../../contracts/libraries/Error.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract LinkLinklistTest is Test, SetUp, Utils {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));

        vm.prank(address(web3Entry));
        linklist.mint(Const.FIRST_CHARACTER_ID, Const.FollowLinkType);
    }

    function testLinkLinklist() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkLinklist(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_LINKLIST_ID,
            Const.FollowLinkType,
            Const.SECOND_LINKLIST_ID
        );
        vm.startPrank(alice);
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_LINKLIST_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // link twice
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_LINKLIST_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        vm.stopPrank();

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_LINKLIST_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // check state
        uint256[] memory linkingLinkListIds = linklist.getLinkingLinklistIds(
            Const.SECOND_LINKLIST_ID
        );
        assertEq(linkingLinkListIds.length, 1);
        assertEq(linkingLinkListIds[0], 1);
        assertEq(linklist.getLinkingLinklistLength(Const.SECOND_LINKLIST_ID), 1);
    }

    function testLinkLinklistFail() public {
        // case 1: NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_LINKLIST_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
    }

    function testUnlinkLinklist() public {
        vm.startPrank(alice);
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_LINKLIST_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.UnlinkLinklist(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_LINKLIST_ID,
            Const.FollowLinkType,
            Const.SECOND_LINKLIST_ID
        );
        web3Entry.unlinkLinklist(
            DataTypes.unlinkLinklistData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_LINKLIST_ID,
                Const.FollowLinkType
            )
        );

        // unlink twice
        web3Entry.unlinkLinklist(
            DataTypes.unlinkLinklistData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_LINKLIST_ID,
                Const.FollowLinkType
            )
        );

       // unlink a non-existing character
        web3Entry.unlinkLinklist(
            DataTypes.unlinkLinklistData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_LINKLIST_ID,
                Const.FollowLinkType
            )
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        uint256[] memory linkingLinkListIds = linklist.getLinkingLinklistIds(
            Const.SECOND_LINKLIST_ID
        );
        assertEq(linkingLinkListIds.length, 0);
        assertEq(linklist.getLinkingLinklistLength(Const.SECOND_LINKLIST_ID), 0);
    }

    function testUnlinkLinklistFail() public {
        vm.prank(alice);
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_LINKLIST_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkLinklist(
            DataTypes.unlinkLinklistData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_LINKLIST_ID,
                Const.FollowLinkType
            )
        );
    }
}
