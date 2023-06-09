// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface ILinkModule4Note {
    function initializeLinkModule(
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external returns (bytes memory);

    function processLink(
        address caller,
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external;
}
