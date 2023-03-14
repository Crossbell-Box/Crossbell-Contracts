// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import {IWeb3Entry} from "./interfaces/IWeb3Entry.sol";
import {ILinklist} from "./interfaces/ILinklist.sol";
import {ILinkModule4Note} from "./interfaces/ILinkModule4Note.sol";
import {NFTBase} from "./base/NFTBase.sol";
import {Web3EntryStorage} from "./storage/Web3EntryStorage.sol";
import {Web3EntryExtendStorage} from "./storage/Web3EntryExtendStorage.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {Constants} from "./libraries/Constants.sol";
import {Events} from "./libraries/Events.sol";
import {CharacterLogic} from "./libraries/CharacterLogic.sol";
import {PostLogic} from "./libraries/PostLogic.sol";
import {OperatorLogic} from "./libraries/OperatorLogic.sol";
import {LinkModuleLogic} from "./libraries/LinkModuleLogic.sol";
import {LinkLogic} from "./libraries/LinkLogic.sol";
import {OP} from "./libraries/OP.sol";
import {
    ErrSocialTokenExists,
    ErrNotAddressOwner,
    ErrHandleExists,
    ErrNotCharacterOwner,
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote,
    ErrCharacterNotExists,
    ErrNoteIsDeleted,
    ErrNoteNotExists,
    ErrNoteLocked,
    ErrHandleLengthInvalid,
    ErrHandleContainsInvalidCharacters
} from "./libraries/Error.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

