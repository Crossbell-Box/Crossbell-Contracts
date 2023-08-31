// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {StorageLib} from "./StorageLib.sol";
import {Constants} from "./Constants.sol";
import {
    ErrHandleExists,
    ErrNoteIsDeleted,
    ErrNoteNotExists,
    ErrNoteLocked,
    ErrHandleLengthInvalid,
    ErrHandleContainsInvalidCharacters
} from "./Error.sol";

// solhint-disable-next-line no-empty-blocks
library ValidationLib {
    function validateNoteExists(uint256 characterId, uint256 noteId) internal view {
        if (StorageLib.getNote(characterId, noteId).deleted) revert ErrNoteIsDeleted();
        if (noteId > StorageLib.getCharacter(characterId).noteCount) revert ErrNoteNotExists();
    }

    function validateNoteNotLocked(uint256 characterId, uint256 noteId) internal view {
        if (StorageLib.getNote(characterId, noteId).locked) revert ErrNoteLocked();
    }

    function validateHandleNotExists(bytes32 handleHash) internal view {
        if (StorageLib.characterIdByHandleHash()[handleHash] != 0) revert ErrHandleExists();
    }

    function validateHandle(string memory handle) internal pure {
        bytes memory byteHandle = bytes(handle);
        uint256 len = byteHandle.length;
        if (len > Constants.MAX_HANDLE_LENGTH || len < Constants.MIN_HANDLE_LENGTH)
            revert ErrHandleLengthInvalid();

        for (uint256 i = 0; i < len; ) {
            validateChar(byteHandle[i]);

            unchecked {
                ++i;
            }
        }
    }

    function validateChar(bytes1 c) internal pure {
        // char range: [0,9][a,z][-][_]
        if ((c < "0" || c > "z" || (c > "9" && c < "a")) && c != "-" && c != "_")
            revert ErrHandleContainsInvalidCharacters();
    }
}
