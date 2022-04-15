// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library Events {
    event BaseInitialized(string name, string symbol, uint256 timestamp);

    event Web3EntryInitialized(uint256 timestamp);

    event LinklistNFTInitialized(uint256 timestamp);

    event MintNFTInitialized(uint256 profileId, uint256 noteId, uint256 timestamp);

    event ProfileCreated(
        uint256 indexed profileId,
        address indexed creator,
        address indexed to,
        string handle,
        uint256 timestamp
    );

    event SetPrimaryProfileId(address indexed account, uint256 indexed profileId);

    event SetHandle(address indexed account, uint256 indexed profileId, string newHandle);

    event SetSocialToken(
        address indexed account,
        uint256 indexed profileId,
        address indexed tokenAddress
    );

    event AttachLinklist(uint256 indexed profileId, bytes32 linkType, uint256 indexed linklistId);

    event DetachLinklist(uint256 indexed profileId, bytes32 linkType, uint256 indexed linklistId);

    event LinkProfile(
        address indexed account,
        uint256 indexed fromProfileId,
        uint256 indexed toProfileId,
        bytes32 linkType,
        uint256 linklistId
    );

    event UnlinkProfile(
        address indexed account,
        uint256 indexed fromProfileId,
        uint256 indexed toProfileId,
        bytes32 linkType
    );

    event SetLinkModule4Profile(
        uint256 indexed profileId,
        address indexed linkModule,
        bytes returnData,
        uint256 timestamp
    );

    event SetLinkModule4Note(
        uint256 indexed profileId,
        uint256 indexed noteId,
        address indexed linkModule,
        bytes returnData,
        uint256 timestamp
    );

    event SetLinkModule4Address(
        address indexed account,
        address indexed linkModule,
        bytes returnData,
        uint256 timestamp
    );

    event SetMintModule4Note(
        uint256 indexed profileId,
        uint256 indexed noteId,
        address indexed mintModule,
        bytes returnData,
        uint256 timestamp
    );
}
