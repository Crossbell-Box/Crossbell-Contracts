// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/**
Permissions are laid out in a increasing order of power.
so the bitmap looks like this:

|   opSync   |   opSign   |   future   |  owner   |
|------------|------------|------------|----------|
| [236, 255] | [176, 235] |  [21, 175] | [0, 20]  |

*/
library OP {
    // [0,20] for owner permission
    uint8 internal constant SET_HANDLE = 0;
    uint8 internal constant SET_PRIMARY_CHARACTER_ID = 1;
    uint8 internal constant ADD_OPERATOR = 2;
    uint8 internal constant REMOVE_OPERATOR = 3;
    uint8 internal constant SET_SOCIAL_TOKEN = 4;
    uint8 internal constant GRANT_OPERATOR_PERMISSIONS = 5;
    uint256 internal constant DEFAULT_PERMISSION_BITMAP = ~uint256(0) << 20; // default permission sets all owner permissions to false

    // [21, 175] are reserved for future

    // [176, 235] for operator sign permissions
    uint8 internal constant SET_CHARACTER_URI = 176;
    uint8 internal constant SET_LINKLIST_URI = 177;
    uint8 internal constant LINK_CHARACTER = 178;
    uint8 internal constant UNLINK_CHARACTER = 179;
    uint8 internal constant CREATE_THEN_LINK_CHARACTER = 180;
    uint8 internal constant LINK_NOTE = 181;
    uint8 internal constant UNLINK_NOTE = 182;
    uint8 internal constant LINK_ERC721 = 183;
    uint8 internal constant UNLINK_ERC721 = 184;
    uint8 internal constant LINK_ADDRESS = 185;
    uint8 internal constant UNLINK_ADDRESS = 186;
    uint8 internal constant LINK_ANY_URI = 187;
    uint8 internal constant UNLINK_ANY_URI = 188;
    uint8 internal constant LINK_LINK_LIST = 189;
    uint8 internal constant UNLINK_LINK_LIST = 190;
    uint8 internal constant SET_LINK_MODULE_FOR_CHARACTER = 191;
    uint8 internal constant SET_LINK_MODULE_FOR_NOTE = 192;
    uint8 internal constant SET_LINK_MODULE_FOR_LINK_LIST = 193;
    uint8 internal constant SET_MINT_MODULE_FOR_NOTE = 194;
    uint8 internal constant SET_NOTE_URI = 195;
    uint8 internal constant LOCK_NOTE = 196;
    uint8 internal constant DELETE_NOTE = 197;
    uint8 internal constant POST_NOTE_FOR_CHARACTER = 198;
    uint8 internal constant POST_NOTE_FOR_ADDRESS = 199;
    uint8 internal constant POST_NOTE_FOR_LINK_LIST = 200;
    uint8 internal constant POST_NOTE_FOR_NOTE = 201;
    uint8 internal constant POST_NOTE_FOR_ERC721 = 202;
    uint8 internal constant POST_NOTE_FOR_ANY_URI = 203;

    uint256 internal constant OPERATORSIGN_PERMISSION_BITMAP = ~(~uint256(0) >> 80);

    // [236, 255] for operator sync permissio
    uint8 internal constant POST_NOTE = 236;
    uint256 internal constant OPERATORSYNC_PERMISSION_BITMAP = ~(~uint256(0) >> 20);

    // below are permissions for note
    uint8 internal constant NOTE_SET_LINK_MODULE_FOR_NOTE = 1;
    uint8 internal constant NOTE_SET_MINT_MODULE_FOR_NOTE = 2;
    uint8 internal constant NOTE_SET_NOTE_URI = 3;
    uint8 internal constant NOTE_LOCK_NOTE = 4;
    uint8 internal constant NOTE_DELETE_NOTE = 5;
    uint256 internal constant DEFAULT_NOTE_PERMISSION_BITMAP = ~(~uint256(0) << 6);
}
