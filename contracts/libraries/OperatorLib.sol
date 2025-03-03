// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.18;

import {Events} from "./Events.sol";
import {DataTypes} from "./DataTypes.sol";
import {OP} from "./OP.sol";
import {StorageLib} from "./StorageLib.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library OperatorLib {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice  Grants permission to a given operator for a character.
     * @param   characterId  The ID of the character to set operator for.
     * @param   operator  The operator address to set.
     * @param   permissionBitMap  The permission bitmap for the operator.
     */
    function grantOperatorPermissions(uint256 characterId, address operator, uint256 permissionBitMap) external {
        EnumerableSet.AddressSet storage operators = StorageLib.operatorsByCharacter()[characterId];
        if (permissionBitMap == 0) {
            operators.remove(operator);
        } else {
            operators.add(operator);
        }

        uint256 bitmap = _bitmapFilter(permissionBitMap);
        StorageLib.setOperatorsPermissionBitMap(characterId, operator, bitmap);
        emit Events.GrantOperatorPermissions(characterId, operator, bitmap);
    }

    /**
     * @notice Sets blocklist and allowlist for a specific note. Blocklist and allowlist are overwritten every time.
     *  @param characterId The character ID of the note owner.
     *  @param noteId The note ID to grant.
     *  @param blocklist The addresses list of blocked operators.
     *  @param allowlist The addresses list of allowed operators.
     */
    function grantOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blocklist,
        address[] calldata allowlist
    ) external {
        DataTypes.Operators4Note storage operators4Note = StorageLib.getOperators4Note(characterId, noteId);
        // clear all items in blocklist and allowlist first
        _clearOperators4Note(operators4Note);

        // update blocklist and allowlist
        _updateOperators4Note(operators4Note, blocklist, allowlist);

        emit Events.GrantOperators4Note(characterId, noteId, blocklist, allowlist);
    }

    function clearOperators(uint256 characterId) external {
        EnumerableSet.AddressSet storage _operators = StorageLib.operatorsByCharacter()[characterId];

        // clear operators
        uint256 len = _operators.length();
        address[] memory values = _operators.values();
        for (uint256 i = 0; i < len; i++) {
            // clear permission bitmap
            StorageLib.setOperatorsPermissionBitMap(characterId, values[i], 0);
            _operators.remove(values[i]);
        }
    }

    function _clearOperators4Note(DataTypes.Operators4Note storage operators4Note) internal {
        uint256 blocklistLength = operators4Note.blocklist.length();
        for (uint256 i = blocklistLength; i > 0;) {
            operators4Note.blocklist.remove(operators4Note.blocklist.at(i - 1));
            unchecked {
                i--;
            }
        }

        uint256 allowlistLength = operators4Note.allowlist.length();
        for (uint256 i = allowlistLength; i > 0;) {
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
        for (uint256 i = 0; i < blocklist.length;) {
            operators4Note.blocklist.add(blocklist[i]);
            unchecked {
                i++;
            }
        }
        for (uint256 i = 0; i < allowlist.length;) {
            operators4Note.allowlist.add(allowlist[i]);
            unchecked {
                i++;
            }
        }
    }

    /**
     * @dev _bitmapFilter unsets bits of non-existent permission IDs to zero. <br>
     * These unset permission IDs are meaningless now, but they are reserved for future use,
     * so it's best to leave them blank and avoid messing up with future methods.
     */
    function _bitmapFilter(uint256 bitmap) internal pure returns (uint256) {
        return bitmap & OP.ALLOWED_PERMISSION_BITMAP_MASK;
    }
}
