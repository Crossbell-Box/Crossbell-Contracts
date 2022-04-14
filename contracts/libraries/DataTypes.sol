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

    struct LinkData {
        uint256 linkListId;
        bytes32 linkType;
        uint256 linkTargetType;
        bytes content;
    }

    struct PostNoteData {
        uint256 profileId;
        string contentURI;
        address linkModule;
        bytes linkModuleInitData;
        address mintModule;
        bytes mintModuleInitData;
    }

    // profile struct
    struct Profile {
        string handle;
        string metadataUri;
        uint256 noteCount;
        address socialTokenAddress;
    }

    // note struct
    struct Note {
        uint256 noteType;
        uint256 linkType;
        bytes32 IdPointed;
        string contentURI;
        address linkModule;
        address mintModule;
    }
}
