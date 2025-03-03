// SPDX-License-Identifier: MIT
// solhint-disable contract-name-camelcase
pragma solidity 0.8.18;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title DataTypes
 * @notice A standard library of data types.
 */
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

    /**
     * @dev A struct containing data associated with each new note.
     * @param linkItemType The link type of this note, if the note is a note with link.
     * @param linkKey If linkKey is not empty, it is a note with link(eg.a comment to a character or a note).
     * @param contentURI The URI associated with this note.
     * @param linkModule The address of the current link module of this note, can be empty.
     * @param mintModule  The address of the current mint module of this note, can be empty.
     * @param mintNFT The address of the mintNFT associated with this note, if any.
     * @param deleted Whether the note is deleted.
     * @param locked Whether the note is locked. If the note is locked, its owner can't set not uri anymore.
     */
    struct Note {
        bytes32 linkItemType;
        bytes32 linkKey;
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
     * @param blocklist The list of blocklist addresses.
     *  @param allowlist The list of allowlist addresses.
     */
    struct Operators4Note {
        EnumerableSet.AddressSet blocklist;
        EnumerableSet.AddressSet allowlist;
    }

    /**
     * @dev A struct containing the necessary information to reconstruct an EIP-712 typed data signature.
     * @param signer The address of the signer.
     * @param v The signature's recovery parameter.
     * @param r The signature's r parameter.
     * @param s The signature's s parameter
     * @param deadline The signature's deadline.
     */
    struct EIP712Signature {
        address signer;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }
}
