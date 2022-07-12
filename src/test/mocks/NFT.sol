// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract NFT is ERC721Enumerable {
    constructor() ERC721("NFT", "NFT") {}

    function mint(address to) public {
        uint256 tokenId = totalSupply() + 1;
        _safeMint(to, tokenId);
    }
}

contract NFT1155 is ERC1155 {
    constructor() ERC1155("https://ipfsxxxx") {}

    function mint(address to) public {
        bytes memory data = new bytes(0);
        _mint(to, 1, 1, data);
    }
}
