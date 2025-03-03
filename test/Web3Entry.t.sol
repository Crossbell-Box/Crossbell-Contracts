// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {CommonTest} from "./helpers/CommonTest.sol";
import {ErrCharacterNotExists} from "../contracts/libraries/Error.sol";
import {Web3Entry} from "../contracts/Web3Entry.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

contract Web3EntryTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
    }

    function testSetupState() public {
        assertEq(web3Entry.name(), WEB3_ENTRY_NFT_NAME);
        assertEq(web3Entry.symbol(), WEB3_ENTRY_NFT_SYMBOL);
        assertEq(web3Entry.getRevision(), 4);
        assertEq(web3Entry.getLinklistContract(), address(linklist));

        bytes32 v = vm.load(address(web3Entry), bytes32(uint256(20)));
        assertEq(uint256(v >> 160), uint256(3)); // initialize version
    }

    function testSupportsInterface() public {
        assertTrue(web3Entry.supportsInterface(type(IERC721).interfaceId));
        assertTrue(web3Entry.supportsInterface(type(IERC721Enumerable).interfaceId));
        assertTrue(web3Entry.supportsInterface(type(IERC721Metadata).interfaceId));
        assertTrue(web3Entry.supportsInterface(type(IERC165).interfaceId));
    }

    function testInitialize() public {
        Web3Entry c = new Web3Entry();
        c.initialize(
            "Web3 Entry Character",
            "WEC",
            address(linklist),
            address(mintNFTImpl),
            address(periphery),
            address(newbieVilla)
        );

        // check state
        assertEq(c.getLinklistContract(), address(linklist));

        bytes32 v = vm.load(address(web3Entry), bytes32(uint256(20)));
        assertEq(uint256(v >> 160), uint256(3)); // initialize version
    }

    function testTransferCharacter() public {
        uint256 characterId = _createCharacter(CHARACTER_HANDLE, alice);
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, characterId);

        assertEq(web3Entry.ownerOf(characterId), bob);
    }

    function testTransferCharacterWithApproval() public {
        uint256 characterId = _createCharacter(CHARACTER_HANDLE, alice);

        // alice approves bob
        vm.prank(alice);
        web3Entry.approve(bob, characterId);
        assertEq(web3Entry.getApproved(characterId), bob);

        // case 1: bob transfers character from alice to carol
        vm.prank(bob);
        web3Entry.transferFrom(alice, carol, characterId);
        assertEq(web3Entry.ownerOf(characterId), carol);
        assertEq(web3Entry.getApproved(characterId), address(0));

        // case 2: carol approve alice to transfer NFT to bob
        vm.prank(carol);
        web3Entry.setApprovalForAll(alice, true);
        assertEq(web3Entry.isApprovedForAll(carol, alice), true);
        // alice transfers character from carol to bob
        vm.prank(alice);
        web3Entry.transferFrom(carol, bob, characterId);
        assertEq(web3Entry.ownerOf(characterId), bob);
        assertEq(web3Entry.getApproved(characterId), address(0));
        assertEq(web3Entry.isApprovedForAll(carol, alice), true);
    }

    function testQueryWithTokenNotExists() public {
        // token not exist
        uint256 tokenId = 2;

        vm.expectRevert(abi.encodeWithSelector(ErrCharacterNotExists.selector, tokenId));
        web3Entry.tokenURI(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrCharacterNotExists.selector, tokenId));
        web3Entry.getHandle(tokenId);

        vm.expectRevert("ERC721: owner query for nonexistent token");
        web3Entry.ownerOf(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrCharacterNotExists.selector, tokenId));
        web3Entry.getCharacter(tokenId);
    }
}
