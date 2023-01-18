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
     @notice Set blocklist and allowlist for a specific note. Blocklist and allowlist are overwritten every time.
     @dev The blocklistId and allowlistId increase by 1 everytime this function is called.
     @param characterId The character Id of the note owner.
     @param noteId The note Id to grant.
     @param blocklist The addresses list of blocked operators.
     @param allowlist The addresses list of allowed operators.
     */
    function grantOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blocklist,
        address[] calldata allowlist,
        mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) storage _operators4Note
    ) external {
        DataTypes.Operators4Note storage operators4Note = _operators4Note[characterId][noteId];

        operators4Note.blocklistId++;
        uint256 currentId = operators4Note.blocklistId; // the current id of blocklists
        // grant blocklist roles
        for (uint256 i = 0; i < blocklist.length; i++) {
            operators4Note.blocklists[currentId].add(blocklist[i]);
        }

        operators4Note.allowlistId++;
        currentId = operators4Note.allowlistId; // the current id of allowlists
        // grant allowlist roles
        for (uint256 i = 0; i < allowlist.length; i++) {
            operators4Note.allowlists[currentId].add(allowlist[i]);
        }
        emit Events.GrantOperators4Note(characterId, noteId, blocklist, allowlist);
    }

    /**
     * @dev _bitmapFilter unsets bits of non-existent permission IDs to zero.
     * These unset permission IDs are meaningless now, but they are reserved for future use,
     * so it's best to leave them blank and avoid messing up with future methods.
     */
    function _bitmapFilter(uint256 bitmap) internal pure returns (uint256) {
        return bitmap & OP.ALLOWED_PERMISSION_BITMAP_MASK;
    }
}
