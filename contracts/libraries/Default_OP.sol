// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

/**
 * @dev For most cases, we recommand simply granting operators the OPERATORSIGN_PERMISSION_BITMAP, 
        which gives operator full permissions aside from owner permissions and future permissions, but for 
        those who're more aware of access control, the custom permission bitmap is all yours, 
        and you can find every customizable methods below.
        
        `OPERATORSIGN_PERMISSION_BITMAP` have access to all methods in `OPERATORSIGN_PERMISSION_BITMAP` 
        plus more permissions for signing.
*/
library DEFAULT_OP {
    uint256 internal constant DEFAULT_PERMISSION_BITMAP = ~uint256(0) << 20;
    uint256 internal constant OPERATORSIGN_PERMISSION_BITMAP = ~uint256(0) << 176;
    uint256 internal constant OPERATORSYNC_PERMISSION_BITMAP = ~uint256(0) << 236;
    uint256 internal constant DEFAULT_NOTE_PERMISSION_BITMAP = ~uint256(0) >> 250;
}
