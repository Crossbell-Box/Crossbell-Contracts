// SPDX-License-Identifier: MIT
// solhint-disable  private-vars-leading-underscore
pragma solidity 0.8.16;

import "./Events.sol";
import "./DataTypes.sol";
import "./OP.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library OperatorLogic {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice  Grant permission to a given operator for a character.
     * @param   characterId  The ID of the character to set operator for.
     * @param   operator  The operator address to set.
     * @param   permissionBitMap  The permission bitmap for the operator.
     */
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
        // clear all iterms in blocklist and allowlist first
        _clearOperators4Note(operators4Note);

        // update blocklist and allowlist
        _updateOperators4Note(operators4Note, blocklist, allowlist);

        emit Events.GrantOperators4Note(characterId, noteId, blocklist, allowlist);
    }

    function _clearOperators4Note(DataTypes.Operators4Note storage operators4Note) internal {
        uint256 blocklistLength = operators4Note.blocklist.length();
        for (uint256 i = blocklistLength; i > 0; ) {
            operators4Note.blocklist.remove(operators4Note.blocklist.at(i - 1));
            unchecked {
                i--;
            }
        }

        uint256 allowlistLength = operators4Note.allowlist.length();
        for (uint256 i = allowlistLength; i > 0; ) {
            operators4Note.allowlist.remove(operators4Note.allowlist.at(i - 1));
            unchecked {
                i--;
            }
        }
    }

    function _updateOperators4Note(
        DataTypes.Operators4Note storage operators4Note,
        address[] calldata blocklist,
        address[] calldata allowlist
    ) internal {
        // grant blocklist roles
        for (uint256 i = 0; i < blocklist.length; ) {
            operators4Note.blocklist.add(blocklist[i]);
            unchecked {
                i++;
            }
        }
        for (uint256 i = 0; i < allowlist.length; ) {
            operators4Note.allowlist.add(allowlist[i]);
            unchecked {
                i++;
            }
        }
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
