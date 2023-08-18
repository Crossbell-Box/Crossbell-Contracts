// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.18;

import {DataTypes} from "./DataTypes.sol";

library StorageLib {
    uint256 public constant CHARACTERS_MAPPING_SLOT = 10;
    uint256 public constant CHARACTER_ID_BY_HANDLE_HASH_MAPPING_SLOT = 11;
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

    function characterIdByHandleHash()
        internal
        pure
        returns (mapping(bytes32 => uint256) storage _characterIdByHandleHash)
    {
        assembly {
            _characterIdByHandleHash.slot := CHARACTER_ID_BY_HANDLE_HASH_MAPPING_SLOT
        }
    }
}
