// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library Events {
    event BaseInitialized(string name, string symbol, uint256 timestamp);

    event Web3EntryInitialized(uint256 timestamp);

    event LinklistNFTInitialized(uint256 timestamp);

    event MintNFTInitialized(uint256 characterId, uint256 noteId, uint256 timestamp);

    event CharacterCreated(
        uint256 indexed characterId,
        address indexed creator,
        address indexed to,
        string handle,
        uint256 timestamp
    );

    event SetPrimaryCharacterId(
        address indexed account,
        uint256 indexed characterId,
        uint256 indexed oldCharacterId
    );

    event SetHandle(address indexed account, uint256 indexed characterId, string newHandle);

    event SetSocialToken(
        address indexed account,
        uint256 indexed characterId,
        address indexed tokenAddress
    );

    event GrantOperatorPermissions(
        uint256 indexed characterId,
        address indexed operator,
        uint256 permissionBitMap
    );

    event GrantOperators4Note(
        uint256 indexed characterId,
        uint256 indexed noteId,
        address[] blocklist,
        address[] allowlist
    );

    event SetCharacterUri(uint256 indexed characterId, string newUri);

    event PostNote(
        uint256 indexed characterId,
        uint256 indexed noteId,
        bytes32 indexed linkKey,
        bytes32 linkItemType,
        bytes data
    );

    event SetNoteUri(uint256 indexed characterId, uint256 noteId, string newUri);

    event DeleteNote(uint256 indexed characterId, uint256 noteId);

    event LockNote(uint256 indexed characterId, uint256 noteId);

    event LinkCharacter(
        address indexed account,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        bytes32 linkType,
        uint256 linklistId
    );

    event UnlinkCharacter(
        address indexed account,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        bytes32 linkType
    );

    event LinkNote(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        uint256 indexed toNoteId,
        bytes32 linkType,
        uint256 linklistId
    );

    event UnlinkNote(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        uint256 indexed toNoteId,
        bytes32 linkType,
        uint256 linklistId
    );

    event LinkERC721(
        uint256 indexed fromCharacterId,
        address indexed tokenAddress,
        uint256 indexed toNoteId,
        bytes32 linkType,
        uint256 linklistId
    );

    event LinkAddress(
        uint256 indexed fromCharacterId,
        address indexed ethAddress,
        bytes32 linkType,
        uint256 linklistId
    );

    event UnlinkAddress(
        uint256 indexed fromCharacterId,
        address indexed ethAddress,
        bytes32 linkType
    );

    event LinkAnyUri(
        uint256 indexed fromCharacterId,
        string toUri,
        bytes32 linkType,
        uint256 linklistId
    );

    event UnlinkAnyUri(uint256 indexed fromCharacterId, string toUri, bytes32 linkType);

    event LinkCharacterLink(
        uint256 indexed fromCharacterId,
        bytes32 indexed linkType,
        uint256 clFromCharacterId,
        uint256 clToCharacterId,
        bytes32 clLinkType
    );

    event UnlinkCharacterLink(
        uint256 indexed fromCharacterId,
        bytes32 indexed linkType,
        uint256 clFromCharactereId,
        uint256 clToCharacterId,
        bytes32 clLinkType
    );

    event UnlinkERC721(
        uint256 indexed fromCharacterId,
        address indexed tokenAddress,
        uint256 indexed toNoteId,
        bytes32 linkType,
        uint256 linklistId
    );

    event LinkLinklist(
        uint256 indexed fromCharacterId,
        uint256 indexed toLinklistId,
        bytes32 linkType,
        uint256 indexed linklistId
    );

    event UnlinkLinklist(
        uint256 indexed fromCharacterId,
        uint256 indexed toLinklistId,
        bytes32 linkType,
        uint256 indexed linklistId
    );

    event MintNote(
        address indexed to,
        uint256 indexed characterId,
        uint256 indexed noteId,
        address tokenAddress,
        uint256 tokenId
    );

    event SetLinkModule4Character(
        uint256 indexed characterId,
        address indexed linkModule,
        bytes returnData,
        uint256 timestamp
    );

    event SetLinkModule4Note(
        uint256 indexed characterId,
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

    event SetLinkModule4Linklist(
        uint256 indexed linklistId,
        address indexed linkModule,
        bytes returnData,
        uint256 timestamp
    );

    event SetMintModule4Note(
        uint256 indexed characterId,
        uint256 indexed noteId,
        address indexed mintModule,
        bytes returnData,
        uint256 timestamp
    );

    event AttachLinklist(
        uint256 indexed linklistId,
        uint256 indexed characterId,
        bytes32 indexed linkType
    );

    event DetachLinklist(
        uint256 indexed linklistId,
        uint256 indexed characterId,
        bytes32 indexed linkType
    );
}
