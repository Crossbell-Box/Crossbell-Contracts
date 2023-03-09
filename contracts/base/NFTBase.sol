// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import {ERC721} from "./ERC721.sol";
import {ERC721Enumerable} from "./ERC721Enumerable.sol";
import {Events} from "../libraries/Events.sol";

abstract contract NFTBase is ERC721Enumerable {
    function _initialize(string calldata name, string calldata symbol) internal {
        ERC721.__ERC721_Init(name, symbol);

        emit Events.BaseInitialized(name, symbol, block.timestamp);
    }

    // solhint-disable ordering
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(msg.sender, tokenId), "NFTBase: NotOwnerOrApproved");
        _burn(tokenId);
    }
}
