// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

// Operator Permission
library OP {
    // [0，20] for owner permissions
    uint8 internal constant SET_HANDLE = 0;
    uint8 internal constant SET_PRIMARY_CHARACTER_ID = 1;
    uint8 internal constant ADD_OPERATOR = 2;
    uint8 internal constant REMOVE_OPERATOR = 3;
    uint8 internal constant SET_SOCIAL_TOKEN = 4;
    uint8 internal constant GRANT_OPERATOR_PERMISSIONS = 5;

    // [21,80] for operator sign permissions
    uint8 internal constant SET_CHARACTER_URI = 21;
    uint8 internal constant SET_LINKLIST_URI = 22;
    uint8 internal constant LINK_CHARACTER = 23;

    // [81,100] for operator sync permissions
    uint8 internal constant POST_NOTE = 81;

    // [100,255] are reserved for future
}
