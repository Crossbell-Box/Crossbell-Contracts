// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./Events.sol";
import "./DataTypes.sol";
import "./OP.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library OperatorLogic {
    using EnumerableSet for EnumerableSet.AddressSet;

    function grantOperatorPermissions(
        uint256 characterId,
        address operator,
        uint256 permissionBitMap,
        mapping(uint256 => EnumerableSet.AddressSet) storage _operatorsByCharacter,
        mapping(uint256 => mapping(address => uint256)) storage _operatorsPermissionBitMap
    ) external {
        if (permissionBitMap == 0) {
            _operatorsByCharacter[characterId].remove(operator);
        } else {
            _operatorsByCharacter[characterId].add(operator);
        }

        uint256 bitmap = _bitmapFilter(permissionBitMap);
        _operatorsPermissionBitMap[characterId][operator] = bitmap;
        emit Events.GrantOperatorPermissions(characterId, operator, bitmap);
    }

    function grantOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata _blocklist,
        address[] calldata _allowlist,
        mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) storage _operators4Note
    ) external {
        // clear the blocklist first
        uint256 length = _operators4Note[characterId][noteId].blocklist.length();
        if (length > 0) {
            for (uint256 i = length; i > 0; --i) {
                _operators4Note[characterId][noteId].blocklist.remove(
                    _operators4Note[characterId][noteId].blocklist.at(i)
                );
            }
        }
        uint256 blocklistLength = _blocklist.length;
        // grant blocklist roles
        for (uint256 i = 0; i < blocklistLength; i++) {
            _operators4Note[characterId][noteId].blocklist.add(_blocklist[i]);
        }

        // clear the allowlist first
        length = _operators4Note[characterId][noteId].allowlist.length();
        if (length > 0) {
            for (uint256 i = length; i > 0; --i) {
                _operators4Note[characterId][noteId].allowlist.remove(
                    _operators4Note[characterId][noteId].allowlist.at(i)
                );
            }
        }

        uint256 allowlistLength = _allowlist.length;
        // grant allowlist roles
        for (uint256 i = 0; i < allowlistLength; i++) {
            _operators4Note[characterId][noteId].allowlist.add(_allowlist[i]);
        }

        emit Events.GrantOperators4Note(characterId, noteId, _blocklist, _allowlist);
    }

    function revokeOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blocklist,
        address[] calldata allowlist,
        mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) storage _operators4Note
    ) external {
        // revoke blocklist roles
        for (uint256 i = 0; i < blocklist.length; i++) {
            _operators4Note[characterId][noteId].blocklist.remove(blocklist[i]);
        }
        // revoke allowlist roles
        for (uint256 i = 0; i < allowlist.length; i++) {
            _operators4Note[characterId][noteId].allowlist.remove(allowlist[i]);
        }

        emit Events.RevokeOperators4Note(characterId, noteId, blocklist, allowlist);
    }

    /**
 * @dev _bitmapFilter unsets bits of non-existent permission IDs to zero. These unset permission IDs are
     meaningless now, but they are reserved for future use, so it's best to leave them blank and avoid messing
      up with future methods.
     */
    function _bitmapFilter(uint256 bitmap) internal pure returns (uint256) {
        return bitmap & OP.ALLOWED_PERMISSION_BITMAP_MASK;
    }
}
