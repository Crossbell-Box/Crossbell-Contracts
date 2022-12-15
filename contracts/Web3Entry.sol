// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "./Web3EntryBase.sol";
import "./libraries/OP.sol";
import "./libraries/OperatorLogic.sol";

contract Web3Entry is Web3EntryBase {
    using EnumerableSet for EnumerableSet.AddressSet;

    // characterId => operator => permissionsBitMap
    mapping(uint256 => mapping(address => uint256)) internal _operatorsPermissionBitMap; // slot 25

    // characterId => noteId => Operators4Note
    // only for set note uri
    mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) internal _operators4Note; // slot 26

    function hasNotePermission(
        uint256 characterId,
        uint256 noteId,
        address operator
    ) external view returns (bool) {
        return _hasNotePermission(characterId, noteId, operator);
    }

    function _hasNotePermission(
        uint256 characterId,
        uint256 noteId,
        address operator
    ) internal view returns (bool) {
        // check blacklist
        if (_operators4Note[characterId][noteId].blacklist.contains(operator)) {
            return false;
        }
        // check whitelist
        if (_operators4Note[characterId][noteId].whitelist.contains(operator)) {
            return true;
        }
        // check character operator permission
        return _checkBit(_operatorsPermissionBitMap[characterId][operator], OP.SET_NOTE_URI);
    }

    function addOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blacklist,
        address[] calldata whitelist
    ) external override {
        _validateCallerPermission(characterId, OP.ADD_OPERATORS_FOR_NOTE);
        _validateNoteExists(characterId, noteId);
        OperatorLogic.addOperators4Note(characterId, noteId, blacklist, whitelist, _operators4Note);
    }

    function removeOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blacklist,
        address[] calldata whitelist
    ) external override {
        _validateCallerPermission(characterId, OP.REMOVE_OPERATORS_FOR_NOTE);
        _validateNoteExists(characterId, noteId);
        OperatorLogic.removeOperators4Note(
            characterId,
            noteId,
            blacklist,
            whitelist,
            _operators4Note
        );
    }

    function getOperators4Note(uint256 characterId, uint256 noteId)
        external
        view
        override
        returns (address[] memory blacklist, address[] memory whitelist)
    {
        blacklist = _operators4Note[characterId][noteId].blacklist.values();
        whitelist = _operators4Note[characterId][noteId].whitelist.values();
        return (blacklist, whitelist);
    }

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
        OperatorLogic.grantOperatorPermissions(
            characterId,
            operator,
            permissionBitMap,
            _operatorsByCharacter,
            _operatorsPermissionBitMap
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
                OperatorLogic.grantOperatorPermissions(
                    characterId,
                    operators[j],
                    OP.OPERATOR_SYNC_PERMISSION_BITMAP,
                    _operatorsByCharacter,
                    _operatorsPermissionBitMap
                );
            }
        }
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

    function _validateCallerPermission(uint256 characterId, uint256 permissionId)
        internal
        view
        override
    {
        address owner = ownerOf(characterId);
        if (msg.sender == owner) {
            // caller is character owner
        } else if (tx.origin == owner && msg.sender == periphery) {
            // caller is periphery
        } else if (_checkBit(_operatorsPermissionBitMap[characterId][msg.sender], permissionId)) {
            // caller has operator permission
        } else {
            // caller doesn't have corresponding permission,
            revert("NotEnoughPermission");
        }
    }

    function _validateCallerPermission4Note(uint256 characterId, uint256 noteId)
        internal
        view
        override
    {
        address owner = ownerOf(characterId);
        if (msg.sender == owner) {
            // caller is character owner
        } else if (tx.origin == owner && msg.sender == periphery) {
            // caller is periphery
        } else if (_hasNotePermission(characterId, noteId, msg.sender)) {
            // caller has note permission
        } else {
            // caller doesn't have corresponding permission,
            revert("NotEnoughPermissionForThisNote");
        }
    }

    /**
     * @dev _checkBit checks if the value of the i'th bit of x is 1
     */
    function _checkBit(uint256 x, uint256 i) internal pure returns (bool) {
        return (x >> i) & 1 == 1;
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
