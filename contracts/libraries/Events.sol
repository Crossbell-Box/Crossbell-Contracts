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

    event LinkNote(
        uint256 indexed fromProfileId,
        uint256 indexed toProfileId,
        uint256 indexed toNoteId,
        bytes32 linkType,
        uint256 linklistId
    );

    event UnlinkNote(
        uint256 indexed fromProfileId,
        uint256 indexed toProfileId,
        uint256 indexed toNoteId,
        bytes32 linkType,
        uint256 linklistId
    );

    event LinkERC721(
        uint256 indexed fromProfileId,
        address indexed tokenAddress,
        uint256 indexed toNoteId,
        bytes32 linkType,
        uint256 linklistId
    );

    event LinkAddress(
        uint256 indexed fromProfileId,
        address indexed ethAddress,
        bytes32 linkType,
        uint256 linklistId
    );

    event UnlinkAddress(
        uint256 indexed fromProfileId,
        address indexed ethAddress,
        bytes32 linkType
    );

    event LinkAny(
        uint256 indexed fromProfileId,
        string toUri,
        bytes32 linkType,
        uint256 linklistId
    );

    event UnlinkAny(uint256 indexed fromProfileId, string toUri, bytes32 linkType);

    event LinkProfileLink(
        uint256 indexed fromProfileId,
        bytes32 indexed linkType,
        uint256 plFromProfileId,
        uint256 plToProfileId,
        bytes32 plLinkType
    );

    event UnlinkProfileLink(
        uint256 indexed fromProfileId,
        bytes32 indexed linkType,
        uint256 plFromProfileId,
        uint256 plToProfileId,
        bytes32 plLinkType
    );

    event UnlinkERC721(
        uint256 indexed fromProfileId,
        address indexed tokenAddress,
        uint256 indexed toNoteId,
        bytes32 linkType,
        uint256 linklistId
    );

    event LinkLinklist(
        uint256 indexed fromProfileId,
        uint256 indexed toLinklistId,
        bytes32 linkType,
        uint256 indexed linklistId
    );

    event UninkLinklist(
        uint256 indexed fromProfileId,
        uint256 indexed toLinklistId,
        bytes32 linkType,
        uint256 indexed linklistId
    );

    event MintNote(
        address indexed to,
        uint256 indexed profileId,
        uint256 indexed noteId,
        uint256 tokenId,
        bytes data,
        uint256 timestamp
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

    event SetLinkModule4ERC721(
        address indexed tokenAddress,
        uint256 indexed tokenId,
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
