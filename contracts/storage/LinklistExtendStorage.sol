// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

contract LinklistExtendStorage {
    uint256 internal _tokenCount;

    // tokenId => characterId
    mapping(uint256 => uint256) internal _linklistOwners;
    // characterId => balances
    mapping(uint256 => uint256) internal _linklistBalances;
}
