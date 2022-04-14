// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface ILinkModule4Profile {
    function initializeLinkModule(uint256 profileId, bytes calldata data)
        external
        returns (bytes memory);

    function processLink(uint256 profileId, bytes calldata data) external;
}
