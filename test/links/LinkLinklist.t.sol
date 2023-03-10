// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {Test} from "forge-std/Test.sol";
import {Web3Entry} from "../../contracts/Web3Entry.sol";
import {Events} from "../../contracts/libraries/Events.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote
} from "../../contracts/libraries/Error.sol";
import {Utils} from "../helpers/Utils.sol";
import {SetUp} from "../helpers/SetUp.sol";

contract LinkLinklistTest is Test, SetUp, Utils {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(MOCK_CHARACTER_HANDLE2, bob));

        vm.prank(address(web3Entry));
        linklist.mint(FIRST_CHARACTER_ID, FollowLinkType);
    }

    function testLinkLinklist() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkLinklist(
            FIRST_CHARACTER_ID,
            FIRST_LINKLIST_ID,
            FollowLinkType,
            SECOND_LINKLIST_ID
        );
        vm.startPrank(alice);
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                FIRST_CHARACTER_ID,
                FIRST_LINKLIST_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // link twice
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                FIRST_CHARACTER_ID,
                FIRST_LINKLIST_ID,
                FollowLinkType,
                new bytes(0)
            )
        );
        vm.stopPrank();

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                FIRST_CHARACTER_ID,
                FIRST_LINKLIST_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // check state
        uint256[] memory linkingLinkListIds = linklist.getLinkingLinklistIds(SECOND_LINKLIST_ID);
        assertEq(linkingLinkListIds.length, 1);
        assertEq(linkingLinkListIds[0], 1);
        assertEq(linklist.getLinkingLinklistLength(SECOND_LINKLIST_ID), 1);
    }

    function testLinkLinklistFail() public {
        // case 1: NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                FIRST_CHARACTER_ID,
                FIRST_LINKLIST_ID,
                FollowLinkType,
                new bytes(0)
            )
        );
    }

    // solhint-disable-next-line function-max-lines
    function testUnlinkLinklist() public {
        vm.startPrank(alice);
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                FIRST_CHARACTER_ID,
                FIRST_LINKLIST_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.UnlinkLinklist(
            FIRST_CHARACTER_ID,
            FIRST_LINKLIST_ID,
            FollowLinkType,
            SECOND_LINKLIST_ID
        );
        web3Entry.unlinkLinklist(
            DataTypes.unlinkLinklistData(FIRST_CHARACTER_ID, FIRST_LINKLIST_ID, FollowLinkType)
        );

        // unlink twice
        web3Entry.unlinkLinklist(
            DataTypes.unlinkLinklistData(FIRST_CHARACTER_ID, FIRST_LINKLIST_ID, FollowLinkType)
        );

        // unlink a non-existing character
        web3Entry.unlinkLinklist(
            DataTypes.unlinkLinklistData(FIRST_CHARACTER_ID, SECOND_LINKLIST_ID, FollowLinkType)
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        uint256[] memory linkingLinkListIds = linklist.getLinkingLinklistIds(SECOND_LINKLIST_ID);
        assertEq(linkingLinkListIds.length, 0);
        assertEq(linklist.getLinkingLinklistLength(SECOND_LINKLIST_ID), 0);
    }

    function testUnlinkLinklistFail() public {
        vm.prank(alice);
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                FIRST_CHARACTER_ID,
                FIRST_LINKLIST_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkLinklist(
            DataTypes.unlinkLinklistData(FIRST_CHARACTER_ID, FIRST_LINKLIST_ID, FollowLinkType)
        );
    }
}
