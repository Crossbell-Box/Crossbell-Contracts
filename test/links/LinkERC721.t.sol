// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Events} from "../../contracts/libraries/Events.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote,
    ErrCharacterNotExists,
    ErrHandleExists
} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract LinkERC721Test is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    // solhint-disable-next-line function-max-lines
    function testLinkERC721() public {
        nft.mint(bob);
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.LinkERC721(FIRST_CHARACTER_ID, address(nft), 1, LikeLinkType, 1);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                FIRST_CHARACTER_ID,
                address(nft),
                1,
                LikeLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // link twice
        vm.prank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                FIRST_CHARACTER_ID,
                address(nft),
                1,
                LikeLinkType,
                new bytes(0)
            )
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                FIRST_CHARACTER_ID,
                address(nft),
                1,
                LikeLinkType,
                new bytes(0)
            )
        );

        // check state
        DataTypes.ERC721Struct[] memory linkingERC721s = linklist.getLinkingERC721s(1);
        assertEq(linkingERC721s.length, 1);
        assertEq(linkingERC721s[0].tokenAddress, address(nft));
        assertEq(linkingERC721s[0].erc721TokenId, 1);
        bytes32 linkKey = keccak256(abi.encodePacked("ERC721", address(nft), uint256(1)));
        DataTypes.ERC721Struct memory linkingERC721 = linklist.getLinkingERC721(linkKey);
        assertEq(linkingERC721.tokenAddress, address(nft));
        assertEq(linkingERC721.erc721TokenId, 1);
        assertEq(linklist.getLinkingERC721ListLength(1), 1);
    }

    function testLinkERC721Fail() public {
        //  NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                FIRST_CHARACTER_ID,
                address(nft),
                1,
                LikeLinkType,
                new bytes(0)
            )
        );
    }

    function testUnlinkERC721() public {
        nft.mint(bob);

        vm.startPrank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                FIRST_CHARACTER_ID,
                address(nft),
                1,
                LikeLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckAll);
        emit Events.UnlinkERC721(FIRST_CHARACTER_ID, address(nft), 1, LikeLinkType, 1);
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(FIRST_CHARACTER_ID, address(nft), 1, LikeLinkType)
        );

        // unlink twice
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(FIRST_CHARACTER_ID, address(nft), 1, LikeLinkType)
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        assertEq(linklist.getOwnerCharacterId(1), FIRST_CHARACTER_ID);
        assertEq(linklist.getLinkingERC721s(1).length, 0);
        assertEq(linklist.getLinkingERC721ListLength(1), 0);
    }

    function testUnlinkERC721Fail() public {
        nft.mint(bob);
        vm.prank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                FIRST_CHARACTER_ID,
                address(nft),
                1,
                LikeLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(FIRST_CHARACTER_ID, address(nft), 1, LikeLinkType)
        );
    }
}
