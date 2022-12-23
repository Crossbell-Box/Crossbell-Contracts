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

    /**
     @notice Set blocklist and allowlist for a specifc note. Blocklist and allowlist are overwritten every time.
     @dev The _blocklistSetIndex and _allowlistSetIndex increase by 1 everytime this function is called.
     @param characterId The character Id of the note owner.
     @param  noteId The note Id to grant.
     @param _blocklist The addresses list of blocked operators.
     @param _allowlist The addresses list of allowed operators.
     */
    function grantOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata _blocklist,
        address[] calldata _allowlist,
        mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) storage _operators4Note
    ) external {
        uint256 blocklistLength = _blocklist.length;
        _operators4Note[characterId][noteId].blocklistSetIndex++;
        uint256 currentIndex = _operators4Note[characterId][noteId].blocklistSetIndex; // the current index of blocklistSet
        // grant blocklist roles
        for (uint256 i = 0; i < blocklistLength; i++) {
            _operators4Note[characterId][noteId].blocklistSet[currentIndex].add(_blocklist[i]);
        }

        uint256 allowlistLength = _allowlist.length;
        _operators4Note[characterId][noteId].allowlistSetIndex++;
        currentIndex = _operators4Note[characterId][noteId].allowlistSetIndex; // the current index of allowlistSet
        // grant blocklist roles
        for (uint256 i = 0; i < allowlistLength; i++) {
            _operators4Note[characterId][noteId].allowlistSet[currentIndex].add(_allowlist[i]);
        }
        emit Events.GrantOperators4Note(characterId, noteId, _blocklist, _allowlist);
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
