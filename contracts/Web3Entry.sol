// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Web3EntryBase.sol";
import "./libraries/OP.sol";

contract Web3Entry is Web3EntryBase {
    using EnumerableSet for EnumerableSet.AddressSet;

    // characterId => operator => permissionsBitMap
    mapping(uint256 => mapping(address => uint256)) internal operatorsPermissionBitMap; // slot 25

    // characterId => noteId => operator => uint256
    mapping(uint256 => mapping(uint256 => mapping(address => uint256)))
        internal operatorsPermission4NoteBitMap; // slot 26

    /**
     * @notice Grant an address as an operator and authorize it with cutom permissions.
     * @param permissionBitMap Bitmap used for finer grained operator permissions controls.
     * @dev Every bit in permissionBitMap stands for a corresponding method in Web3Entry. more details in OP.sol.
     */
    function grantOperatorPermissions(
        uint256 characterId,
        address operator,
        uint256 permissionBitMap
    ) external override {
        _validateCallerIsCharacterOwner(characterId);
        operatorsPermissionBitMap[characterId][operator] = permissionBitMap;
        emit Events.GrantOperatorPermissions(
            characterId,
            operator,
            permissionBitMap,
            block.timestamp
        );
    }

    /**
         * @notice Grant an address as an operator and authorize it with cutom permissions for a signle note.
         * @param permissionBitMap an uint256 bitmap used for finer grained operator permissions controls over notes
         * @dev Every bit in permissionBitMap stands for a sigle note that this character posted. The notes are 
                open to all operators who are granted with note permissions, until the Permissions4Note are set.
                With grantOperatorPermissions4Note, users can restrict permissions on individual notes, for example:
                I authorize bob to set uri for my notes, but only for my third notes(noteId = 3).
     */
    function grantOperatorPermissions4Note(
        uint256 characterId,
        uint256 noteId,
        address operator,
        uint256 permissionBitMap
    ) external override {
        _validateCallerIsCharacterOwner(characterId);
        _validateNoteExists(characterId, noteId);
        operatorsPermission4NoteBitMap[characterId][noteId][operator] = permissionBitMap;
        emit Events.GrantOperatorPermissions4Note(
            characterId,
            noteId,
            operator,
            permissionBitMap,
            block.timestamp
        );
    }

    /**
     * @notice Check if an address have the permission of a method(by permissionId) over a character.
     */
    function checkPermissionByPermissionId(
        uint256 characterId,
        address operator,
        uint256 permissionId
    ) public returns (bool) {
        return ((operatorsPermissionBitMap[characterId][operator] >> permissionId) & 1) == 1;
    }

    /**
     * @notice Check if an address have the permission of a method(by permissionId) over a note.
     */
    function checkPermission4NoteByPermissionId(
        uint256 characterId,
        uint256 noteId,
        address operator,
        uint256 permissionId
    ) public returns (bool) {
        return (((operatorsPermission4NoteBitMap[characterId][noteId][operator] >> permissionId) &
            1) ==
            1 ||
            operatorsPermission4NoteBitMap[characterId][noteId][operator] == 0);
    }

    /**
         * @notice Migrates operators permissions to operatorsAuthBitMap
         * @dev `addOpertor`, `removeOperator`, `setOperator` will all be deprecated soon. We recommand to use 
                `migrateOperator` to grant DEFAULT_PERMISSION_BITMAP to all previous operators.
     */
    function migrateOperator(uint256[] calldata characterIds) external {
        // set default permissions bitmap
        for (uint256 i = 0; i < characterIds.length; ++i) {
            uint256 characterId = characterIds[i];
            address operator = _operatorByCharacter[characterId];
            if (operator != address(0)) {
                operatorsPermissionBitMap[characterId][operator] = OP.DEFAULT_PERMISSION_BITMAP;
            }

            address[] memory operators = _operatorsByCharacter[characterId].values();
            for (uint256 j = 0; j < operators.length; ++j) {
                operatorsPermissionBitMap[characterId][operators[j]] = OP.DEFAULT_PERMISSION_BITMAP;
            }
        }
    }

    /**
     * @notice Check permission bitmap of an opertor.
     */
    function getOperatorPermissions(uint256 characterId, address operator)
        external
        view
        returns (uint256)
    {
        return operatorsPermissionBitMap[characterId][operator];
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

    function _validateCallerPermission(uint256 characterId, uint256 permissionId) internal {
        address owner = ownerOf(characterId);
        require(
            msg.sender == owner ||
                (tx.origin == owner && msg.sender == periphery) ||
                checkPermissionByPermissionId(characterId, msg.sender, permissionId),
            "Web3Entry: Not Enough Perssion"
        );
    }

    function _validateCallerPermission4Note(
        uint256 characterId,
        uint256 noteId,
        uint256 permissionId
    ) internal {
        address owner = ownerOf(characterId);
        require(
            msg.sender == owner ||
                (tx.origin == owner && msg.sender == periphery) ||
                checkPermission4NoteByPermissionId(characterId, noteId, msg.sender, permissionId),
            "Web3Entry: Not Enough PerssionForThisNote"
        );
    }
}
