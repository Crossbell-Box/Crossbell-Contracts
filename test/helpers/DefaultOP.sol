// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library DefaultOP {
    // set all methods for notes
    uint256 internal constant UINT256_MAX = ~uint256(0);

    uint256 internal constant DEFAULT_NOTE_PERMISSION_BITMAP = (UINT256_MAX >> 251);
}
