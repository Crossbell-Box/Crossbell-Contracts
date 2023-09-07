// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract LinklistExtendStorage {
    uint256 internal _tokenCount;
    mapping(uint256 tokenId => uint256 characterId) internal _linklistOwners;
    mapping(uint256 characterId => uint256 balances) internal _linklistBalances;
    uint256 internal _totalSupply;
}
