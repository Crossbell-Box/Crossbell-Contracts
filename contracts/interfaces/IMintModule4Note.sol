// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IMintModule4Note {
    function initializeMintModule(
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external returns (bytes memory);

    function processMint(
        address to,
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external;
}
