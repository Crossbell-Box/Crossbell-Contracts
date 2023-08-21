// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {CommonTest} from "./helpers/CommonTest.sol";
import {ErrTokenNotExists} from "../contracts/libraries/Error.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

contract CharacterSettingsTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
    }

    function testSetupState() public {
        assertEq(web3Entry.name(), WEB3_ENTRY_NFT_NAME);
        assertEq(web3Entry.symbol(), WEB3_ENTRY_NFT_SYMBOL);
        assertEq(web3Entry.getRevision(), 4);
        assertEq(web3Entry.getLinklistContract(), address(linklist));
    }

    function testSupportsInterface() public {
        assertTrue(web3Entry.supportsInterface(type(IERC721).interfaceId));
        assertTrue(web3Entry.supportsInterface(type(IERC721Enumerable).interfaceId));
        assertTrue(web3Entry.supportsInterface(type(IERC721Metadata).interfaceId));
        assertTrue(web3Entry.supportsInterface(type(IERC165).interfaceId));
    }

    function testQueryWithTokenNotExists() public {
        // token not exist
        uint256 tokenId = 2;

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        web3Entry.tokenURI(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        web3Entry.getHandle(tokenId);

        vm.expectRevert("ERC721: owner query for nonexistent token");
        web3Entry.ownerOf(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        web3Entry.getCharacter(tokenId);
    }
}
