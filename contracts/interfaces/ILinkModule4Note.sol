// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface ILinkModule4Note {
    function initializeLinkModule(
        uint256 profileId,
        uint256 noteId,
        bytes calldata data
    ) external returns (bytes memory);

    function processLink(
        uint256 profileId,
        uint256 noteId,
        bytes calldata data
    ) external;
}
