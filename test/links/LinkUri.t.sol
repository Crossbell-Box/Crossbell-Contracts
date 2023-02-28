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

contract LinkUriTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testLinkAddress() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkAnyUri(Const.FIRST_CHARACTER_ID, "ipfs://anyURI", Const.FollowLinkType, 1);
        // alice link an uri
        vm.prank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // link twice
        vm.prank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType,
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
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType,
                new bytes(0)
            )
        );
    }

    function testUnlinkUri() public {
        vm.prank(address(web3Entry));
        nft.mint(bob);
        vm.startPrank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.UnlinkAnyUri(Const.FIRST_CHARACTER_ID, "ipfs://anyURI", Const.FollowLinkType);
        web3Entry.unlinkAnyUri(
            DataTypes.unlinkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType
            )
        );

        // unlink twice
        web3Entry.unlinkAnyUri(
            DataTypes.unlinkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType
            )
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
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkAnyUri(
            DataTypes.unlinkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType
            )
        );
    }
}
