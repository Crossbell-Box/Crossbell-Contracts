// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {Test} from "forge-std/Test.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {Events} from "../../contracts/libraries/Events.sol";
import {
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote
} from "../../contracts/libraries/Error.sol";
import {Utils} from "../helpers/Utils.sol";
import {SetUp} from "../helpers/SetUp.sol";

contract LinkUriTest is Test, SetUp, Utils {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(MOCK_CHARACTER_HANDLE2, bob));
    }

    function testLinkAddress() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkAnyUri(FIRST_CHARACTER_ID, "ipfs://anyURI", FollowLinkType, 1);
        // alice link an uri
        vm.prank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                FollowLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

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
        string[] memory linkingUris = linklist.getLinkingAnyUris(1);
        assertEq(linkingUris.length, 1);
        assertEq(linkingUris[0], "ipfs://anyURI");
        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", "ipfs://anyURI"));
        string memory linkingUri = linklist.getLinkingAnyUri(linkKey);
        assertEq(linkingUri, "ipfs://anyURI");
        bytes32[] memory linkingUriKeys = linklist.getLinkingAnyUriKeys(1);
        assertEq(linkingUriKeys.length, 1);
        assertEq(linkingUriKeys[0], linkKey);
    }

    function testLinkUriFail() public {
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

    function testUnlinkUri() public {
        nft.mint(bob);
        vm.startPrank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.UnlinkAnyUri(FIRST_CHARACTER_ID, "ipfs://anyURI", FollowLinkType);
        web3Entry.unlinkAnyUri(
            DataTypes.unlinkAnyUriData(FIRST_CHARACTER_ID, "ipfs://anyURI", FollowLinkType)
        );

        // unlink twice
        web3Entry.unlinkAnyUri(
            DataTypes.unlinkAnyUriData(FIRST_CHARACTER_ID, "ipfs://anyURI", FollowLinkType)
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        string[] memory linkingUris = linklist.getLinkingAnyUris(1);
        assertEq(linkingUris.length, 0);
        // bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", "ipfs://anyURI"));
        // string memory linkingUri = linklist.getLinkingAnyUri(linkKey);
        // assertEq(linkingUri, "");
        bytes32[] memory linkingUriKeys = linklist.getLinkingAnyUriKeys(1);
        assertEq(linkingUriKeys.length, 0);
    }

    function testUnlinkAddressFail() public {
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
