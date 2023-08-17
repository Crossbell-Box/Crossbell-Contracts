// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {Events} from "../../contracts/libraries/Events.sol";
import {
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote
} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract LinkUriTest is CommonTest {
    string public constant uri = "ipfs://anyURI";

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create a character for alice
        _createCharacter(CHARACTER_HANDLE, alice);
    }

    function testLinkAnyUri() public {
        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", uri));

        expectEmit(CheckAll);
        emit Events.LinkAnyUri(FIRST_CHARACTER_ID, uri, FollowLinkType, 1);
        // alice links an uri
        vm.prank(alice);
        web3Entry.linkAnyUri(_makeLinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));

        // check linklist
        assertEq(web3Entry.getLinklistId(FIRST_CHARACTER_ID, FollowLinkType), 1);

        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.getLinkingAnyListLength(1), 1);
        assertEq(linklist.getLinkingAnyUriKeys(1)[0], linkKey);
        assertEq(linklist.getLinkingAnyUri(linkKey), uri);
        assertEq(linklist.getLinkingAnyUris(1)[0], uri);
        // check link type
        assertEq(web3Entry.getLinklistType(1), FollowLinkType);
    }

    function testLinkAnyUriByPeriphery() public {
        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", uri));

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkAnyUri(_makeLinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));

        // check linklist
        assertEq(web3Entry.getLinklistId(FIRST_CHARACTER_ID, FollowLinkType), 1);
        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.getLinkingAnyListLength(1), 1);
        assertEq(linklist.getLinkingAnyUriKeys(1)[0], linkKey);
        assertEq(linklist.getLinkingAnyUri(linkKey), uri);
        assertEq(linklist.getLinkingAnyUris(1)[0], uri);
        // check link type
        assertEq(web3Entry.getLinklistType(1), FollowLinkType);
    }

    function testLinkAnyUriLinkTwice() public {
        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", uri));

        vm.startPrank(alice);
        // link
        web3Entry.linkAnyUri(_makeLinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));
        // link twice
        web3Entry.linkAnyUri(_makeLinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));
        vm.stopPrank();

        // check linklist
        assertEq(web3Entry.getLinklistId(FIRST_CHARACTER_ID, FollowLinkType), 1);
        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.getLinkingAnyListLength(1), 1);
        assertEq(linklist.getLinkingAnyUriKeys(1)[0], linkKey);
        assertEq(linklist.getLinkingAnyUri(linkKey), uri);
        assertEq(linklist.getLinkingAnyUris(1)[0], uri);
        // check link type
        assertEq(web3Entry.getLinklistType(1), FollowLinkType);
    }

    function testLinkAnyUriFail() public {
        //  NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.linkAnyUri(_makeLinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));
    }

    function testUnlinkAnyUri() public {
        vm.startPrank(alice);
        web3Entry.linkAnyUri(_makeLinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));

        // unlink
        expectEmit(CheckAll);
        emit Events.UnlinkAnyUri(FIRST_CHARACTER_ID, uri, FollowLinkType);
        web3Entry.unlinkAnyUri(DataTypes.unlinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));
        vm.stopPrank();

        // check state
        assertEq(web3Entry.getLinklistId(FIRST_CHARACTER_ID, FollowLinkType), 1);
        assertEq(linklist.ownerOf(1), alice);
        // no links
        assertEq(linklist.getLinkingAnyListLength(1), 0);
        assertEq(linklist.getLinkingAnyUris(1).length, 0);
        assertEq(linklist.getLinkingAnyUriKeys(1).length, 0);
    }

    function testUnlinkAnyUriTwice() public {
        vm.startPrank(alice);
        web3Entry.linkAnyUri(_makeLinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));

        // unlink
        web3Entry.unlinkAnyUri(DataTypes.unlinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));
        // unlink twice
        web3Entry.unlinkAnyUri(DataTypes.unlinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));
        vm.stopPrank();

        // check state
        assertEq(web3Entry.getLinklistId(FIRST_CHARACTER_ID, FollowLinkType), 1);
        assertEq(linklist.ownerOf(1), alice);
        // no links
        assertEq(linklist.getLinkingAnyListLength(1), 0);
        assertEq(linklist.getLinkingAnyUris(1).length, 0);
        assertEq(linklist.getLinkingAnyUriKeys(1).length, 0);
    }

    function testUnlinkAnyUriFail() public {
        vm.prank(alice);
        web3Entry.linkAnyUri(_makeLinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));

        // unlink
        // NotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkAnyUri(DataTypes.unlinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));
    }

    function _makeLinkAnyUriData(
        uint256 fromCharacterId,
        string memory toUri,
        bytes32 linkType
    ) internal pure returns (DataTypes.linkAnyUriData memory) {
        return DataTypes.linkAnyUriData(fromCharacterId, toUri, linkType, "");
    }
}
