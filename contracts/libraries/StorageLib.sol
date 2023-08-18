// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.18;

import {DataTypes} from "./DataTypes.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library StorageLib {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public constant CHARACTERS_MAPPING_SLOT = 10;
    uint256 public constant CHARACTER_ID_BY_HANDLE_HASH_MAPPING_SLOT = 11;
    uint256 public constant NOTES_MAPPING_SLOT = 14;
    uint256 public constant OPERATORS_BY_CHARACTER_MAPPING_SLOT = 24;
    uint256 public constant OPERATORS_PERMISSION_BIT_MAP_MAPPING_SLOT = 25;
    uint256 public constant OPERATOR_FOR_NOTE_MAPPING_SLOT = 26;
    uint256 public constant SIG_NONCES_MAPPING_SLOT = 28;

    function nonces() internal pure returns (mapping(address => uint256) storage _nonces) {
        assembly {
            _nonces.slot := SIG_NONCES_MAPPING_SLOT
        }
    }

    function getCharacter(
        uint256 characterId
    ) internal pure returns (DataTypes.Character storage _character) {
        assembly {
            mstore(0, characterId)
            mstore(32, CHARACTERS_MAPPING_SLOT)
            _character.slot := keccak256(0, 64)
        }
    }

    function getNote(
        uint256 characterId,
        uint256 noteId
    ) internal pure returns (DataTypes.Note storage _note) {
        assembly {
            mstore(0, characterId)
            mstore(32, NOTES_MAPPING_SLOT)
            mstore(32, keccak256(0, 64))
            mstore(0, noteId)
            _note.slot := keccak256(0, 64)
        }
    }

    function characterIdByHandleHash()
        internal
        pure
        returns (mapping(bytes32 => uint256) storage _characterIdByHandleHash)
    {
        assembly {
            _characterIdByHandleHash.slot := CHARACTER_ID_BY_HANDLE_HASH_MAPPING_SLOT
        }
    }

    function operatorsByCharacter()
        internal
        pure
        returns (mapping(uint256 => EnumerableSet.AddressSet) storage _operatorsByCharacter)
    {
        assembly {
            _operatorsByCharacter.slot := OPERATORS_BY_CHARACTER_MAPPING_SLOT
        }
    }

    function operatorsPermissionBitMap()
        internal
        pure
        returns (mapping(uint256 => mapping(address => uint256)) storage _operatorsPermissionBitMap)
    {
        assembly {
            _operatorsPermissionBitMap.slot := OPERATORS_PERMISSION_BIT_MAP_MAPPING_SLOT
        }
    }

    function getOperators4Note(
        uint256 characterId,
        uint256 noteId
    ) internal pure returns (DataTypes.Operators4Note storage _operators4Note) {
        assembly {
            mstore(0, characterId)
            mstore(32, OPERATOR_FOR_NOTE_MAPPING_SLOT)
            mstore(32, keccak256(0, 64))
            mstore(0, noteId)
            _operators4Note.slot := keccak256(0, 64)
        }
    }
}
