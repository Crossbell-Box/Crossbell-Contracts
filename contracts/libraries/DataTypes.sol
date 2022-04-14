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

    // profile struct
    struct Profile {
        string handle;
        string metadataURI;
        uint256 noteCount;
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
