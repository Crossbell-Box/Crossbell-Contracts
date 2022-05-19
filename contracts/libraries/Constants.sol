// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library Constants {
    uint8 internal constant MAX_HANDLE_LENGTH = 31;
    uint8 internal constant MIN_HANDLE_LENGTH = 3;

    // note link type
    // "ProfileLink"
    bytes32 constant NoteLinkTypeProfileLink =
        0x50726f66696c654c696e6b000000000000000000000000000000000000000000;
    // "AddressLink"
    bytes32 constant NoteLinkTypeAddressLink =
        0x416464726573734c696e6b000000000000000000000000000000000000000000;
    // "NoteLink"
    bytes32 constant NoteLinkTypeNoteLink =
        0x4e6f74654c696e6b000000000000000000000000000000000000000000000000;
    // "ERC721Link"
    bytes32 constant NoteLinkTypeERC721Link =
        0x4552433732314c696e6b00000000000000000000000000000000000000000000;
    // "ListLink"
    bytes32 constant NoteLinkTypeListLink =
        0x4c6973744c696e6b000000000000000000000000000000000000000000000000;
    // "AnyLink"
    bytes32 constant NoteLinkTypeAnyLink =
        0x416e794c696e6b00000000000000000000000000000000000000000000000000;
}
