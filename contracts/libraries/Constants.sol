// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library Constants {
    uint8 internal constant MAX_HANDLE_LENGTH = 31;
    uint8 internal constant MIN_HANDLE_LENGTH = 3;

    // note link item type
    // "Profile"
    bytes32 constant NoteLinkTypeProfile =
        0x50726f66696c6500000000000000000000000000000000000000000000000000;
    // "Address"
    bytes32 constant NoteLinkTypeAddress =
        0x4164647265737300000000000000000000000000000000000000000000000000;
    // "Linklist"
    bytes32 constant NoteLinkTypeLinklist =
        0x4c696e6b6c697374000000000000000000000000000000000000000000000000;
    // "Note"
    bytes32 constant NoteLinkTypeNote =
        0x4e6f746500000000000000000000000000000000000000000000000000000000;
    // "ERC721"
    bytes32 constant NoteLinkTypeERC721 =
        0x4552433732310000000000000000000000000000000000000000000000000000;
    // "AnyUri"
    bytes32 constant NoteLinkTypeAnyUri =
        0x416e795572690000000000000000000000000000000000000000000000000000;
}
