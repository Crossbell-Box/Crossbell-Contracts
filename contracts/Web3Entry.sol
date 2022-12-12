// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Web3EntryBase.sol";
import "./libraries/OP.sol";

contract Web3Entry is Web3EntryBase {
    using EnumerableSet for EnumerableSet.AddressSet;

    // characterId => operator => permissionsBitMap
    mapping(uint256 => mapping(address => uint256)) internal _operatorsPermissionBitMap; // slot 25

    // characterId => noteId => operator => permissionsBitMap4Note
    mapping(uint256 => mapping(uint256 => mapping(address => uint256)))
        internal _operatorsPermission4NoteBitMap; // slot 26

    /**
     * @notice Grant an address as an operator and authorize it with custom permissions.
     * @param characterId ID of your character that you want to authorize.
     * @param operator Address to grant operator permissions to.
     * @param permissionBitMap Bitmap used for finer grained operator permissions controls.
     * @dev Every bit in permissionBitMap stands for a corresponding method in Web3Entry. more details in OP.sol.
     */
    function grantOperatorPermissions(
        uint256 characterId,
        address operator,
        uint256 permissionBitMap
    ) external override {
        _validateCallerPermission(characterId, OP.GRANT_OPERATOR_PERMISSIONS);
        if (permissionBitMap == 0) {
            _operatorsByCharacter[characterId].remove(operator);
        } else {
            _operatorsByCharacter[characterId].add(operator);
        }
        _setOperatorPermissions(characterId, operator, _bitmapFilter(permissionBitMap));
    }

    /**
     * @notice Grant an address as an operator and authorize it with custom permissions for a single note.
     * @param characterId ID of your character that you want to authorize.
     * @param noteId ID of your note that you want to authorize.
     * @param operator Address to grant operator permissions to.
     * @param permissionBitMap an uint256 bitmap used for finer grained operator permissions controls over notes
     * @dev Every bit in permissionBitMap stands for a single note that this character posted.
     * The level of note permissions is above operator permissions. When both note permissions and operator permissions exist at the same time, note permissions prevail.
     * With grantOperatorPermissions4Note, users can restrict permissions on individual notes,
     * for example: I authorize bob to set uri for my notes, but only for my third notes(noteId = 3).
     */
    function grantOperatorPermissions4Note(
        uint256 characterId,
        uint256 noteId,
        address operator,
        uint256 permissionBitMap
    ) external override {
        _validateCallerPermission(characterId, OP.GRANT_OPERATOR_PERMISSIONS_FOR_NOTE);
        _validateNoteExists(characterId, noteId);
        _operatorsPermission4NoteBitMap[characterId][noteId][operator] = permissionBitMap;
        emit Events.GrantOperatorPermissions4Note(
            characterId,
            noteId,
            operator,
            _bitmapFilter(permissionBitMap)
        );
    }

    /**
     * @notice Migrates operators permissions to operatorsSignBitMap
     * @param characterIds List of characters to migrate.
     * @dev `addOperator`, `removeOperator`, `setOperator` will all be deprecated soon. We recommend to use
     *  `migrateOperator` to grant OPERATOR_SIGN_PERMISSION_BITMAP to all previous operators.
     */
    function migrateOperator(uint256[] calldata characterIds) external {
        // set default permissions bitmap
        for (uint256 i = 0; i < characterIds.length; ++i) {
            uint256 characterId = characterIds[i];

            address[] memory operators = _operatorsByCharacter[characterId].values();
            for (uint256 j = 0; j < operators.length; ++j) {
                _setOperatorPermissions(
                    characterId,
                    operators[j],
                    OP.OPERATOR_SIGN_PERMISSION_BITMAP
                );
            }
        }
    }

    /**
     * @notice Check if an address is the operator of a character.
     * @param characterId  ID of character to query.
     * @param operator operator address to query.
     * @return true if the address is the operator of a character, otherwise false.
     */
    function isOperator(uint256 characterId, address operator)
        external
        view
        override
        returns (bool)
    {
        uint256 bitMap = _operatorsPermissionBitMap[characterId][operator];
        return (bitMap == 0) ? false : true;
    }

    function addOperator(uint256 characterId, address operator) external override {
        _validateCallerIsCharacterOwner(characterId);
        _operatorsByCharacter[characterId].add(operator);
        _setOperatorPermissions(characterId, operator, OP.OPERATOR_SIGN_PERMISSION_BITMAP);

        // emit AddOperator
        emit Events.AddOperator(characterId, operator, block.timestamp);
    }

    /**
     * @notice Cancel authorization on operators and remove them from operator list.
     */
    function removeOperator(uint256 characterId, address operator) external override {
        _validateCallerIsCharacterOwner(characterId);
        _operatorsByCharacter[characterId].remove(operator);
        _setOperatorPermissions(characterId, operator, 0);

        // emit RemoveOperator
        emit Events.RemoveOperator(characterId, operator, block.timestamp);
    }

    // @notice users can't remove an operator by setOperator
    function setOperator(uint256 characterId, address operator) external override {
        _validateCallerIsCharacterOwner(characterId);
        if (operator == address(0)) {
            address oldOperator = _operatorByCharacter[characterId];
            _operatorsByCharacter[characterId].remove(oldOperator);
            _setOperatorPermissions(characterId, oldOperator, 0);
        } else {
            _operatorsByCharacter[characterId].add(operator);
            _setOperatorPermissions(characterId, operator, OP.OPERATOR_SIGN_PERMISSION_BITMAP);
        }

        // emit SetOperator
        emit Events.SetOperator(characterId, operator, block.timestamp);
    }

    /**
     * @notice Get permission bitmap of an operator.
     * @param characterId ID of character that you want to check.
     * @param operator Address to grant operator permissions to.
     * @return Permission bitmap of this operator.
     */
    function getOperatorPermissions(uint256 characterId, address operator)
        external
        view
        override
        returns (uint256)
    {
        return _operatorsPermissionBitMap[characterId][operator];
    }

    /**
     * @notice Get permission bitmap of an operator for a note.
     * @param characterId ID of character that you want to check.
     * @param noteId ID of note that you want to authorize.
     * @param operator Address to grant operator permissions to.
     * @return Permission bitmap of this operator.
     */
    function getOperatorPermissions4Note(
        uint256 characterId,
        uint256 noteId,
        address operator
    ) external view override returns (uint256) {
        return _operatorsPermission4NoteBitMap[characterId][noteId][operator];
    }

    function _validateCallerPermission(uint256 characterId, uint256 permissionId)
        internal
        view
        override
    {
        address owner = ownerOf(characterId);

        if (msg.sender == owner) {
            // check if it's owner
        } else if (tx.origin == owner && msg.sender == periphery) {
            // check if it's periphery
        } else if (
            _checkBit(_operatorsPermissionBitMap[characterId][msg.sender], permissionId)
        ) {} else {
            // if it doesn't have corresponding permission,
            revert("NotEnoughPermission"); // then this caller is nothing, we need to revert.
        }
    }

    function _validateCallerPermission4Note(
        uint256 characterId,
        uint256 noteId,
        uint256 permissionId
    ) internal view override {
        address owner = ownerOf(characterId);
        if (msg.sender == owner) {
            // check if it's owner
        } else if (tx.origin == owner && msg.sender == periphery) {
            // check if it's periphery
        } else if (_operatorsPermission4NoteBitMap[characterId][noteId][msg.sender] == 0) {
            if (_checkBit(_operatorsPermissionBitMap[characterId][msg.sender], permissionId)) {
                // check if it has operator permission for this method and if it's open to all notes
            } else {
                revert("NotEnoughPermissionForThisNote");
            }
        } else if (
            ((_operatorsPermission4NoteBitMap[characterId][noteId][msg.sender] >> permissionId) &
                1) == 1
        ) {
            // check if it has note permission
        } else {
            // if it doesn't have corresponding permission,
            revert("NotEnoughPermissionForThisNote"); // then this caller is nothing, we need to revert.
        }
    }

    /**
     * @dev _bitmapFilter unsets bits of non-existent permission IDs to zero. These unset permission IDs are 
     meaningless now, but they are reserved for future use, so it's best to leave them blank and avoid messing
      up with future methods.
     */
    function _bitmapFilter(uint256 bitmap) internal pure returns (uint256) {
        return bitmap & OP.ALLOWED_PERMISSION_BITMAP_MASK;
    }

    /**
     * @dev _checkBit checks if the value of the i'th bit of x is 1
     */
    function _checkBit(uint256 x, uint256 i) internal pure returns (bool) {
        return (x >> i) & 1 == 1;
    }

    function _setOperatorPermissions(
        uint256 characterId,
        address operator,
        uint256 permissionBitMap
    ) internal {
        _operatorsPermissionBitMap[characterId][operator] = permissionBitMap;
        emit Events.GrantOperatorPermissions(characterId, operator, permissionBitMap);
    }

    /**
     * @dev Operator lists will be reset to blank before the characters are transferred in order to grant the
     * whole control power to receivers of character transfers.
     * Permissions4Note is left unset, because permissions for notes are always stricter than default.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        uint256 len = _operatorsByCharacter[tokenId].length();
        address[] memory operators = _operatorsByCharacter[tokenId].values();
        for (uint256 i = 0; i < len; i++) {
            _operatorsPermissionBitMap[tokenId][operators[i]] = 0;
            _operatorsByCharacter[tokenId].remove(operators[i]);
        }

        if (_primaryCharacterByAddress[from] != 0) {
            _primaryCharacterByAddress[from] = 0;
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }
}
