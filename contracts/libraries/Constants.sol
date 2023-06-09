// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

library Constants {
    uint8 public constant MAX_HANDLE_LENGTH = 31;
    uint8 public constant MIN_HANDLE_LENGTH = 3;

    // constants for linkItemType of note struct
    bytes32 public constant LINK_ITEM_TYPE_CHARACTER = "Character";
    bytes32 public constant LINK_ITEM_TYPE_ADDRESS = "Address";
    bytes32 public constant LINK_ITEM_TYPE_LINKLIST = "Linklist";
    bytes32 public constant LINK_ITEM_TYPE_NOTE = "Note";
    bytes32 public constant LINK_ITEM_TYPE_ERC721 = "ERC721";
    bytes32 public constant LINK_ITEM_TYPE_ANYURI = "AnyUri";
}
