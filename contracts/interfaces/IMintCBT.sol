// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IMintCBT {
    function initialize(
        uint256 characterId,
        uint256 noteId,
        address web3Entry,
        string calldata name,
        string calldata symbol
    ) external;

    function mint(address to, uint256 characterId) external returns (uint256);
}
