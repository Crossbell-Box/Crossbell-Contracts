// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./ERC721Enumerable.sol";
import "../libraries/Events.sol";

abstract contract NFTBase is ERC721Enumerable {
    function _initialize(string calldata name, string calldata symbol) internal {
        ERC721.__ERC721_Init(name, symbol);

        emit Events.BaseInitialized(name, symbol, block.timestamp);
    }
}
