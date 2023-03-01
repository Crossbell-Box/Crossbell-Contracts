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

contract LinkERC721Test is Test, SetUp, Utils {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    // solhint-disable-next-line function-max-lines
    function testLinkERC721() public {
        vm.prank(address(web3Entry));
        nft.mint(bob);
        vm.prank(alice);
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkERC721(Const.FIRST_CHARACTER_ID, address(nft), 1, Const.LikeLinkType, 1);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // link twice
        vm.prank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType,
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
        // case 1: NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // case 2: ErrREC721NotExists
        vm.prank(alice);
        vm.expectRevert(abi.encodePacked("ERC721: owner query for nonexistent token"));
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                2,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
    }

    function testUnlinkERC721() public {
        vm.prank(address(web3Entry));
        nft.mint(bob);
        vm.startPrank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.UnlinkERC721(Const.FIRST_CHARACTER_ID, address(nft), 1, Const.LikeLinkType, 1);
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType
            )
        );

        // unlink twice
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType
            )
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        assertEq(linklist.getOwnerCharacterId(1), Const.FIRST_CHARACTER_ID);
        assertEq(linklist.getLinkingERC721s(1).length, 0);
        assertEq(linklist.getLinkingERC721ListLength(1), 0);
    }

    function testUnlinkERC721Fail() public {
        vm.prank(address(web3Entry));
        nft.mint(bob);
        vm.prank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkERC721(
            DataTypes.unlinkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType
            )
        );
    }
}
