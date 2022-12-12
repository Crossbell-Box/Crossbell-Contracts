// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library DefaultOP {
    uint256 internal constant DEFAULT_PERMISSION_BITMAP =
        (~uint256(0) << 4) &
            ((~uint256(0) >> 252) | ((~uint256(0) << 176) & (~uint256(0) >> 52)) | (1 << 236));
    uint256 internal constant DEFAULT_NOTE_PERMISSION_BITMAP =
        (1 << 192) | (1 << 194) | (1 << 195) | (1 << 196) | (1 << 197);
}
