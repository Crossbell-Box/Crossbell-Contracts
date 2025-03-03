// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface ILinkModule4Address {
    function initializeLinkModule(address account, bytes calldata data) external returns (bytes memory);

    function processLink(address account, uint256 noteId, bytes calldata data) external;
}
