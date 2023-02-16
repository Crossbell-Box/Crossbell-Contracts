// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.16;

/**
* @dev every uint8 stands for a single method in Web3Entry.sol.
* For most cases, we recommend simply granting operators the OPERATOR_SIGN_PERMISSION_BITMAP,
* which gives operator full permissions aside from owner permissions and future permissions, but for
* those who're more aware of access control, the custom permission bitmap is all yours,
* and you can find every customizable methods below.

* `OPERATOR_SIGN_PERMISSION_BITMAP` have access to all methods in `OPERATOR_SYNC_PERMISSION_BITMAP`
* plus more permissions for signing.

* Permissions are laid out in a increasing order of power.
* so the bitmap looks like this:

* |   opSync   |   opSign   |   future   |  owner   |
* |------------|------------|------------|----------|
* |255------236|235------176|175-------21|20-------0|
*/

library OP {
    uint256 internal constant UINT256_MAX = ~uint256(0);

    // [0,20] for owner permissions
    uint8 internal constant SET_HANDLE = 0;
    uint8 internal constant SET_SOCIAL_TOKEN = 1;
    uint8 internal constant GRANT_OPERATOR_PERMISSIONS = 2;
    // uint8 internal constant GRANT_OPERATOR_PERMISSIONS_FOR_NOTE = 3;
    uint8 internal constant GRANT_OPERATORS_FOR_NOTE = 3;
    // set [0, 3] bit index
    uint256 internal constant OWNER_PERMISSION_BITMAP = ~(UINT256_MAX << 4);

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
    uint8 internal constant LINK_ANYURI = 187;
    uint8 internal constant UNLINK_ANYURI = 188;
    uint8 internal constant LINK_LINKLIST = 189;
    uint8 internal constant UNLINK_LINKLIST = 190;
    uint8 internal constant SET_LINK_MODULE_FOR_CHARACTER = 191;
    uint8 internal constant SET_LINK_MODULE_FOR_NOTE = 192;
    uint8 internal constant SET_LINK_MODULE_FOR_LINKLIST = 193;
    // slither-disable-next-line similar-names
    uint8 internal constant SET_MINT_MODULE_FOR_NOTE = 194;
    uint8 internal constant SET_NOTE_URI = 195;
    uint8 internal constant LOCK_NOTE = 196;
    uint8 internal constant DELETE_NOTE = 197;
    uint8 internal constant POST_NOTE_FOR_CHARACTER = 198;
    uint8 internal constant POST_NOTE_FOR_ADDRESS = 199;
    uint8 internal constant POST_NOTE_FOR_LINKLIST = 200;
    uint8 internal constant POST_NOTE_FOR_NOTE = 201;
    uint8 internal constant POST_NOTE_FOR_ERC721 = 202;
    uint8 internal constant POST_NOTE_FOR_ANYURI = 203;
    // set [176,204] bit index

    // [236, 255] for operator sync permissions
    uint8 internal constant POST_NOTE = 236;
    // set 236 bit index
    uint256 internal constant POST_NOTE_PERMISSION_BITMAP = 1 << POST_NOTE;

    // DEFAULT_PERMISSION_BITMAP has operator sign permissions and operator sync permissions
    uint256 internal constant DEFAULT_PERMISSION_BITMAP =
        ((UINT256_MAX << 176) & ~(UINT256_MAX << 204)) | POST_NOTE_PERMISSION_BITMAP;

    // bitmap mask with all current-in-use methods to 1
    uint256 internal constant ALLOWED_PERMISSION_BITMAP_MASK =
        OWNER_PERMISSION_BITMAP | DEFAULT_PERMISSION_BITMAP;
}
