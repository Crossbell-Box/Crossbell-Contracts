// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface ILinkModule4ERC721 {
    function initializeLinkModule(
        address tokenAddress,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes memory);

    function processLink(
        address account,
        address tokenAddress,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
