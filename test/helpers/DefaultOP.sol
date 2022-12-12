// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library DefaultOP {
    // set all methods for notes
    uint256 internal constant DEFAULT_NOTE_PERMISSION_BITMAP =
        (1 << 192) | (1 << 194) | (1 << 195) | (1 << 196) | (1 << 197);
}
