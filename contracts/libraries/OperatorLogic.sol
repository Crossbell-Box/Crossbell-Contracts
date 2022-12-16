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

    function addOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blacklist,
        address[] calldata whitelist,
        mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) storage _operators4Note
    ) external {
        // add blacklist
        for (uint256 i = 0; i < blacklist.length; i++) {
            _operators4Note[characterId][noteId].blacklist.add(blacklist[i]);
        }
        // add whitelist
        for (uint256 i = 0; i < whitelist.length; i++) {
            _operators4Note[characterId][noteId].whitelist.add(whitelist[i]);
        }

        emit Events.AddOperators4Note(characterId, noteId, blacklist, whitelist);
    }

    function removeOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blacklist,
        address[] calldata whitelist,
        mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) storage _operators4Note
    ) external {
        // remove blacklist
        for (uint256 i = 0; i < blacklist.length; i++) {
            _operators4Note[characterId][noteId].blacklist.remove(blacklist[i]);
        }
        // remove whitelist
        for (uint256 i = 0; i < whitelist.length; i++) {
            _operators4Note[characterId][noteId].whitelist.remove(whitelist[i]);
        }

        emit Events.RemoveOperators4Note(characterId, noteId, blacklist, whitelist);
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
