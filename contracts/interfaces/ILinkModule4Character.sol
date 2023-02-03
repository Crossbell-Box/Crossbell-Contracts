// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface ILinkModule4Character {
    function initializeLinkModule(uint256 characterId, bytes calldata data)
        external
        returns (bytes memory);

    function processLink(
        address caller,
        uint256 characterId,
        bytes calldata data
    ) external;
}
