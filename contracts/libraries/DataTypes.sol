// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library DataTypes {
    struct CreateProfileData {
        address to;
        string handle;
        string uri;
        address linkModule;
        bytes linkModuleInitData;
    }

    struct createThenLinkProfileData {
        uint256 fromProfileId;
        address to;
        bytes32 linkType;
    }

    struct linkNoteData {
        uint256 fromProfileId;
        uint256 toProfileId;
        uint256 toNoteId;
        bytes32 linkType;
        bytes data;
    }

    struct unlinkNoteData {
        uint256 fromProfileId;
        uint256 toProfileId;
        uint256 toNoteId;
        bytes32 linkType;
    }

    struct linkProfileData {
        uint256 fromProfileId;
        uint256 toProfileId;
        bytes32 linkType;
        bytes data;
    }

    struct unlinkProfileData {
        uint256 fromProfileId;
        uint256 toProfileId;
        bytes32 linkType;
    }

    struct linkProfileLinkData {
        uint256 fromProfileId;
        bytes32 linkType;
        uint256 profileLinkFromProfileId;
        uint256 profileLinkToProfileId;
        bytes32 profileLinkLinkType;
    }

    struct linkERC721Data {
        uint256 fromProfileId;
        address tokenAddress;
        uint256 tokenId;
        bytes32 linkType;
        bytes data;
    }

    struct unlinkERC721Data {
        uint256 fromProfileId;
        address tokenAddress;
        uint256 tokenId;
        bytes32 linkType;
    }

    struct linkAddressData {
        uint256 fromProfileId;
        address ethAddress;
        bytes32 linkType;
        bytes data;
    }

    struct linkAnyUriData {
        uint256 fromProfileId;
        string toUri;
        bytes32 linkType;
        bytes data;
    }

    struct unlinkAnyUriData {
        uint256 fromProfileId;
        string toUri;
        bytes32 linkType;
    }

    struct linkLinklistData {
        uint256 fromProfileId;
        uint256 toLinkListId;
        bytes32 linkType;
        bytes data;
    }

    struct setLinkModule4ProfileData {
        uint256 profileId;
        address linkModule;
        bytes linkModuleInitData;
    }

    struct setLinkModule4NoteData {
        uint256 profileId;
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
        uint256 profileId;
        uint256 noteId;
        address mintModule;
        bytes mintModuleInitData;
    }

    struct linkProfilesInBatchData {
        uint256 fromProfileId;
        uint256[] toProfileIds;
        bytes[] data;
        address[] toAddresses;
        bytes32 linkType;
    }

    struct createProfileThenPostNoteData {
        string handle;
        string uri;
        address profileLinkModule;
        bytes profileLinkModuleInitData;
        string contentUri;
        address noteLinkModule;
        bytes noteLinkModuleInitData;
        address mintModule;
        bytes mintModuleInitData;
    }

    struct LinkData {
        uint256 linklistId;
        uint256 linkItemType;
        uint256 linkingProfileId;
        address linkingAddress;
        uint256 linkingLinklistId;
        bytes32 linkKey;
    }

    struct PostNoteData {
        uint256 profileId;
        string contentUri;
        address linkModule;
        bytes linkModuleInitData;
        address mintModule;
        bytes mintModuleInitData;
    }

    struct MintNoteData {
        uint256 profileId;
        uint256 noteId;
        address to;
        bytes mintModuleData;
    }

    // profile struct
    struct Profile {
        uint256 profileId;
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
    }

    struct ProfileLinkStruct {
        uint256 fromProfileId;
        uint256 toProfileId;
        bytes32 linkType;
    }

    struct NoteStruct {
        uint256 profileId;
        uint256 noteId;
    }

    struct ERC721Struct {
        address tokenAddress;
        uint256 erc721TokenId;
    }
}
