// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library DataTypes {
    // link type
    uint256 constant LinkTypeProfile = 1;
    uint256 constant LinkTypeAddress = 2;
    uint256 constant LinkTypeNote = 3;
    uint256 constant LinkTypeAsset = 4;
    uint256 constant LinkTypeList = 5;

    // note type
    uint256 constant NoteTypeNote = 1;
    uint256 constant NoteTypeLink = 2;

    struct CreateProfileData {
        address to;
        string handle;
        string uri;
        address linkModule;
        bytes linkModuleInitData;
    }

    struct linkProfileLinkData {
        uint256 fromProfileId;
        bytes32 linkType;
        uint256 profileLinkFromProfileId;
        uint256 profileLinkToProfileId;
        bytes32 profileLinkLinkType;
    }

    struct LinkData {
        uint256 linklistId;
        bytes content;
    }

    struct PostNoteData {
        uint256 profileId;
        string contentUri;
        address linkModule;
        bytes linkModuleInitData;
        address mintModule;
        bytes mintModuleInitData;
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
        uint256 noteType;
        uint256 linkType;
        bytes32 linkKey;
        string contentUri;
        address linkModule;
        address mintModule;
        address mintNFT;
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
