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
    uint256 internal constant OPERATORSIGN_PERMISSION_BITMAP = ~(~uint256(0) >> 80);

    // [236, 255] for operator sync permissio
    uint8 internal constant POST_NOTE = 236;
    uint256 internal constant OPERATORSYNC_PERMISSION_BITMAP = ~(~uint256(0) >> 20);
}
