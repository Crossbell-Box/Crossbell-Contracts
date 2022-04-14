// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IMintNFT {
    function initialize(
        uint256 profileId,
        uint256 noteId,
        address web3Entry,
        string calldata name,
        string calldata symbol
    ) external;

    function mint(address to) external returns (uint256);

    function getSourcePublicationPointer()
        external
        view
        returns (uint256, uint256);
}
