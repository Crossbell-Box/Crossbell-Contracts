// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Events} from "../../contracts/libraries/Events.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {ErrNotEnoughPermission} from "../../contracts/libraries/Error.sol";
import {OP} from "../../contracts/libraries/OP.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract LinkERC721Test is CommonTest {
    uint256 public firstCharacter;
    uint256 public secondCharacter;

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        firstCharacter = _createCharacter(CHARACTER_HANDLE, alice);
        secondCharacter = _createCharacter(CHARACTER_HANDLE2, bob);
    }

    // solhint-disable-next-line function-max-lines
    function testLinkERC721() public {
        nft.mint(bob);

        vm.prank(alice);
        expectEmit(CheckAll);
        emit Events.LinkERC721(firstCharacter, address(nft), 1, LikeLinkType, 1);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(firstCharacter, address(nft), 1, LikeLinkType, "")
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // link twice
        vm.prank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(firstCharacter, address(nft), 1, LikeLinkType, "")
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(firstCharacter, address(nft), 1, LikeLinkType, "")
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

    function testLinkERC721WithOperator() public {
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(firstCharacter, bob, 1 << OP.LINK_ERC721);

        vm.prank(bob);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(firstCharacter, address(nft), 1, LikeLinkType, "")
        );
    }

    function testLinkERC721Fail() public {
        //  NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(firstCharacter, address(nft), 1, LikeLinkType, "")
        );
    }

    function testLinkERC721FailWithOperator() public {
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            firstCharacter,
            bob,
            UINT256_MAX ^ (1 << OP.LINK_ERC721)
        );

        //  NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(firstCharacter, address(nft), 1, LikeLinkType, "")
        );
    }

    function testUnlinkERC721() public {
        nft.mint(bob);

        vm.startPrank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(firstCharacter, address(nft), 1, LikeLinkType, "")
        );

        // unlink
        expectEmit(CheckAll);
        emit Events.UnlinkERC721(firstCharacter, address(nft), 1, LikeLinkType, 1);
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(firstCharacter, address(nft), 1, LikeLinkType)
        );

        // unlink twice
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(firstCharacter, address(nft), 1, LikeLinkType)
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        assertEq(linklist.getOwnerCharacterId(1), firstCharacter);
        assertEq(linklist.getLinkingERC721s(1).length, 0);
        assertEq(linklist.getLinkingERC721ListLength(1), 0);
    }

    function testUnlinkERC721Fail() public {
        nft.mint(bob);
        vm.prank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(firstCharacter, address(nft), 1, LikeLinkType, "")
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(firstCharacter, address(nft), 1, LikeLinkType)
        );
    }
}
