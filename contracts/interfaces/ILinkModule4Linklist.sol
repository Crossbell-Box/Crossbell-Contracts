// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface ILinkModule4Linklist {
    function initializeLinkModule(uint256 tokenId, bytes calldata data)
        external
        returns (bytes memory);

    function processLink(
        address account,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
