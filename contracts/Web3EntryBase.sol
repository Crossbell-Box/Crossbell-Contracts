// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./base/NFTBase.sol";
import "./interfaces/IWeb3Entry.sol";
import "./interfaces/ILinklist.sol";
import "./interfaces/ILinkModule4Note.sol";
import "./storage/Web3EntryStorage.sol";
import "./storage/Web3EntryExtendStorage.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Constants.sol";
import "./libraries/Events.sol";
import "./libraries/CharacterLogic.sol";
import "./libraries/PostLogic.sol";
import "./libraries/OperatorLogic.sol";
import "./libraries/LinkModuleLogic.sol";
import "./libraries/LinkLogic.sol";
import "./libraries/OP.sol";
import "./libraries/Error.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Web3EntryBase is
    IWeb3Entry,
    NFTBase,
    Web3EntryStorage,
    Initializable,
    Web3EntryExtendStorage
{
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    // solhint-disable-next-line private-vars-leading-underscore
    uint256 internal constant REVISION = 4;

    address public constant OPERATOR = 0xda2423ceA4f1047556e7a142F81a7ED50e93e160;
    address public constant XSYNC_OPERATOR = 0x0F588318A494e4508A121a32B6670b5494Ca3357;

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address linklist_,
        address mintNFTImpl_,
        address periphery_,
        address newbieVilla_
    ) external override reinitializer(2) {
        super._initialize(name_, symbol_);
        _linklist = linklist_;
        MINT_NFT_IMPL = mintNFTImpl_;
        _periphery = periphery_;
        _newbieVilla = newbieVilla_;

        emit Events.Web3EntryInitialized(block.timestamp);
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

    function migrateOperatorSyncPermissions(uint256[] calldata characterIds) external override {
        require(msg.sender == OPERATOR, "only operator");

        for (uint256 i = 0; i < characterIds.length; i++) {
            OperatorLogic.grantOperatorPermissions(
                characterIds[i],
                XSYNC_OPERATOR,
                OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP,
                _operatorsByCharacter,
                _operatorsPermissionBitMap
            );
        }
    }

    /**
     * @notice Grant operators allowlist and blocklist roles of a note.
     * @param characterId ID of character that you want to set.
     * @param noteId ID of note that you want to set.
     * @param blocklist blocklist addresses that you want to grant.
     * @param allowlist allowlist addresses that you want to grant.
     */
    function grantOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blocklist,
        address[] calldata allowlist
    ) external override {
        _validateCallerPermission(characterId, OP.GRANT_OPERATORS_FOR_NOTE);
        _validateNoteExists(characterId, noteId);
        OperatorLogic.grantOperators4Note(
            characterId,
            noteId,
            blocklist,
            allowlist,
            _operators4Note
        );
    }

    /**
     * This method creates a character with the given parameters to the given address.
     *
     * @param vars The CreateCharacterData struct containing the following parameters:
     *      * to: The address receiving the character.
     *      * handle: The handle to set for the character.
     *      * uri: The URI to set for the character metadata.
     *      * linkModule: The link module to use, can be the zero address.
     *      * linkModuleInitData: The link module initialization data, if any.
     */
    function createCharacter(
        DataTypes.CreateCharacterData calldata vars
    ) external override returns (uint256 characterId) {
        // check if the handle exists
        _checkHandleExists(keccak256(bytes(vars.handle)));

        // check if the handle is valid
        _validateHandle(vars.handle);

        characterId = ++_characterCounter;
        // mint character nft
        _safeMint(vars.to, characterId);

        CharacterLogic.createCharacter(vars, characterId, _characterIdByHandleHash, _characterById);

        // set primary character
        if (_primaryCharacterByAddress[vars.to] == 0) {
            _primaryCharacterByAddress[vars.to] = characterId;
        }
    }

    // owner permission
    function setHandle(uint256 characterId, string calldata newHandle) external override {
        _validateCallerPermission(characterId, OP.SET_HANDLE);

        // check if the handle exists
        _checkHandleExists(keccak256(bytes(newHandle)));

        // check if the handle is valid
        _validateHandle(newHandle);

        CharacterLogic.setHandle(characterId, newHandle, _characterIdByHandleHash, _characterById);
    }

    // owner permission
    function setSocialToken(uint256 characterId, address tokenAddress) external override {
        _validateCallerPermission(characterId, OP.SET_SOCIAL_TOKEN);

        // check if the social token exists
        if (_characterById[characterId].socialToken != address(0)) revert ErrSocialTokenExists();

        CharacterLogic.setSocialToken(characterId, tokenAddress, _characterById);
    }

    // owner permission
    function setPrimaryCharacterId(uint256 characterId) external override {
        _validateCallerIsCharacterOwner(characterId);

        uint256 oldCharacterId = _primaryCharacterByAddress[msg.sender];
        _primaryCharacterByAddress[msg.sender] = characterId;

        emit Events.SetPrimaryCharacterId(msg.sender, characterId, oldCharacterId);
    }

    // opSign permission
    function setCharacterUri(uint256 characterId, string calldata newUri) external override {
        _validateCallerPermission(characterId, OP.SET_CHARACTER_URI);
        _characterById[characterId].uri = newUri;

        emit Events.SetCharacterUri(characterId, newUri);
    }

    // opSign permission
    function setLinklistUri(uint256 linklistId, string calldata uri) external override {
        uint256 ownerCharacterId = ILinklist(_linklist).getOwnerCharacterId(linklistId);
        _validateCallerPermission(ownerCharacterId, OP.SET_LINKLIST_URI);

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
            _linklist,
            _characterById[vars.toCharacterId].linkModule,
            _attachedLinklists
        );
    }

    function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_CHARACTER);

        LinkLogic.unlinkCharacter(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    function createThenLinkCharacter(
        DataTypes.createThenLinkCharacterData calldata vars
    ) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.CREATE_THEN_LINK_CHARACTER);
        // slither-disable-next-line reentrancy-no-eth
        _createThenLinkCharacter(vars.fromCharacterId, vars.to, vars.linkType, "0x");
    }

    function linkNote(DataTypes.linkNoteData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_NOTE);
        _validateNoteExists(vars.toCharacterId, vars.toNoteId);

        LinkLogic.linkNote(vars, _linklist, _noteByIdByCharacter, _attachedLinklists);
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
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_ANYURI);

        LinkLogic.linkAnyUri(vars, _linklist, _attachedLinklists);
    }

    function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_ANYURI);

        LinkLogic.unlinkAnyUri(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    function linkLinklist(DataTypes.linkLinklistData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_LINKLIST);

        LinkLogic.linkLinklist(vars, _linklist, _attachedLinklists);
    }

    function unlinkLinklist(DataTypes.unlinkLinklistData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_LINKLIST);

        LinkLogic.unlinkLinklist(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    //////////////////////////////////////////////////////////////
    /*
     * These functions are temporarily commented out, in order to limit the contract code size within 24K.
     * These functions will be restored when necessary in the future.
     */
    /**
     * @notice set link module for his character
     */

    /*
    function setLinkModule4Character(DataTypes.setLinkModule4CharacterData calldata vars) external  override {
        _validateCallerPermission(vars.characterId, OP.SET_LINK_MODULE_FOR_CHARACTER);

        CharacterLogic.setCharacterLinkModule(
            vars.characterId,
            vars.linkModule,
            vars.linkModuleInitData,
            _characterById[vars.characterId]
        );
    }

    function setLinkModule4Note(DataTypes.setLinkModule4NoteData calldata vars) external override  {
        _validateCallerPermission(vars.characterId, OP.SET_LINK_MODULE_FOR_NOTE);
        _validateCallerPermission4Note(vars.characterId, vars.noteId);
        _validateNoteExists(vars.characterId, vars.noteId);
        _validateNoteNotLocked(vars.characterId, vars.noteId);

        LinkModuleLogic.setLinkModule4Note(
            vars.characterId,
            vars.noteId,
            vars.linkModule,
            vars.linkModuleInitData,
            _noteByIdByCharacter
        );
    }
    */

    /**
     * @notice Set linkModule for a ERC721 token that you own.
     * @dev Operators can't setLinkModule4ERC721, because operators are set for 
     characters but erc721 tokens belong to address and not characters.
     */
    /*
   function setLinkModule4ERC721(DataTypes.setLinkModule4ERC721Data calldata vars) external  override {
       require(msg.sender == ERC721(vars.tokenAddress).ownerOf(vars.tokenId), "NotERC721Owner");

       LinkModuleLogic.setLinkModule4ERC721(
           vars.tokenAddress,
           vars.tokenId,
           vars.linkModule,
           vars.linkModuleInitData,
           _linkModules4ERC721
       );
   }
     */
    //////////////////////////////////////////////////////////////

    function setLinkModule4Linklist(
        DataTypes.setLinkModule4LinklistData calldata vars
    ) external override {
        // get character id of the owner of this linklist
        uint256 ownerCharacterId = ILinklist(_linklist).getOwnerCharacterId(vars.linklistId);

        _validateCallerPermission(ownerCharacterId, OP.SET_LINK_MODULE_FOR_LINKLIST);

        LinkModuleLogic.setLinkModule4Linklist(
            vars.linklistId,
            vars.linkModule,
            vars.linkModuleInitData,
            _linkModules4Linklist
        );
    }

    /**
     * @notice Set linkModule for an address.
     * @dev Operators can't setLinkModule4Address, because this linkModule is for 
     addresses and is irrelevan to characters.
     */
    function setLinkModule4Address(
        DataTypes.setLinkModule4AddressData calldata vars
    ) external override {
        if (msg.sender != vars.account) revert ErrNotAddressOwner();

        LinkModuleLogic.setLinkModule4Address(
            vars.account,
            vars.linkModule,
            vars.linkModuleInitData,
            _linkModules4Address
        );
    }

    function mintNote(DataTypes.MintNoteData calldata vars) external override returns (uint256) {
        _validateNoteExists(vars.characterId, vars.noteId);

        return
            PostLogic.mintNote(
                vars.characterId,
                vars.noteId,
                vars.to,
                vars.mintModuleData,
                MINT_NFT_IMPL,
                _characterById,
                _noteByIdByCharacter
            );
    }

    function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external override {
        _validateCallerPermission(vars.characterId, OP.SET_MINT_MODULE_FOR_NOTE);
        _validateNoteExists(vars.characterId, vars.noteId);
        _validateNoteNotLocked(vars.characterId, vars.noteId);

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
        _validateCallerPermission4Note(characterId, noteId);
        _validateNoteExists(characterId, noteId);
        _validateNoteNotLocked(characterId, noteId);

        PostLogic.setNoteUri(characterId, noteId, newUri, _noteByIdByCharacter);
    }

    /**
     * @notice lockNote put a note into a immutable state where no modifications are 
     allowed. You should call this method to announce that this is the final version.
     */
    function lockNote(uint256 characterId, uint256 noteId) external override {
        _validateCallerPermission(characterId, OP.LOCK_NOTE);
        _validateNoteExists(characterId, noteId);

        _noteByIdByCharacter[characterId][noteId].locked = true;

        emit Events.LockNote(characterId, noteId);
    }

    function deleteNote(uint256 characterId, uint256 noteId) external override {
        _validateCallerPermission(characterId, OP.DELETE_NOTE);
        _validateNoteExists(characterId, noteId);

        _noteByIdByCharacter[characterId][noteId].deleted = true;

        emit Events.DeleteNote(characterId, noteId);
    }

    function postNote4Character(
        DataTypes.PostNoteData calldata postNoteData,
        uint256 toCharacterId
    ) external override returns (uint256) {
        _validateCallerPermission(postNoteData.characterId, OP.POST_NOTE_FOR_CHARACTER);

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_CHARACTER;
        uint256 noteId = ++_characterById[postNoteData.characterId].noteCount;
        bytes32 linkKey = bytes32(toCharacterId);

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

    function postNote4Address(
        DataTypes.PostNoteData calldata noteData,
        address ethAddress
    ) external override returns (uint256) {
        _validateCallerPermission(noteData.characterId, OP.POST_NOTE_FOR_ADDRESS);

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_ADDRESS;
        uint256 noteId = ++_characterById[noteData.characterId].noteCount;
        bytes32 linkKey = bytes32(uint256(uint160(ethAddress)));

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

    function postNote4Linklist(
        DataTypes.PostNoteData calldata noteData,
        uint256 toLinklistId
    ) external override returns (uint256) {
        _validateCallerPermission(noteData.characterId, OP.POST_NOTE_FOR_LINKLIST);

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_LINKLIST;
        uint256 noteId = ++_characterById[noteData.characterId].noteCount;
        bytes32 linkKey = bytes32(toLinklistId);

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

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_NOTE;
        uint256 noteId = ++_characterById[postNoteData.characterId].noteCount;
        bytes32 linkKey = ILinklist(_linklist).addLinkingNote(0, note.characterId, note.noteId);

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

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_ERC721;
        uint256 noteId = ++_characterById[postNoteData.characterId].noteCount;
        bytes32 linkKey = ILinklist(_linklist).addLinkingERC721(
            0,
            erc721.tokenAddress,
            erc721.erc721TokenId
        );

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

    function postNote4AnyUri(
        DataTypes.PostNoteData calldata postNoteData,
        string calldata uri
    ) external override returns (uint256) {
        _validateCallerPermission(postNoteData.characterId, OP.POST_NOTE_FOR_ANYURI);

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_ANYURI;
        uint256 noteId = ++_characterById[postNoteData.characterId].noteCount;
        bytes32 linkKey = ILinklist(_linklist).addLinkingAnyUri(0, uri);

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

    /**
     * @notice Get operator list of a character. This operator list has only a sole purpose, which is
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
     * @notice Get permission bitmap of an operator.
     * @param characterId ID of character that you want to check.
     * @param operator Address to grant operator permissions to.
     * @return Permission bitmap of this operator.
     */
    function getOperatorPermissions(
        uint256 characterId,
        address operator
    ) external view override returns (uint256) {
        return _operatorsPermissionBitMap[characterId][operator];
    }

    /**
     * @notice Get operators blocklist and allowlist for a note.
     * @param characterId ID of character to query.
     * @param noteId ID of note to query.
     */
    function getOperators4Note(
        uint256 characterId,
        uint256 noteId
    ) external view override returns (address[] memory blocklist, address[] memory allowlist) {
        blocklist = _operators4Note[characterId][noteId].blocklist.values();
        allowlist = _operators4Note[characterId][noteId].allowlist.values();
        return (blocklist, allowlist);
    }

    /**
     * @notice Query if a operator has permission for a note.
     * @param characterId ID of character that you want to query.
     * @param noteId ID of note that you want to query.
     * @param operator Address to query.
     * @return true if Operator has permission for a note, otherwise false.
     */
    function isOperatorAllowedForNote(
        uint256 characterId,
        uint256 noteId,
        address operator
    ) external view override returns (bool) {
        return _isOperatorAllowedForNote(characterId, noteId, operator);
    }

    function getPrimaryCharacterId(address account) external view override returns (uint256) {
        return _primaryCharacterByAddress[account];
    }

    function isPrimaryCharacter(uint256 characterId) external view override returns (bool) {
        address account = ownerOf(characterId);
        return characterId == _primaryCharacterByAddress[account];
    }

    function getCharacter(
        uint256 characterId
    ) external view override returns (DataTypes.Character memory) {
        return _characterById[characterId];
    }

    function getCharacterByHandle(
        string calldata handle
    ) external view override returns (DataTypes.Character memory) {
        bytes32 handleHash = keccak256(bytes(handle));
        uint256 characterId = _characterIdByHandleHash[handleHash];
        return _characterById[characterId];
    }

    function getHandle(uint256 characterId) external view override returns (string memory) {
        return _characterById[characterId].handle;
    }

    function getCharacterUri(uint256 characterId) external view override returns (string memory) {
        return tokenURI(characterId);
    }

    function getNote(
        uint256 characterId,
        uint256 noteId
    ) external view override returns (DataTypes.Note memory) {
        return _noteByIdByCharacter[characterId][noteId];
    }

    function getLinkModule4Address(address account) external view override returns (address) {
        return _linkModules4Address[account];
    }

    function getLinkModule4Linklist(uint256 tokenId) external view override returns (address) {
        return _linkModules4Linklist[tokenId];
    }

    function getLinkModule4ERC721(
        address tokenAddress,
        uint256 tokenId
    ) external view override returns (address) {
        return _linkModules4ERC721[tokenAddress][tokenId];
    }

    function getLinklistUri(uint256 tokenId) external view override returns (string memory) {
        return ILinklist(_linklist).Uri(tokenId);
    }

    function getLinklistId(
        uint256 characterId,
        bytes32 linkType
    ) external view override returns (uint256) {
        return _attachedLinklists[characterId][linkType];
    }

    function getLinklistType(uint256 linkListId) external view override returns (bytes32) {
        return ILinklist(_linklist).getLinkType(linkListId);
    }

    function getLinklistContract() external view override returns (address) {
        return _linklist;
    }

    function getRevision() external pure override returns (uint256) {
        return REVISION;
    }

    function burn(uint256 tokenId) public virtual override {
        // clear handle
        bytes32 handleHash = keccak256(bytes(_characterById[tokenId].handle));
        _characterIdByHandleHash[handleHash] = 0;

        // clear character
        delete _characterById[tokenId];

        // burn token
        super.burn(tokenId);
    }

    function tokenURI(uint256 characterId) public view override returns (string memory) {
        return _characterById[characterId].uri;
    }

    function _createThenLinkCharacter(
        uint256 fromCharacterId,
        address to,
        bytes32 linkType,
        bytes memory data
    ) internal {
        if (_primaryCharacterByAddress[to] != 0) revert ErrTargetAlreadyHasPrimaryCharacter();

        // check if the to handle exists
        _checkHandleExists(keccak256(abi.encodePacked(to)));

        uint256 characterId = ++_characterCounter;
        // mint character nft
        _safeMint(to, characterId);

        CharacterLogic.createCharacter(
            DataTypes.CreateCharacterData({
                to: to,
                handle: string(abi.encodePacked(to)),
                uri: "",
                linkModule: address(0),
                linkModuleInitData: ""
            }),
            characterId,
            _characterIdByHandleHash,
            _characterById
        );

        // set primary character
        _primaryCharacterByAddress[to] = characterId;

        // link character
        LinkLogic.linkCharacter(
            fromCharacterId,
            characterId,
            linkType,
            data,
            _linklist,
            address(0),
            _attachedLinklists
        );
    }

    /**
     * @dev Operators will be reset to blank before the characters are transferred in order to grant the
     * whole control power to receivers of character transfers.
     * If character is transferred from newbieVilla contract, don't clear operators.
     *
     * Permissions4Note is left unset, because permissions for notes are always stricter than default.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        // don't clear operator if character is transferred from newbieVilla contract
        if (from != _newbieVilla) {
            uint256 len = _operatorsByCharacter[tokenId].length();
            address[] memory operators = _operatorsByCharacter[tokenId].values();
            // clear operators
            for (uint256 i = 0; i < len; i++) {
                _clearOperator(tokenId, operators[i]);
            }
        }

        if (_primaryCharacterByAddress[from] != 0) {
            _primaryCharacterByAddress[from] = 0;
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _clearOperator(uint256 tokenId, address operator) internal {
        delete _operatorsPermissionBitMap[tokenId][operator];
        // slither-disable-next-line unused-return
        _operatorsByCharacter[tokenId].remove(operator);
    }

    function _isOperatorAllowedForNote(
        uint256 characterId,
        uint256 noteId,
        address operator
    ) internal view returns (bool) {
        DataTypes.Operators4Note storage op = _operators4Note[characterId][noteId];

        // check blocklist
        if (op.blocklist.contains(operator)) {
            return false;
        }
        // check allowlist
        if (op.allowlist.contains(operator)) {
            return true;
        }
        // check character operator permission
        return _checkBit(_operatorsPermissionBitMap[characterId][operator], OP.SET_NOTE_URI);
    }

    // check if the handle exists
    function _checkHandleExists(bytes32 handleHash) internal view {
        if (_characterIdByHandleHash[handleHash] != 0) revert ErrHandleExists();
    }

    function _validateCallerIsCharacterOwner(uint256 characterId) internal view {
        address owner = ownerOf(characterId);

        // tx.origin is character owner, and msg.sender is periphery
        // solhint-disable-next-line avoid-tx-origin
        if (msg.sender == _periphery && tx.origin == owner) {
            return;
        }

        // msg.sender is character owner
        if (msg.sender == owner) {
            return;
        }

        revert ErrNotCharacterOwner();
    }

    function _validateCallerPermission(uint256 characterId, uint256 permissionId) internal view {
        // check character owner
        if (_callerIsCharacterOwner(characterId)) {
            return;
        }

        // check operator permission for tx.origin
        if (msg.sender == _periphery) {
            // solhint-disable-next-line avoid-tx-origin
            if (_checkBit(_operatorsPermissionBitMap[characterId][tx.origin], permissionId)) {
                return;
            }
        }

        //  check operator permission for msg.sender
        if (_checkBit(_operatorsPermissionBitMap[characterId][msg.sender], permissionId)) {
            return;
        }

        revert ErrNotEnoughPermission();
    }

    function _callerIsCharacterOwner(uint256 characterId) internal view returns (bool) {
        address owner = ownerOf(characterId);

        if (msg.sender == owner) {
            // caller is character owner
            return true;
        }

        // solhint-disable-next-line avoid-tx-origin
        if (msg.sender == _periphery && tx.origin == owner) {
            // caller is periphery, and tx.origin is character owner
            return true;
        }

        return false;
    }

    function _validateCallerPermission4Note(uint256 characterId, uint256 noteId) internal view {
        // check character owner
        if (_callerIsCharacterOwner(characterId)) {
            return;
        }

        // check note permission for tx.origin
        if (msg.sender == _periphery) {
            // solhint-disable-next-line avoid-tx-origin
            if (_isOperatorAllowedForNote(characterId, noteId, tx.origin)) {
                return;
            }
        }

        // check note permission for caller
        if (_isOperatorAllowedForNote(characterId, noteId, msg.sender)) {
            return;
        }

        revert ErrNotEnoughPermissionForThisNote();
    }

    function _validateCharacterExists(uint256 characterId) internal view {
        if (!_exists(characterId)) revert ErrCharacterNotExists(characterId);
    }

    function _validateERC721Exists(address tokenAddress, uint256 tokenId) internal view {
        address owner = IERC721(tokenAddress).ownerOf(tokenId);
        if (address(0) == owner) revert ErrREC721NotExists();
    }

    function _validateNoteExists(uint256 characterId, uint256 noteId) internal view {
        if (_noteByIdByCharacter[characterId][noteId].deleted) revert ErrNoteIsDeleted();
        if (noteId > _characterById[characterId].noteCount) revert ErrNoteNotExists();
    }

    function _validateNoteNotLocked(uint256 characterId, uint256 noteId) internal view {
        if (_noteByIdByCharacter[characterId][noteId].locked) revert ErrNoteLocked();
    }

    function _validateHandle(string calldata handle) internal pure {
        bytes calldata byteHandle = bytes(handle);
        if (
            byteHandle.length > Constants.MAX_HANDLE_LENGTH ||
            byteHandle.length < Constants.MIN_HANDLE_LENGTH
        ) revert ErrHandleLengthInvalid();

        for (uint256 i = 0; i < byteHandle.length; ) {
            _validateChar(byteHandle[i]);

            unchecked {
                ++i;
            }
        }
    }

    function _validateChar(bytes1 c) internal pure {
        // char range: [0,9][a,z][-][_]
        if ((c < "0" || c > "z" || (c > "9" && c < "a")) && c != "-" && c != "_")
            revert ErrHandleContainsInvalidCharacters();
    }

    /**
     * @dev _checkBit checks if the value of the i'th bit of x is 1
     */
    function _checkBit(uint256 x, uint256 i) internal pure returns (bool) {
        return (x >> i) & 1 == 1;
    }
}
