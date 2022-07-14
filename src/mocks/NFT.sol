// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../base/NFTBase.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract NFT is NFTBase, Initializable {
    function initialize(string calldata _name, string calldata _symbol) external initializer {
        super._initialize(_name, _symbol);
    }

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
