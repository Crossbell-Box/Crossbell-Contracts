// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library Events {
    event BaseInitialized(string name, string symbol, uint256 timestamp);

    event Web3EntryInitialized(uint256 timestamp);

    event LinkListNFTInitialized(uint256 timestamp);

    event MintNFTInitialized(
        uint256 profileId,
        uint256 noteId,
        uint256 timestamp
    );

    event ProfileCreated(
        uint256 indexed profileId,
        address indexed creator,
        address indexed to,
        string handle,
        uint256 timestamp
    );

    event SetPrimaryProfile(address indexed account, uint256 indexed profileId);

    event SetHandle(
        address indexed account,
        uint256 indexed profileId,
        string newHandle
    );

    event LinkProfile(
        address indexed account,
        uint256 indexed fromProfileId,
        uint256 indexed toProfileId,
        bytes32 linkType
    );

    event UnlinkProfile(
        address indexed account,
        uint256 indexed fromProfileId,
        uint256 indexed toProfileId,
        bytes32 linkType
    );
}
