// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface ILinkModule {
    function initializeLinkModule(
        uint256 characterId,
        uint256 noteId,
        string calldata name,
        string calldata symbol
    ) external returns (bytes memory);

    function processLink(
        address to,
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external;
}