contract Web3EntryBase is
    IWeb3Entry,
    Multicall,
    NFTBase,
    Web3EntryStorage,
    Initializable,
    Web3EntryExtendStorage
{
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    // solhint-disable-next-line private-vars-leading-underscore
    uint256 internal constant REVISION = 4;

    /// @inheritdoc IWeb3Entry
    function initialize(
        string calldata name_,
        string calldata symbol_,
        address linklist_,
        address mintNFTImpl_,
        address periphery_,
        address newbieVilla_
    ) external override reinitializer(3) {
        super._initialize(name_, symbol_);
        _linklist = linklist_;
        MINT_NFT_IMPL = mintNFTImpl_;
        _periphery = periphery_;
        _newbieVilla = newbieVilla_;

        emit Events.Web3EntryInitialized(block.timestamp);
    }

    /// @inheritdoc IWeb3Entry
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

    /// @inheritdoc IWeb3Entry
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

    /// @inheritdoc IWeb3Entry
    function createCharacter(
        DataTypes.CreateCharacterData calldata vars
    ) external override returns (uint256 characterId) {
        return _createCharacter(vars, true);
    }

    /// @inheritdoc IWeb3Entry
    function setHandle(uint256 characterId, string calldata newHandle) external override {
        _validateCallerPermission(characterId, OP.SET_HANDLE);

        // check if the handle exists
        _checkHandleExists(keccak256(bytes(newHandle)));

        // check if the handle is valid
        _validateHandle(newHandle);

        CharacterLogic.setHandle(characterId, newHandle, _characterIdByHandleHash, _characterById);
    }

    /// @inheritdoc IWeb3Entry
    function setSocialToken(uint256 characterId, address tokenAddress) external override {
        _validateCallerPermission(characterId, OP.SET_SOCIAL_TOKEN);

        // check if the social token exists
        if (_characterById[characterId].socialToken != address(0)) revert ErrSocialTokenExists();

        CharacterLogic.setSocialToken(characterId, tokenAddress, _characterById);
    }

    /// @inheritdoc IWeb3Entry
    function setPrimaryCharacterId(uint256 characterId) external override {
        _validateCallerIsCharacterOwner(characterId);

        uint256 oldCharacterId = _primaryCharacterByAddress[msg.sender];
        _primaryCharacterByAddress[msg.sender] = characterId;

        emit Events.SetPrimaryCharacterId(msg.sender, characterId, oldCharacterId);
    }

    /// @inheritdoc IWeb3Entry
    function setCharacterUri(uint256 characterId, string calldata newUri) external override {
        _validateCallerPermission(characterId, OP.SET_CHARACTER_URI);
        _characterById[characterId].uri = newUri;

        emit Events.SetCharacterUri(characterId, newUri);
    }

    /// @inheritdoc IWeb3Entry
    function setLinklistUri(uint256 linklistId, string calldata uri) external override {
        uint256 ownerCharacterId = ILinklist(_linklist).getOwnerCharacterId(linklistId);
        _validateCallerPermission(ownerCharacterId, OP.SET_LINKLIST_URI);

        ILinklist(_linklist).setUri(linklistId, uri);
    }

    /// @inheritdoc IWeb3Entry
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

    /// @inheritdoc IWeb3Entry
    function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_CHARACTER);

        LinkLogic.unlinkCharacter(
            vars.fromCharacterId,
            vars.toCharacterId,
            vars.linkType,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    /// @inheritdoc IWeb3Entry
    function createThenLinkCharacter(
        DataTypes.createThenLinkCharacterData calldata vars
    ) external override returns (uint256 characterId) {
        _validateCallerPermission(vars.fromCharacterId, OP.CREATE_THEN_LINK_CHARACTER);

        // create character
        characterId = _createCharacter(
            DataTypes.CreateCharacterData({
                to: vars.to,
                handle: _addressToHexString(vars.to),
                uri: "",
                linkModule: address(0),
                linkModuleInitData: ""
            }),
            false
        );

        // link character
        LinkLogic.linkCharacter(
            vars.fromCharacterId,
            characterId,
            vars.linkType,
            "",
            _linklist,
            address(0),
            _attachedLinklists
        );
    }

    /// @inheritdoc IWeb3Entry
    function linkNote(DataTypes.linkNoteData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_NOTE);
        _validateNoteExists(vars.toCharacterId, vars.toNoteId);

        LinkLogic.linkNote(
            vars.fromCharacterId,
            vars.toCharacterId,
            vars.toNoteId,
            vars.linkType,
            vars.data,
            _linklist,
            _noteByIdByCharacter[vars.toCharacterId][vars.toNoteId].linkModule,
            _attachedLinklists
        );
    }

    /// @inheritdoc IWeb3Entry
    function unlinkNote(DataTypes.unlinkNoteData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_NOTE);

        LinkLogic.unlinkNote(
            vars.fromCharacterId,
            vars.toCharacterId,
            vars.toNoteId,
            vars.linkType,
            _linklist,
            _attachedLinklists
        );
    }

    /// @inheritdoc IWeb3Entry
    function linkERC721(DataTypes.linkERC721Data calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_ERC721);

        LinkLogic.linkERC721(
            vars.fromCharacterId,
            vars.tokenAddress,
            vars.tokenId,
            vars.linkType,
            _linklist,
            _attachedLinklists
        );
    }

    /// @inheritdoc IWeb3Entry
    function unlinkERC721(DataTypes.unlinkERC721Data calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_ERC721);

        LinkLogic.unlinkERC721(
            vars.fromCharacterId,
            vars.tokenAddress,
            vars.tokenId,
            vars.linkType,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    /// @inheritdoc IWeb3Entry
    function linkAddress(DataTypes.linkAddressData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_ADDRESS);

        LinkLogic.linkAddress(
            vars.fromCharacterId,
            vars.ethAddress,
            vars.linkType,
            _linklist,
            _attachedLinklists
        );
    }

    /// @inheritdoc IWeb3Entry
    function unlinkAddress(DataTypes.unlinkAddressData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_ADDRESS);

        LinkLogic.unlinkAddress(
            vars.fromCharacterId,
            vars.ethAddress,
            vars.linkType,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    /// @inheritdoc IWeb3Entry
    function linkAnyUri(DataTypes.linkAnyUriData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_ANYURI);

        LinkLogic.linkAnyUri(
            vars.fromCharacterId,
            vars.toUri,
            vars.linkType,
            _linklist,
            _attachedLinklists
        );
    }

    /// @inheritdoc IWeb3Entry
    function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_ANYURI);

        LinkLogic.unlinkAnyUri(
            vars.fromCharacterId,
            vars.toUri,
            vars.linkType,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    /// @inheritdoc IWeb3Entry
    function linkLinklist(DataTypes.linkLinklistData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.LINK_LINKLIST);

        LinkLogic.linkLinklist(
            vars.fromCharacterId,
            vars.toLinkListId,
            vars.linkType,
            _linklist,
            _attachedLinklists
        );
    }

    /// @inheritdoc IWeb3Entry
    function unlinkLinklist(DataTypes.unlinkLinklistData calldata vars) external override {
        _validateCallerPermission(vars.fromCharacterId, OP.UNLINK_LINKLIST);

        LinkLogic.unlinkLinklist(
            vars.fromCharacterId,
            vars.toLinkListId,
            vars.linkType,
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

    /// @inheritdoc IWeb3Entry
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

    /// @inheritdoc IWeb3Entry
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

    /// @inheritdoc IWeb3Entry
    function mintNote(
        DataTypes.MintNoteData calldata vars
    ) external override returns (uint256 tokenId) {
        _validateNoteExists(vars.characterId, vars.noteId);

        tokenId = PostLogic.mintNote(
            vars.characterId,
            vars.noteId,
            vars.to,
            vars.mintModuleData,
            MINT_NFT_IMPL,
            _noteByIdByCharacter
        );
    }

    /// @inheritdoc IWeb3Entry
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

    /// @inheritdoc IWeb3Entry
    function postNote(
        DataTypes.PostNoteData calldata vars
    ) external override returns (uint256 noteId) {
        _validateCallerPermission(vars.characterId, OP.POST_NOTE);

        noteId = _nextNoteId(vars.characterId);
        PostLogic.postNoteWithLink(vars, noteId, 0, 0, "", _noteByIdByCharacter);
    }

    /// @inheritdoc IWeb3Entry
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

    /// @inheritdoc IWeb3Entry
    function lockNote(uint256 characterId, uint256 noteId) external override {
        _validateCallerPermission(characterId, OP.LOCK_NOTE);
        _validateNoteExists(characterId, noteId);

        _noteByIdByCharacter[characterId][noteId].locked = true;

        emit Events.LockNote(characterId, noteId);
    }

    /// @inheritdoc IWeb3Entry
    function deleteNote(uint256 characterId, uint256 noteId) external override {
        _validateCallerPermission(characterId, OP.DELETE_NOTE);
        _validateNoteExists(characterId, noteId);

        _noteByIdByCharacter[characterId][noteId].deleted = true;

        emit Events.DeleteNote(characterId, noteId);
    }

    /// @inheritdoc IWeb3Entry
    function postNote4Character(
        DataTypes.PostNoteData calldata vars,
        uint256 toCharacterId
    ) external override returns (uint256) {
        _validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_CHARACTER);

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_CHARACTER;
        uint256 noteId = _nextNoteId(vars.characterId);
        bytes32 linkKey = bytes32(toCharacterId);

        PostLogic.postNoteWithLink(
            vars,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(toCharacterId),
            _noteByIdByCharacter
        );

        return noteId;
    }

    /// @inheritdoc IWeb3Entry
    function postNote4Address(
        DataTypes.PostNoteData calldata vars,
        address ethAddress
    ) external override returns (uint256) {
        _validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_ADDRESS);

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_ADDRESS;
        uint256 noteId = _nextNoteId(vars.characterId);
        bytes32 linkKey = bytes32(uint256(uint160(ethAddress)));

        PostLogic.postNoteWithLink(
            vars,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(ethAddress),
            _noteByIdByCharacter
        );

        return noteId;
    }

    /// @inheritdoc IWeb3Entry
    function postNote4Linklist(
        DataTypes.PostNoteData calldata vars,
        uint256 toLinklistId
    ) external override returns (uint256) {
        _validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_LINKLIST);

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_LINKLIST;
        uint256 noteId = _nextNoteId(vars.characterId);
        bytes32 linkKey = bytes32(toLinklistId);

        PostLogic.postNoteWithLink(
            vars,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(toLinklistId),
            _noteByIdByCharacter
        );

        return noteId;
    }

    /// @inheritdoc IWeb3Entry
    function postNote4Note(
        DataTypes.PostNoteData calldata vars,
        DataTypes.NoteStruct calldata note
    ) external override returns (uint256) {
        _validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_NOTE);

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_NOTE;
        uint256 noteId = _nextNoteId(vars.characterId);
        bytes32 linkKey = ILinklist(_linklist).addLinkingNote(0, note.characterId, note.noteId);

        PostLogic.postNoteWithLink(
            vars,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(note.characterId, note.noteId),
            _noteByIdByCharacter
        );

        return noteId;
    }

    /// @inheritdoc IWeb3Entry
    function postNote4ERC721(
        DataTypes.PostNoteData calldata vars,
        DataTypes.ERC721Struct calldata erc721
    ) external override returns (uint256) {
        _validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_ERC721);

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_ERC721;
        uint256 noteId = _nextNoteId(vars.characterId);
        bytes32 linkKey = ILinklist(_linklist).addLinkingERC721(
            0,
            erc721.tokenAddress,
            erc721.erc721TokenId
        );

        PostLogic.postNoteWithLink(
            vars,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(erc721.tokenAddress, erc721.erc721TokenId),
            _noteByIdByCharacter
        );

        return noteId;
    }

    /// @inheritdoc IWeb3Entry
    function postNote4AnyUri(
        DataTypes.PostNoteData calldata vars,
        string calldata uri
    ) external override returns (uint256) {
        _validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_ANYURI);

        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_ANYURI;
        uint256 noteId = _nextNoteId(vars.characterId);
        bytes32 linkKey = ILinklist(_linklist).addLinkingAnyUri(0, uri);

        PostLogic.postNoteWithLink(
            vars,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(uri),
            _noteByIdByCharacter
        );

        return noteId;
    }

    /// @inheritdoc IWeb3Entry
    function getOperators(uint256 characterId) external view override returns (address[] memory) {
        return _operatorsByCharacter[characterId].values();
    }

    /// @inheritdoc IWeb3Entry
    function getOperatorPermissions(
        uint256 characterId,
        address operator
    ) external view override returns (uint256) {
        return _operatorsPermissionBitMap[characterId][operator];
    }

    /// @inheritdoc IWeb3Entry
    function getOperators4Note(
        uint256 characterId,
        uint256 noteId
    ) external view override returns (address[] memory blocklist, address[] memory allowlist) {
        blocklist = _operators4Note[characterId][noteId].blocklist.values();
        allowlist = _operators4Note[characterId][noteId].allowlist.values();
    }

    /// @inheritdoc IWeb3Entry
    function isOperatorAllowedForNote(
        uint256 characterId,
        uint256 noteId,
        address operator
    ) external view override returns (bool) {
        return _isOperatorAllowedForNote(characterId, noteId, operator);
    }

    /// @inheritdoc IWeb3Entry
    function getPrimaryCharacterId(address account) external view override returns (uint256) {
        return _primaryCharacterByAddress[account];
    }

    /// @inheritdoc IWeb3Entry
    function isPrimaryCharacter(uint256 characterId) external view override returns (bool) {
        address account = ownerOf(characterId);
        return characterId == _primaryCharacterByAddress[account];
    }

    /// @inheritdoc IWeb3Entry
    function getCharacter(
        uint256 characterId
    ) external view override returns (DataTypes.Character memory) {
        return _characterById[characterId];
    }

    /// @inheritdoc IWeb3Entry
    function getCharacterByHandle(
        string calldata handle
    ) external view override returns (DataTypes.Character memory) {
        bytes32 handleHash = keccak256(bytes(handle));
        uint256 characterId = _characterIdByHandleHash[handleHash];
        return _characterById[characterId];
    }

    /// @inheritdoc IWeb3Entry
    function getHandle(uint256 characterId) external view override returns (string memory) {
        return _characterById[characterId].handle;
    }

    /// @inheritdoc IWeb3Entry
    function getCharacterUri(uint256 characterId) external view override returns (string memory) {
        return tokenURI(characterId);
    }

    /// @inheritdoc IWeb3Entry
    function getNote(
        uint256 characterId,
        uint256 noteId
    ) external view override returns (DataTypes.Note memory) {
        return _noteByIdByCharacter[characterId][noteId];
    }

    /// @inheritdoc IWeb3Entry
    function getLinkModule4Address(address account) external view override returns (address) {
        return _linkModules4Address[account];
    }

    /// @inheritdoc IWeb3Entry
    function getLinkModule4Linklist(uint256 tokenId) external view override returns (address) {
        return _linkModules4Linklist[tokenId];
    }

    /// @inheritdoc IWeb3Entry
    function getLinkModule4ERC721(
        address tokenAddress,
        uint256 tokenId
    ) external view override returns (address) {
        return _linkModules4ERC721[tokenAddress][tokenId];
    }

    /// @inheritdoc IWeb3Entry
    function getLinklistUri(uint256 tokenId) external view override returns (string memory) {
        return ILinklist(_linklist).Uri(tokenId);
    }

    /// @inheritdoc IWeb3Entry
    function getLinklistId(
        uint256 characterId,
        bytes32 linkType
    ) external view override returns (uint256) {
        return _attachedLinklists[characterId][linkType];
    }

    /// @inheritdoc IWeb3Entry
    function getLinklistType(uint256 linkListId) external view override returns (bytes32) {
        return ILinklist(_linklist).getLinkType(linkListId);
    }

    /// @inheritdoc IWeb3Entry
    function getLinklistContract() external view override returns (address) {
        return _linklist;
    }

    /// @inheritdoc IWeb3Entry
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

    function _createCharacter(
        DataTypes.CreateCharacterData memory vars,
        bool validateHandle
    ) internal returns (uint256 characterId) {
        // check if the handle exists
        _checkHandleExists(keccak256(bytes(vars.handle)));

        // check if the handle is valid
        if (validateHandle) {
            _validateHandle(vars.handle);
        }

        characterId = ++_characterCounter;
        // mint character nft
        _safeMint(vars.to, characterId);

        CharacterLogic.createCharacter(
            vars.to,
            vars.handle,
            vars.uri,
            vars.linkModule,
            vars.linkModuleInitData,
            characterId,
            _characterIdByHandleHash,
            _characterById
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
        //  clear operators if character is transferred from non-newbieVilla contract
        if (from != _newbieVilla) {
            // clear operators
            uint256 len = _operatorsByCharacter[tokenId].length();
            address[] memory operators = _operatorsByCharacter[tokenId].values();
            for (uint256 i = 0; i < len; i++) {
                _clearOperator(tokenId, operators[i]);
            }

            // reset if `tokenId` is primary character of `from` account
            if (_primaryCharacterByAddress[from] == tokenId) {
                _primaryCharacterByAddress[from] = 0;
            }
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        // set primary character if `to` account has no primary character
        if (_primaryCharacterByAddress[to] == 0) {
            _primaryCharacterByAddress[to] = tokenId;
        }

        super._afterTokenTransfer(from, to, tokenId);
    }

    function _nextNoteId(uint256 characterId) internal returns (uint256) {
        return ++_characterById[characterId].noteCount;
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

    function _validateNoteExists(uint256 characterId, uint256 noteId) internal view {
        if (_noteByIdByCharacter[characterId][noteId].deleted) revert ErrNoteIsDeleted();
        if (noteId > _characterById[characterId].noteCount) revert ErrNoteNotExists();
    }

    function _validateNoteNotLocked(uint256 characterId, uint256 noteId) internal view {
        if (_noteByIdByCharacter[characterId][noteId].locked) revert ErrNoteLocked();
    }

    function _validateHandle(string memory handle) internal pure {
        bytes memory byteHandle = bytes(handle);
        uint256 len = byteHandle.length;
        if (len > Constants.MAX_HANDLE_LENGTH || len < Constants.MIN_HANDLE_LENGTH)
            revert ErrHandleLengthInvalid();

        for (uint256 i = 0; i < len; ) {
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

    /**
     * @dev _addressToHexString converts an address to its ASCII `string hexadecimal representation.
     */
    function _addressToHexString(address addr) internal pure returns (string memory) {
        bytes16 symbols = "0123456789abcdef";
        uint256 value = uint256(uint160(addr));

        bytes memory buffer = new bytes(42);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 41; i > 1; ) {
            buffer[i] = symbols[value & 0xf];
            value >>= 4;

            unchecked {
                --i;
            }
        }
        return string(buffer);
    }
}
