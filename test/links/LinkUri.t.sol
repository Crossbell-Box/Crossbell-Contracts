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
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testLinkAnyUri() public {
        string memory uri = "ipfs://anyURI";
        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", uri));

        expectEmit(CheckAll);
        emit Events.LinkAnyUri(FIRST_CHARACTER_ID, uri, FollowLinkType, 1);
        // alice link an uri
        vm.prank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType, new bytes(0))
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.getLinkingAnyListLength(1), 1);
        assertEq(linklist.getLinkingAnyUriKeys(1)[0], linkKey);
        assertEq(linklist.getLinkingAnyUri(linkKey), uri);

        // link twice
        vm.prank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                FollowLinkType,
                new bytes(0)
            )
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                FollowLinkType,
                new bytes(0)
            )
        );

        // check state
        assertEq(linklist.getLinkingAnyListLength(1), 1);
        string[] memory linkingUris = linklist.getLinkingAnyUris(1);
        assertEq(linkingUris.length, 1);
        assertEq(linkingUris[0], uri);
        string memory linkingUri = linklist.getLinkingAnyUri(linkKey);
        assertEq(linkingUri, uri);
        bytes32[] memory linkingUriKeys = linklist.getLinkingAnyUriKeys(1);
        assertEq(linkingUriKeys.length, 1);
        assertEq(linkingUriKeys[0], linkKey);
    }

    function testLinkAnyUriFail() public {
        // case 1: NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                FollowLinkType,
                new bytes(0)
            )
        );
    }

    function testUnlinkAnyUri() public {
        string memory uri = "ipfs://anyURI";

        vm.startPrank(alice);
        web3Entry.linkAnyUri(DataTypes.linkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType, ""));

        // unlink
        expectEmit(CheckAll);
        emit Events.UnlinkAnyUri(FIRST_CHARACTER_ID, uri, FollowLinkType);
        web3Entry.unlinkAnyUri(DataTypes.unlinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));

        // unlink twice
        web3Entry.unlinkAnyUri(DataTypes.unlinkAnyUriData(FIRST_CHARACTER_ID, uri, FollowLinkType));
        vm.stopPrank();

        // check state
        assertEq(linklist.getLinkingAnyListLength(1), 0);
        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.getLinkingAnyListLength(1), 0);
        string[] memory uris = linklist.getLinkingAnyUris(1);
        assertEq(uris.length, 0);
        bytes32[] memory keys = linklist.getLinkingAnyUriKeys(1);
        assertEq(keys.length, 0);
    }

    function testUnlinkAnyUriFail() public {
        vm.prank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkAnyUri(
            DataTypes.unlinkAnyUriData(FIRST_CHARACTER_ID, "ipfs://anyURI", FollowLinkType)
        );
    }
}
