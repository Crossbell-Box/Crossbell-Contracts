// SPDX-License-Identifier: MIT
// solhint-disable contract-name-camelcase
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library DataTypes {
    struct MigrateData {
        address account;
        string handle;
        string uri;
        address[] toAddresses;
        bytes32 linkType;
    }

    struct CreateCharacterData {
        address to;
        string handle;
        string uri;
        address linkModule;
        bytes linkModuleInitData;
    }

    struct createThenLinkCharacterData {
        uint256 fromCharacterId;
        address to;
        bytes32 linkType;
    }

    struct linkNoteData {
        uint256 fromCharacterId;
        uint256 toCharacterId;
        uint256 toNoteId;
        bytes32 linkType;
        bytes data;
    }

    struct unlinkNoteData {
        uint256 fromCharacterId;
        uint256 toCharacterId;
        uint256 toNoteId;
        bytes32 linkType;
    }

    struct linkCharacterData {
        uint256 fromCharacterId;
        uint256 toCharacterId;
        bytes32 linkType;
        bytes data;
    }

    struct unlinkCharacterData {
        uint256 fromCharacterId;
        uint256 toCharacterId;
        bytes32 linkType;
    }

    struct linkERC721Data {
        uint256 fromCharacterId;
        address tokenAddress;
        uint256 tokenId;
        bytes32 linkType;
        bytes data;
    }

    struct unlinkERC721Data {
        uint256 fromCharacterId;
        address tokenAddress;
        uint256 tokenId;
        bytes32 linkType;
    }

    struct linkAddressData {
        uint256 fromCharacterId;
        address ethAddress;
        bytes32 linkType;
        bytes data;
    }

    struct unlinkAddressData {
        uint256 fromCharacterId;
        address ethAddress;
        bytes32 linkType;
    }

    struct linkAnyUriData {
        uint256 fromCharacterId;
        string toUri;
        bytes32 linkType;
        bytes data;
    }

    struct unlinkAnyUriData {
        uint256 fromCharacterId;
        string toUri;
        bytes32 linkType;
    }

    struct linkLinklistData {
        uint256 fromCharacterId;
        uint256 toLinkListId;
        bytes32 linkType;
        bytes data;
    }

    struct unlinkLinklistData {
        uint256 fromCharacterId;
        uint256 toLinkListId;
        bytes32 linkType;
    }

    struct setLinkModule4CharacterData {
        uint256 characterId;
        address linkModule;
        bytes linkModuleInitData;
    }

    struct setLinkModule4NoteData {
        uint256 characterId;
        uint256 noteId;
        address linkModule;
        bytes linkModuleInitData;
    }

    struct setLinkModule4LinklistData {
        uint256 linklistId;
        address linkModule;
        bytes linkModuleInitData;
    }

    struct setLinkModule4ERC721Data {
        address tokenAddress;
        uint256 tokenId;
        address linkModule;
        bytes linkModuleInitData;
    }

    struct setLinkModule4AddressData {
        address account;
        address linkModule;
        bytes linkModuleInitData;
    }

    struct setMintModule4NoteData {
        uint256 characterId;
        uint256 noteId;
        address mintModule;
        bytes mintModuleInitData;
    }

    struct linkCharactersInBatchData {
        uint256 fromCharacterId;
        uint256[] toCharacterIds;
        bytes[] data;
        address[] toAddresses;
        bytes32 linkType;
    }

    struct LinkData {
        uint256 linklistId;
        uint256 linkItemType;
        uint256 linkingCharacterId;
        address linkingAddress;
        uint256 linkingLinklistId;
        bytes32 linkKey;
    }

    struct PostNoteData {
        uint256 characterId;
        string contentUri;
        address linkModule;
        bytes linkModuleInitData;
        address mintModule;
        bytes mintModuleInitData;
        bool locked;
    }

    struct MintNoteData {
        uint256 characterId;
        uint256 noteId;
        address to;
        bytes mintModuleData;
    }

    // character struct
    struct Character {
        uint256 characterId;
        string handle;
        string uri;
        uint256 noteCount;
        address socialToken;
        address linkModule;
    }

    // note struct
    struct Note {
        bytes32 linkItemType; // type of note with link
        bytes32 linkKey; // if linkKey is not empty, it is a note with link
        string contentUri;
        address linkModule;
        address mintModule;
        address mintNFT;
        bool deleted;
        bool locked;
    }

    struct CharacterLinkStruct {
        uint256 fromCharacterId;
        uint256 toCharacterId;
        bytes32 linkType;
    }

    struct NoteStruct {
        uint256 characterId;
        uint256 noteId;
    }

    struct ERC721Struct {
        address tokenAddress;
        uint256 erc721TokenId;
    }

    /**
     @dev The blocklistId and allowlistId increase at each call `grantOperators4Note`.
     * This is a safer way to overwrite addressSet,
     * if you want to learn more about the details,
     * check this issue: https://github.com/OpenZeppelin/openzeppelin-contracts/issues/3256.
     @param blocklistId The current id of blocklists.
     @param blocklists The list of blocklist addresses.
     @param allowlistId The current id of allowlists.
     @param allowlists The list of allowlist addresses.
     */
    struct Operators4Note {
        uint256 blocklistId;
        mapping(uint256 => EnumerableSet.AddressSet) blocklists;
        uint256 allowlistId;
        mapping(uint256 => EnumerableSet.AddressSet) allowlists;
    }
}
