// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

library Constants {
    uint8 public constant MAX_HANDLE_LENGTH = 31;
    uint8 public constant MIN_HANDLE_LENGTH = 3;

    // constants for linkItemType of note struct
    bytes32 public constant NoteLinkTypeCharacter = "Character";
    bytes32 public constant NoteLinkTypeAddress = "Address";
    bytes32 public constant NoteLinkTypeLinklist = "Linklist";
    bytes32 public constant NoteLinkTypeNote = "Note";
    bytes32 public constant NoteLinkTypeERC721 = "ERC721";
    bytes32 public constant NoteLinkTypeAnyUri = "AnyUri";
}
