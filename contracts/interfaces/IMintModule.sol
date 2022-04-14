// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IMintModule {
    function initializeMintModule(
        uint256 profileId,
        uint256 noteId,
        string calldata name,
        string calldata symbol
    ) external returns (bytes memory);

    function processMint(
        address to,
        uint256 profileId,
        uint256 noteId,
        bytes calldata data
    ) external;
}
