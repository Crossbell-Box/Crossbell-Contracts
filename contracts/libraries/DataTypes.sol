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

    struct linkProfileLinkData {
        uint256 fromProfileId;
        bytes32 linkType;
        uint256 profileLinkFromProfileId;
        uint256 profileLinkToProfileId;
        bytes32 profileLinkLinkType;
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
        bytes32 linkItemType;
        uint256 linklistId;
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
