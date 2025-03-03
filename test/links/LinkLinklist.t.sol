// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Events} from "../../contracts/libraries/Events.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {ErrNotEnoughPermission} from "../../contracts/libraries/Error.sol";
import {OP} from "../../contracts/libraries/OP.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract LinkLinklistTest is CommonTest {
    uint256 public firstCharacter;
    uint256 public secondCharacter;

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        firstCharacter = _createCharacter(CHARACTER_HANDLE, alice);
        secondCharacter = _createCharacter(CHARACTER_HANDLE2, bob);

        vm.prank(address(web3Entry));
        linklist.mint(firstCharacter, FollowLinkType);
    }

    function testLinkLinklist() public {
        expectEmit(CheckAll);
        emit Events.LinkLinklist(firstCharacter, 1, FollowLinkType, 2);
        vm.startPrank(alice);
        web3Entry.linkLinklist(DataTypes.linkLinklistData(firstCharacter, 1, FollowLinkType, ""));

        // link twice
        web3Entry.linkLinklist(DataTypes.linkLinklistData(firstCharacter, 1, FollowLinkType, ""));
        vm.stopPrank();

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkLinklist(DataTypes.linkLinklistData(firstCharacter, 1, FollowLinkType, ""));

        // check state
        uint256[] memory linkingLinkListIds = linklist.getLinkingLinklistIds(SECOND_LINKLIST_ID);
        assertEq(linkingLinkListIds.length, 1);
        assertEq(linkingLinkListIds[0], 1);
        assertEq(linklist.getLinkingLinklistLength(SECOND_LINKLIST_ID), 1);
    }

    function testLinkLinklistWithOperator() public {
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.LINK_LINKLIST);

        expectEmit(CheckAll);
        emit Events.LinkLinklist(firstCharacter, 1, FollowLinkType, 2);
        vm.startPrank(alice);
        web3Entry.linkLinklist(DataTypes.linkLinklistData(firstCharacter, 1, FollowLinkType, ""));

        // check state
        uint256[] memory linkingLinkListIds = linklist.getLinkingLinklistIds(2);
        assertEq(linkingLinkListIds.length, 1);
        assertEq(linkingLinkListIds[0], 1);
        assertEq(linklist.getLinkingLinklistLength(2), 1);
    }

    function testLinkLinklistFail() public {
        // case 1: NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkLinklist(DataTypes.linkLinklistData(firstCharacter, 1, FollowLinkType, ""));
    }

    function testLinkLinklistFailWithOperator() public {
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, UINT256_MAX ^ (1 << OP.LINK_LINKLIST));

        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.linkLinklist(DataTypes.linkLinklistData(firstCharacter, 1, FollowLinkType, ""));
    }

    function testUnlinkLinklist() public {
        vm.startPrank(alice);
        web3Entry.linkLinklist(DataTypes.linkLinklistData(firstCharacter, 1, FollowLinkType, ""));

        // unlink
        expectEmit(CheckAll);
        emit Events.UnlinkLinklist(firstCharacter, 1, FollowLinkType, 2);
        web3Entry.unlinkLinklist(DataTypes.unlinkLinklistData(firstCharacter, 1, FollowLinkType));

        // unlink twice
        web3Entry.unlinkLinklist(DataTypes.unlinkLinklistData(firstCharacter, 1, FollowLinkType));

        // unlink a non-existing character
        web3Entry.unlinkLinklist(DataTypes.unlinkLinklistData(firstCharacter, 2, FollowLinkType));
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        uint256[] memory linkingLinkListIds = linklist.getLinkingLinklistIds(2);
        assertEq(linkingLinkListIds.length, 0);
        assertEq(linklist.getLinkingLinklistLength(2), 0);
    }

    function testUnlinkLinklistWithOperator() public {
        vm.startPrank(alice);
        web3Entry.linkLinklist(DataTypes.linkLinklistData(firstCharacter, 1, FollowLinkType, ""));
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.UNLINK_LINKLIST);
        vm.stopPrank();

        // unlink
        expectEmit(CheckAll);
        emit Events.UnlinkLinklist(firstCharacter, 1, FollowLinkType, 2);
        vm.prank(bob);
        web3Entry.unlinkLinklist(DataTypes.unlinkLinklistData(firstCharacter, 1, FollowLinkType));

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        uint256[] memory linkingLinkListIds = linklist.getLinkingLinklistIds(2);
        assertEq(linkingLinkListIds.length, 0);
        assertEq(linklist.getLinkingLinklistLength(2), 0);
    }

    function testUnlinkLinklistFail() public {
        vm.prank(alice);
        web3Entry.linkLinklist(DataTypes.linkLinklistData(firstCharacter, 1, FollowLinkType, ""));

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkLinklist(DataTypes.unlinkLinklistData(firstCharacter, 1, FollowLinkType));
    }

    function testUnlinkLinklistFailWithOperator() public {
        vm.prank(alice);
        web3Entry.linkLinklist(DataTypes.linkLinklistData(firstCharacter, 1, FollowLinkType, ""));

        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, UINT256_MAX ^ (1 << OP.UNLINK_LINKLIST));

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkLinklist(DataTypes.unlinkLinklistData(firstCharacter, 1, FollowLinkType));
    }
}
