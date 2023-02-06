// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

library Constants {
    uint8 public constant MAX_HANDLE_LENGTH = 31;
    uint8 public constant MIN_HANDLE_LENGTH = 3;

    // note link item type
    // "Character"
    bytes32 public constant NoteLinkTypeCharacter =
        0x4368617261637465720000000000000000000000000000000000000000000000;
    // "Address"
    bytes32 public constant NoteLinkTypeAddress =
        0x4164647265737300000000000000000000000000000000000000000000000000;
    // "Linklist"
    bytes32 public constant NoteLinkTypeLinklist =
        0x4c696e6b6c697374000000000000000000000000000000000000000000000000;
    // "Note"
    bytes32 public constant NoteLinkTypeNote =
        0x4e6f746500000000000000000000000000000000000000000000000000000000;
    // "ERC721"
    bytes32 public constant NoteLinkTypeERC721 =
        0x4552433732310000000000000000000000000000000000000000000000000000;
    // "AnyUri"
    bytes32 public constant NoteLinkTypeAnyUri =
        0x416e795572690000000000000000000000000000000000000000000000000000;

    // note link tag
    // "LinkNoteTag"
    bytes32 public constant NoteLinkTag =
        0x4c696e6b4e6f7465546167000000000000000000000000000000000000000000;
    // "LinkUriTag"
    bytes32 public constant UriLinkTag =
        0x4e6f74654c696e6b546167000000000000000000000000000000000000000000;
}
