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
        _validateCallerIsCharacterOwner(characterId);
        if (permissionBitMap == 0) {
            _operatorsByCharacter[characterId].remove(operator);
        } else {
            _operatorsByCharacter[characterId].add(operator);
        }
        _setOperatorPermissions(characterId, operator, permissionBitMap);
    }

    /**
     * @notice Grant an address as an operator and authorize it with custom permissions for a single note.
     * @param characterId ID of your character that you want to authorize.
     * @param noteId ID of your note that you want to authorize.
     * @param operator Address to grant operator permissions to.
     * @param permissionBitMap an uint256 bitmap used for finer grained operator permissions controls over notes
     * @dev Every bit in permissionBitMap stands for a single note that this character posted.
     * The notes are open to all operators who are granted with note permissions by default, until the Permissions4Note are set.
     * With grantOperatorPermissions4Note, users can restrict permissions on individual notes,
     * for example: I authorize bob to set uri for my notes, but only for my third notes(noteId = 3).
     */
    function grantOperatorPermissions4Note(
        uint256 characterId,
        uint256 noteId,
        address operator,
        uint256 permissionBitMap
    ) external override {
        _validateCallerIsCharacterOwner(characterId);
        _validateNoteExists(characterId, noteId);
        _operatorsPermission4NoteBitMap[characterId][noteId][operator] = permissionBitMap;
        emit Events.GrantOperatorPermissions4Note(characterId, noteId, operator, permissionBitMap);
    }

    /**
     * @notice Get operator list of a character. This operatorList has only a sole purpose, which is
     * keeping records of keys of `operatorsPermissionBitMap`. Thus, addresses queried by this function
     * not always have operator permissions. Keep in mind don't use this function to check
     * authorizations!!!
     * @param characterId ID of your character that you want to check.
     * @return All keys of operatorsPermission4NoteBitMap.
     */
    function getOperators(uint256 characterId) external view override returns (address[] memory) {
        return _operatorsByCharacter[characterId].values();
    }

    /**
     * @notice Migrates operators permissions to operatorsAuthBitMap
     * @param characterIds List of characters to migrate.
     * @dev `addOperator`, `removeOperator`, `setOperator` will all be deprecated soon. We recommend to use
     *  `migrateOperator` to grant OPERATOR_SIGN_PERMISSION_BITMAP to all previous operators.
     */
    function migrateOperator(uint256[] calldata characterIds) external {
        // set default permissions bitmap
        for (uint256 i = 0; i < characterIds.length; ++i) {
            uint256 characterId = characterIds[i];
            address operator = _operatorByCharacter[characterId];
            if (operator != address(0)) {
                _setOperatorPermissions(characterId, operator, OP.OPERATOR_SIGN_PERMISSION_BITMAP);
            }

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
     * @notice Get permission bitmap of an opertor.
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

    // owner permission
    function setHandle(uint256 characterId, string calldata newHandle) external override {
        _validateCallerPermission(characterId, OP.SET_HANDLE);

        CharacterLogic.setHandle(characterId, newHandle, _characterIdByHandleHash, _characterById);
    }

    // owner permission
    function setSocialToken(uint256 characterId, address tokenAddress) external override {
        _validateCallerPermission(characterId, OP.SET_SOCIAL_TOKEN);

        CharacterLogic.setSocialToken(characterId, tokenAddress, _characterById);
    }

    function _setCharacterUri(uint256 profileId, string memory newUri) public override {
        _validateCallerPermission(profileId, OP.SET_CHARACTER_URI);
        _characterById[profileId].uri = newUri;

        emit Events.SetCharacterUri(profileId, newUri);
    }

    function setLinklistUri(uint256 linklistId, string calldata uri) external override {
        uint256 ownerCharacterId = ILinklist(_linklist).getOwnerCharacterId(linklistId);
        _validateCallerPermission(ownerCharacterId, OP.SET_LINK_LIST_URI);

        ILinklist(_linklist).setUri(linklistId, uri);
    }

    function linkCharacter(DataTypes.linkCharacterData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_CHARACTER);
        _validateCharacterExists(vars.toCharacterId);

        LinkLogic.linkCharacter(
            vars.fromCharacterId,
            vars.toCharacterId,
            vars.linkType,
            vars.data,
            IERC721Enumerable(this).ownerOf(vars.fromCharacterId),
            _linklist,
            _characterById[vars.toCharacterId].linkModule,
            _attachedLinklists
        );
    }

    function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_CHARACTER);

        LinkLogic.unlinkCharacter(
            vars,
            IERC721Enumerable(this).ownerOf(vars.fromCharacterId),
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    function createThenLinkCharacter(DataTypes.createThenLinkCharacterData calldata vars)
        external
        override
    {
        _validateCallerPermission(vars.fromCharacterId, OP.CREATE_THEN_LINK_CHARACTER);
        _createThenLinkCharacter(vars.fromCharacterId, vars.to, vars.linkType, "0x");
    }

    function linkNote(DataTypes.linkNoteData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_NOTE);
        _validateNoteExists(vars.toCharacterId, vars.toNoteId);

        LinkLogic.linkNote(
            vars,
            IERC721Enumerable(this).ownerOf(vars.fromCharacterId),
            _linklist,
            _noteByIdByCharacter,
            _attachedLinklists
        );
    }

    function unlinkNote(DataTypes.unlinkNoteData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_NOTE);

        LinkLogic.unlinkNote(vars, _linklist, _attachedLinklists);
    }

    function linkERC721(DataTypes.linkERC721Data calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_ERC721);
        _validateERC721Exists(vars.tokenAddress, vars.tokenId);

        LinkLogic.linkERC721(vars, _linklist, _attachedLinklists);
    }

    function unlinkERC721(DataTypes.unlinkERC721Data calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_ERC721);

        LinkLogic.unlinkERC721(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    function linkAddress(DataTypes.linkAddressData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_ADDRESS);

        LinkLogic.linkAddress(vars, _linklist, _attachedLinklists);
    }

    function unlinkAddress(DataTypes.unlinkAddressData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_ADDRESS);

        LinkLogic.unlinkAddress(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    function linkAnyUri(DataTypes.linkAnyUriData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_ANY_URI);

        LinkLogic.linkAnyUri(vars, _linklist, _attachedLinklists);
    }

    function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_ANY_URI);

        LinkLogic.unlinkAnyUri(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    function linkLinklist(DataTypes.linkLinklistData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_LINK_LIST);

        LinkLogic.linkLinklist(vars, _linklist, _attachedLinklists);
    }

    function unlinkLinklist(DataTypes.unlinkLinklistData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_LINK_LIST);

        LinkLogic.unlinkLinklist(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    /*
    function setLinkModule4Character(DataTypes.setLinkModule4CharacterData calldata vars)
        external
        override
    {
        _validateCallerPermission(vars.characterId, OP.SET_LINK_MODULE_FOR_CHARACTER);

        CharacterLogic.setCharacterLinkModule(
            vars.characterId,
            vars.linkModule,
            vars.linkModuleInitData,
            _characterById[vars.characterId]
        );
    }


    function setLinkModule4Note(DataTypes.setLinkModule4NoteData calldata vars) external override {
        _validateCallerPermission(vars.characterId, OP.SET_LINK_MODULE_FOR_NOTE);
        _validateCallerPermission4Note(
            vars.characterId,
            vars.noteId,
            OP.NOTE_SET_LINK_MODULE_FOR_NOTE
        );
        _validateNoteExists(vars.characterId, vars.noteId);

        LinkModuleLogic.setLinkModule4Note(
            vars.characterId,
            vars.noteId,
            vars.linkModule,
            vars.linkModuleInitData,
            _noteByIdByCharacter
        );
    }


    function setLinkModule4Linklist(DataTypes.setLinkModule4LinklistData calldata vars)
        external
        override
    {
        // get character id of the owner of this linklist
        uint256 ownerCharacterId = ILinklist(_linklist).getOwnerCharacterId(vars.linklistId);

        _validateCallerPermission(ownerCharacterId, OP.SET_LINK_MODULE_FOR_LINK_LIST);

        LinkModuleLogic.setLinkModule4Linklist(
            vars.linklistId,
            vars.linkModule,
            vars.linkModuleInitData,
            _linkModules4Linklist
        );
    }
    */

    function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external override {
        _validateCallerPermission(vars.characterId, OP.SET_MINT_MODULE_FOR_NOTE);
        _validateCallerPermission4Note(
            vars.characterId,
            vars.noteId,
            OP.NOTE_SET_MINT_MODULE_FOR_NOTE
        );
        _validateNoteExists(vars.characterId, vars.noteId);

        LinkModuleLogic.setMintModule4Note(
            vars.characterId,
            vars.noteId,
            vars.mintModule,
            vars.mintModuleInitData,
            _noteByIdByCharacter
        );
    }

    function postNote(DataTypes.PostNoteData calldata vars) external override returns (uint256) {
        _validateCallerPermission(vars.characterId, OP.POST_NOTE);

        uint256 noteId = ++_characterById[vars.characterId].noteCount;

        PostLogic.postNoteWithLink(vars, noteId, 0, 0, "", _noteByIdByCharacter);
        return noteId;
    }

    function setNoteUri(
        uint256 characterId,
        uint256 noteId,
        string calldata newUri
    ) external override {
        _validateCallerPermission(characterId, OP.SET_NOTE_URI);
        _validateCallerPermission4Note(characterId, noteId, OP.NOTE_SET_NOTE_URI);
        _validateNoteExists(characterId, noteId);
        PostLogic.setNoteUri(characterId, noteId, newUri, _noteByIdByCharacter);
    }

    /**
     * @notice lockNote put a note into a immutable state where no modifications are allowed. You should call this method to announce that this is the final version.
     */
    function lockNote(uint256 characterId, uint256 noteId) external override {
        _validateCallerPermission(characterId, OP.LOCK_NOTE);
        _validateCallerPermission4Note(characterId, noteId, OP.NOTE_LOCK_NOTE);
        _validateNoteExists(characterId, noteId);

        _noteByIdByCharacter[characterId][noteId].locked = true;

        emit Events.LockNote(characterId, noteId);
    }

    function deleteNote(uint256 characterId, uint256 noteId) external override {
        _validateCallerPermission(characterId, OP.DELETE_NOTE);
        _validateCallerPermission4Note(characterId, noteId, OP.NOTE_DELETE_NOTE);
        _validateNoteExists(characterId, noteId);

        _noteByIdByCharacter[characterId][noteId].deleted = true;

        emit Events.DeleteNote(characterId, noteId);
    }

    function postNote4Character(DataTypes.PostNoteData calldata postNoteData, uint256 toCharacterId)
        external
        override
        returns (uint256)
    {
        _validateCallerPermission(postNoteData.characterId, OP.POST_NOTE_FOR_CHARACTER);

        bytes32 linkItemType = Constants.NoteLinkTypeCharacter;
        bytes32 linkKey = bytes32(toCharacterId);
        uint256 noteId = ++_characterById[postNoteData.characterId].noteCount;

        PostLogic.postNoteWithLink(
            postNoteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(toCharacterId),
            _noteByIdByCharacter
        );

        return noteId;
    }

    function postNote4Address(DataTypes.PostNoteData calldata noteData, address ethAddress)
        external
        override
        returns (uint256)
    {
        _validateCallerPermission(noteData.characterId, OP.POST_NOTE_FOR_ADDRESS);

        bytes32 linkItemType = Constants.NoteLinkTypeAddress;
        bytes32 linkKey = bytes32(uint256(uint160(ethAddress)));
        uint256 noteId = ++_characterById[noteData.characterId].noteCount;

        PostLogic.postNoteWithLink(
            noteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(ethAddress),
            _noteByIdByCharacter
        );

        return noteId;
    }

    function postNote4Linklist(DataTypes.PostNoteData calldata noteData, uint256 toLinklistId)
        external
        override
        returns (uint256)
    {
        _validateCallerPermission(noteData.characterId, OP.POST_NOTE_FOR_LINK_LIST);

        bytes32 linkItemType = Constants.NoteLinkTypeLinklist;
        bytes32 linkKey = bytes32(toLinklistId);
        uint256 noteId = ++_characterById[noteData.characterId].noteCount;

        PostLogic.postNoteWithLink(
            noteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(toLinklistId),
            _noteByIdByCharacter
        );

        return noteId;
    }

    function postNote4Note(
        DataTypes.PostNoteData calldata postNoteData,
        DataTypes.NoteStruct calldata note
    ) external override returns (uint256) {
        _validateCallerPermission(postNoteData.characterId, OP.POST_NOTE_FOR_NOTE);

        bytes32 linkItemType = Constants.NoteLinkTypeNote;
        bytes32 linkKey = ILinklist(_linklist).addLinkingNote(0, note.characterId, note.noteId);
        uint256 noteId = ++_characterById[postNoteData.characterId].noteCount;

        PostLogic.postNoteWithLink(
            postNoteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(note.characterId, note.noteId),
            _noteByIdByCharacter
        );

        return noteId;
    }

    function postNote4ERC721(
        DataTypes.PostNoteData calldata postNoteData,
        DataTypes.ERC721Struct calldata erc721
    ) external override returns (uint256) {
        _validateCallerPermission(postNoteData.characterId, OP.POST_NOTE_FOR_ERC721);
        _validateERC721Exists(erc721.tokenAddress, erc721.erc721TokenId);

        bytes32 linkItemType = Constants.NoteLinkTypeERC721;
        bytes32 linkKey = ILinklist(_linklist).addLinkingERC721(
            0,
            erc721.tokenAddress,
            erc721.erc721TokenId
        );
        uint256 noteId = ++_characterById[postNoteData.characterId].noteCount;

        PostLogic.postNoteWithLink(
            postNoteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(erc721.tokenAddress, erc721.erc721TokenId),
            _noteByIdByCharacter
        );

        return noteId;
    }

    function postNote4AnyUri(DataTypes.PostNoteData calldata postNoteData, string calldata uri)
        external
        override
        returns (uint256)
    {
        _validateCallerPermission(postNoteData.characterId, OP.POST_NOTE_FOR_ANY_URI);

        bytes32 linkItemType = Constants.NoteLinkTypeAnyUri;
        bytes32 linkKey = ILinklist(_linklist).addLinkingAnyUri(0, uri);
        uint256 noteId = ++_characterById[postNoteData.characterId].noteCount;

        PostLogic.postNoteWithLink(
            postNoteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(uri),
            _noteByIdByCharacter
        );

        return noteId;
    }

    function _validateCallerPermission(uint256 characterId, uint256 permissionId) internal view {
        address owner = ownerOf(characterId);
        require(
            msg.sender == owner ||
                (tx.origin == owner && msg.sender == periphery) ||
                ((_operatorsPermissionBitMap[characterId][msg.sender] >> permissionId) & 1) == 1,
            "NotEnoughPermission"
        );
    }

    function _validateCallerPermission4Note(
        uint256 characterId,
        uint256 noteId,
        uint256 permissionId
    ) internal view {
        address owner = ownerOf(characterId);
        require(
            msg.sender == owner ||
                (tx.origin == owner && msg.sender == periphery) ||
                (((_operatorsPermission4NoteBitMap[characterId][noteId][msg.sender] >>
                    permissionId) & 1) ==
                    1 ||
                    _operatorsPermission4NoteBitMap[characterId][noteId][msg.sender] == 0),
            "NotEnoughPermissionForThisNote"
        );
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
