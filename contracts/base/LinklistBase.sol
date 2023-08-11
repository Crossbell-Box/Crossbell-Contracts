// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {ERC721} from "./ERC721.sol";
import {Events} from "../libraries/Events.sol";

abstract contract LinklistBase is ERC721 {
    /**
     * @dev For compatibility with previous ERC721Enumerable, we need to keep the unused slots for upgradeability.
     */
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens; // unused slot 6
    mapping(uint256 => uint256) private _ownedTokensIndex; // unused slot 7
    uint256[] private _allTokens; // unused slot 8
    mapping(uint256 => uint256) private _allTokensIndex; // unused slot 9

    function _initialize(string calldata name, string calldata symbol) internal {
        ERC721.__ERC721_Init(name, symbol);

        emit Events.BaseInitialized(name, symbol, block.timestamp);
    }
}
