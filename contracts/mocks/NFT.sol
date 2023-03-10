// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {NFTBase} from "../base/NFTBase.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract NFT is NFTBase, Initializable {
    function initialize(string calldata name_, string calldata symbol_) external initializer {
        super._initialize(name_, symbol_);
    }

    function mint(address to) public {
        uint256 tokenId = totalSupply() + 1;
        _mint(to, tokenId);
    }
}

contract NFT1155 is ERC1155 {
    // solhint-disable-next-line no-empty-blocks
    constructor() ERC1155("https://ipfsxxxx") {}

    function mint(address to) public {
        bytes memory data = new bytes(0);
        _mint(to, 1, 1, data);
    }
}
