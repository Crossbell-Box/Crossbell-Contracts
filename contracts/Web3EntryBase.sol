// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {IWeb3Entry} from "./interfaces/IWeb3Entry.sol";
import {ILinklist} from "./interfaces/ILinklist.sol";
import {NFTBase} from "./base/NFTBase.sol";
import {Web3EntryStorage} from "./storage/Web3EntryStorage.sol";
import {Web3EntryExtendStorage} from "./storage/Web3EntryExtendStorage.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {Constants} from "./libraries/Constants.sol";
import {Events} from "./libraries/Events.sol";
import {CharacterLib} from "./libraries/CharacterLib.sol";
import {PostLib} from "./libraries/PostLib.sol";
import {OperatorLib} from "./libraries/OperatorLib.sol";
import {LinkLib} from "./libraries/LinkLib.sol";
import {LinklistLib} from "./libraries/LinklistLib.sol";
import {MetaTxLib} from "./libraries/MetaTxLib.sol";
import {ValidationLib} from "./libraries/ValidationLib.sol";
import {OP} from "./libraries/OP.sol";
import {
    ErrSocialTokenExists,
    ErrNotCharacterOwner,
    ErrNotEnoughPermission,
    ErrNotEnoughPermissionForThisNote,
    ErrCharacterNotExists,
    ErrTokenNotExists
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

    modifier validateCallerPermission(uint256 characterId, uint256 permissionId) {
        _validateCallerPermission(characterId, permissionId);
        _;
    }

    modifier onlyExistingToken(uint256 tokenId) {
        if (!_exists(tokenId)) revert ErrCharacterNotExists(tokenId);
        _;
    }

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
    ) external override validateCallerPermission(characterId, OP.GRANT_OPERATOR_PERMISSIONS) {
        OperatorLib.grantOperatorPermissions(characterId, operator, permissionBitMap);
    }

    /// @inheritdoc IWeb3Entry
    function grantOperatorPermissionsWithSig(
        uint256 characterId,
        address operator,
        uint256 permissionBitMap,
        DataTypes.EIP712Signature calldata signature
    ) external override {
        if (!_callerIsCharacterOwner(signature.signer, characterId)) revert ErrNotCharacterOwner();

        MetaTxLib.validateGrantOperatorPermissionsSignature(
            signature,
            characterId,
            operator,
            permissionBitMap
        );
        OperatorLib.grantOperatorPermissions(characterId, operator, permissionBitMap);
    }

    /// @inheritdoc IWeb3Entry
    function grantOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blocklist,
        address[] calldata allowlist
    ) external override validateCallerPermission(characterId, OP.GRANT_OPERATORS_FOR_NOTE) {
        ValidationLib.validateNoteExists(characterId, noteId);
        OperatorLib.grantOperators4Note(characterId, noteId, blocklist, allowlist);
    }

    /// @inheritdoc IWeb3Entry
    function createCharacter(
        DataTypes.CreateCharacterData calldata vars
    ) external override returns (uint256 characterId) {
        return _createCharacter(vars, true);
    }

    /// @inheritdoc IWeb3Entry
    function setHandle(
        uint256 characterId,
        string calldata newHandle
    ) external override validateCallerPermission(characterId, OP.SET_HANDLE) {
        CharacterLib.setHandle(characterId, newHandle);
    }

    /// @inheritdoc IWeb3Entry
    function setSocialToken(
        uint256 characterId,
        address tokenAddress
    ) external override validateCallerPermission(characterId, OP.SET_SOCIAL_TOKEN) {
        // check if the social token exists
        if (_characterById[characterId].socialToken != address(0)) revert ErrSocialTokenExists();

        CharacterLib.setSocialToken(characterId, tokenAddress);
    }

    /// @inheritdoc IWeb3Entry
    function setPrimaryCharacterId(uint256 characterId) external override {
        if (!_callerIsCharacterOwner(msg.sender, characterId)) revert ErrNotCharacterOwner();

        // `tx.origin` is used here because the caller may be the periphery contract
        uint256 oldCharacterId = _primaryCharacterByAddress[tx.origin];
        _primaryCharacterByAddress[tx.origin] = characterId;

        emit Events.SetPrimaryCharacterId(msg.sender, characterId, oldCharacterId);
    }

    /// @inheritdoc IWeb3Entry
    function setCharacterUri(
        uint256 characterId,
        string calldata newUri
    ) external override validateCallerPermission(characterId, OP.SET_CHARACTER_URI) {
        _characterById[characterId].uri = newUri;

        emit Events.SetCharacterUri(characterId, newUri);
    }

    /// @inheritdoc IWeb3Entry
    function setLinklistUri(uint256 linklistId, string calldata uri) external override {
        uint256 characterId = ILinklist(_linklist).getOwnerCharacterId(linklistId);
        _validateCallerPermission(characterId, OP.SET_LINKLIST_URI);

        LinklistLib.setLinklistUri(linklistId, uri, _linklist);
    }

    /// @inheritdoc IWeb3Entry
    function setLinklistType(uint256 linklistId, bytes32 linkType) external override {
        uint256 characterId = ILinklist(_linklist).getOwnerCharacterId(linklistId);
        _validateCallerPermission(characterId, OP.SET_LINKLIST_TYPE);

        LinklistLib.setLinklistType(characterId, linklistId, linkType, _linklist);
    }

    /// @inheritdoc IWeb3Entry
    function linkCharacter(
        DataTypes.linkCharacterData calldata vars
    )
        external
        override
        onlyExistingToken(vars.toCharacterId)
        validateCallerPermission(vars.fromCharacterId, OP.LINK_CHARACTER)
    {
        LinkLib.linkCharacter(
            vars.fromCharacterId,
            vars.toCharacterId,
            vars.linkType,
            vars.data,
            _linklist
        );
    }

    /// @inheritdoc IWeb3Entry
    function unlinkCharacter(
        DataTypes.unlinkCharacterData calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.LINK_CHARACTER) {
        LinkLib.unlinkCharacter(vars.fromCharacterId, vars.toCharacterId, vars.linkType, _linklist);
    }

    /// @inheritdoc IWeb3Entry
    function createThenLinkCharacter(
        DataTypes.createThenLinkCharacterData calldata vars
    )
        external
        override
        validateCallerPermission(vars.fromCharacterId, OP.CREATE_THEN_LINK_CHARACTER)
        returns (uint256 characterId)
    {
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
        LinkLib.linkCharacter(vars.fromCharacterId, characterId, vars.linkType, "", _linklist);
    }

    /// @inheritdoc IWeb3Entry
    function linkNote(
        DataTypes.linkNoteData calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.LINK_NOTE) {
        ValidationLib.validateNoteExists(vars.toCharacterId, vars.toNoteId);

        LinkLib.linkNote(
            vars.fromCharacterId,
            vars.toCharacterId,
            vars.toNoteId,
            vars.linkType,
            vars.data,
            _linklist
        );
    }

    /// @inheritdoc IWeb3Entry
    function unlinkNote(
        DataTypes.unlinkNoteData calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.UNLINK_NOTE) {
        LinkLib.unlinkNote(
            vars.fromCharacterId,
            vars.toCharacterId,
            vars.toNoteId,
            vars.linkType,
            _linklist
        );
    }

    /// @inheritdoc IWeb3Entry
    function linkERC721(
        DataTypes.linkERC721Data calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.LINK_ERC721) {
        LinkLib.linkERC721(
            vars.fromCharacterId,
            vars.tokenAddress,
            vars.tokenId,
            vars.linkType,
            _linklist
        );
    }

    /// @inheritdoc IWeb3Entry
    function unlinkERC721(
        DataTypes.unlinkERC721Data calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.UNLINK_ERC721) {
        LinkLib.unlinkERC721(
            vars.fromCharacterId,
            vars.tokenAddress,
            vars.tokenId,
            vars.linkType,
            _linklist
        );
    }

    /// @inheritdoc IWeb3Entry
    function linkAddress(
        DataTypes.linkAddressData calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.LINK_ADDRESS) {
        LinkLib.linkAddress(vars.fromCharacterId, vars.ethAddress, vars.linkType, _linklist);
    }

    /// @inheritdoc IWeb3Entry
    function unlinkAddress(
        DataTypes.unlinkAddressData calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.UNLINK_ADDRESS) {
        LinkLib.unlinkAddress(vars.fromCharacterId, vars.ethAddress, vars.linkType, _linklist);
    }

    /// @inheritdoc IWeb3Entry
    function linkAnyUri(
        DataTypes.linkAnyUriData calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.LINK_ANYURI) {
        LinkLib.linkAnyUri(vars.fromCharacterId, vars.toUri, vars.linkType, _linklist);
    }

    /// @inheritdoc IWeb3Entry
    function unlinkAnyUri(
        DataTypes.unlinkAnyUriData calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.UNLINK_ANYURI) {
        LinkLib.unlinkAnyUri(vars.fromCharacterId, vars.toUri, vars.linkType, _linklist);
    }

    /// @inheritdoc IWeb3Entry
    function linkLinklist(
        DataTypes.linkLinklistData calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.LINK_LINKLIST) {
        LinkLib.linkLinklist(vars.fromCharacterId, vars.toLinkListId, vars.linkType, _linklist);
    }

    /// @inheritdoc IWeb3Entry
    function unlinkLinklist(
        DataTypes.unlinkLinklistData calldata vars
    ) external override validateCallerPermission(vars.fromCharacterId, OP.UNLINK_LINKLIST) {
        LinkLib.unlinkLinklist(vars.fromCharacterId, vars.toLinkListId, vars.linkType, _linklist);
    }

    /// @inheritdoc IWeb3Entry
    function setLinkModule4Character(
        DataTypes.setLinkModule4CharacterData calldata vars
    )
        external
        override
        validateCallerPermission(vars.characterId, OP.SET_LINK_MODULE_FOR_CHARACTER)
    {
        CharacterLib.setCharacterLinkModule(
            vars.characterId,
            vars.linkModule,
            vars.linkModuleInitData
        );
    }

    /// @inheritdoc IWeb3Entry
    function setLinkModule4Note(
        DataTypes.setLinkModule4NoteData calldata vars
    ) external override validateCallerPermission(vars.characterId, OP.SET_LINK_MODULE_FOR_NOTE) {
        // @dev only check operators permission currently
        PostLib.setLinkModule4Note(
            vars.characterId,
            vars.noteId,
            vars.linkModule,
            vars.linkModuleInitData
        );
    }

    /// @inheritdoc IWeb3Entry
    function mintNote(
        DataTypes.MintNoteData calldata vars
    ) external override returns (uint256 tokenId) {
        ValidationLib.validateNoteExists(vars.characterId, vars.noteId);

        tokenId = PostLib.mintNote(
            vars.characterId,
            vars.noteId,
            vars.to,
            vars.mintModuleData,
            MINT_NFT_IMPL
        );
    }

    /// @inheritdoc IWeb3Entry
    function setMintModule4Note(
        DataTypes.setMintModule4NoteData calldata vars
    ) external override validateCallerPermission(vars.characterId, OP.SET_MINT_MODULE_FOR_NOTE) {
        ValidationLib.validateNoteExists(vars.characterId, vars.noteId);
        ValidationLib.validateNoteNotLocked(vars.characterId, vars.noteId);

        PostLib.setMintModule4Note(
            vars.characterId,
            vars.noteId,
            vars.mintModule,
            vars.mintModuleInitData
        );
    }

    /// @inheritdoc IWeb3Entry
    function postNote(
        DataTypes.PostNoteData calldata vars
    )
        external
        override
        validateCallerPermission(vars.characterId, OP.POST_NOTE)
        returns (uint256 noteId)
    {
        noteId = _nextNoteId(vars.characterId);
        PostLib.postNoteWithLink(vars, noteId, 0, 0, "");
    }

    /// @inheritdoc IWeb3Entry
    function setNoteUri(
        uint256 characterId,
        uint256 noteId,
        string calldata newUri
    ) external override {
        _validateCallerPermission4Note(characterId, noteId);
        ValidationLib.validateNoteExists(characterId, noteId);
        ValidationLib.validateNoteNotLocked(characterId, noteId);

        PostLib.setNoteUri(characterId, noteId, newUri);
    }

    /// @inheritdoc IWeb3Entry
    function lockNote(
        uint256 characterId,
        uint256 noteId
    ) external override validateCallerPermission(characterId, OP.LOCK_NOTE) {
        PostLib.lockNote(characterId, noteId);
    }

    /// @inheritdoc IWeb3Entry
    function deleteNote(
        uint256 characterId,
        uint256 noteId
    ) external override validateCallerPermission(characterId, OP.DELETE_NOTE) {
        PostLib.deleteNote(characterId, noteId);
    }

    /// @inheritdoc IWeb3Entry
    function postNote4Character(
        DataTypes.PostNoteData calldata vars,
        uint256 toCharacterId
    )
        external
        override
        validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_CHARACTER)
        returns (uint256 noteId)
    {
        noteId = _nextNoteId(vars.characterId);
        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_CHARACTER;
        bytes32 linkKey = bytes32(toCharacterId);

        PostLib.postNoteWithLink(
            vars,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(toCharacterId)
        );
    }

    /// @inheritdoc IWeb3Entry
    function postNote4Address(
        DataTypes.PostNoteData calldata vars,
        address ethAddress
    )
        external
        override
        validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_ADDRESS)
        returns (uint256 noteId)
    {
        noteId = _nextNoteId(vars.characterId);
        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_ADDRESS;
        bytes32 linkKey = bytes32(uint256(uint160(ethAddress)));

        PostLib.postNoteWithLink(vars, noteId, linkItemType, linkKey, abi.encodePacked(ethAddress));
    }

    /// @inheritdoc IWeb3Entry
    function postNote4Linklist(
        DataTypes.PostNoteData calldata vars,
        uint256 toLinklistId
    )
        external
        override
        validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_LINKLIST)
        returns (uint256 noteId)
    {
        noteId = _nextNoteId(vars.characterId);
        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_LINKLIST;
        bytes32 linkKey = bytes32(toLinklistId);

        PostLib.postNoteWithLink(
            vars,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(toLinklistId)
        );
    }

    /// @inheritdoc IWeb3Entry
    function postNote4Note(
        DataTypes.PostNoteData calldata vars,
        DataTypes.NoteStruct calldata note
    )
        external
        override
        validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_NOTE)
        returns (uint256 noteId)
    {
        noteId = _nextNoteId(vars.characterId);
        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_NOTE;
        bytes32 linkKey = ILinklist(_linklist).addLinkingNote(0, note.characterId, note.noteId);

        PostLib.postNoteWithLink(
            vars,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(note.characterId, note.noteId)
        );
    }

    /// @inheritdoc IWeb3Entry
    function postNote4ERC721(
        DataTypes.PostNoteData calldata vars,
        DataTypes.ERC721Struct calldata erc721
    )
        external
        override
        validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_ERC721)
        returns (uint256 noteId)
    {
        noteId = _nextNoteId(vars.characterId);
        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_ERC721;
        bytes32 linkKey = ILinklist(_linklist).addLinkingERC721(
            0,
            erc721.tokenAddress,
            erc721.erc721TokenId
        );

        PostLib.postNoteWithLink(
            vars,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(erc721.tokenAddress, erc721.erc721TokenId)
        );
    }

    /// @inheritdoc IWeb3Entry
    function postNote4AnyUri(
        DataTypes.PostNoteData calldata vars,
        string calldata uri
    )
        external
        override
        validateCallerPermission(vars.characterId, OP.POST_NOTE_FOR_ANYURI)
        returns (uint256 noteId)
    {
        noteId = _nextNoteId(vars.characterId);
        bytes32 linkItemType = Constants.LINK_ITEM_TYPE_ANYURI;
        bytes32 linkKey = ILinklist(_linklist).addLinkingAnyUri(0, uri);

        PostLib.postNoteWithLink(vars, noteId, linkItemType, linkKey, abi.encodePacked(uri));
    }

    /// @inheritdoc IWeb3Entry
    function burnLinklist(uint256 linklistId) external override {
        // only the owner of the character can burn the linklist through web3Entry contract
        uint256 characterId = ILinklist(_linklist).getOwnerCharacterId(linklistId);
        if (!_callerIsCharacterOwner(msg.sender, characterId)) revert ErrNotCharacterOwner();

        LinklistLib.burnLinklist(characterId, linklistId, _linklist);
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
        DataTypes.Operators4Note storage operators4Note = _operators4Note[characterId][noteId];
        (blocklist, allowlist) = (
            operators4Note.blocklist.values(),
            operators4Note.allowlist.values()
        );
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
    ) external view override onlyExistingToken(characterId) returns (DataTypes.Character memory) {
        return _characterById[characterId];
    }

    /// @inheritdoc IWeb3Entry
    function getCharacterByHandle(
        string calldata handle
    ) external view override returns (DataTypes.Character memory) {
        uint256 characterId = _characterIdByHandleHash[_handleHash(handle)];
        return _characterById[characterId];
    }

    /// @inheritdoc IWeb3Entry
    function getHandle(
        uint256 characterId
    ) external view override onlyExistingToken(characterId) returns (string memory) {
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
    function getDomainSeparator() external view override returns (bytes32) {
        return MetaTxLib._calculateDomainSeparator();
    }

    /// @inheritdoc IWeb3Entry
    function nonces(address owner) external view override returns (uint256) {
        return _sigNonces[owner];
    }

    /// @inheritdoc IWeb3Entry
    function getRevision() external pure override returns (uint256) {
        return REVISION;
    }

    /**
     * @notice Burns a web3Entry character nft.
     * @param tokenId The token ID to burn.
     */
    function burn(uint256 tokenId) public virtual override {
        // clear handle
        bytes32 handleHash = _handleHash(_characterById[tokenId].handle);
        _characterIdByHandleHash[handleHash] = 0;

        // clear character
        delete _characterById[tokenId];

        // burn token
        super.burn(tokenId);
    }

    /**
     * @notice Returns the associated URI with a given character.
     * @param characterId The character ID to query.
     * @return The token URI.
     */
    function tokenURI(
        uint256 characterId
    ) public view override onlyExistingToken(characterId) returns (string memory) {
        return _characterById[characterId].uri;
    }

    function _createCharacter(
        DataTypes.CreateCharacterData memory vars,
        bool validateHandle
    ) internal returns (uint256 characterId) {
        characterId = ++_characterCounter;
        // mint character nft
        _safeMint(vars.to, characterId);

        CharacterLib.createCharacter(
            vars.to,
            vars.handle,
            vars.uri,
            vars.linkModule,
            vars.linkModuleInitData,
            characterId,
            validateHandle
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
            OperatorLib.clearOperators(tokenId);

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

    /**
     * @dev It will first check note permission, and then check operators permission.
     */
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

    function _validateCallerPermission(uint256 characterId, uint256 permissionId) internal view {
        // check character owner
        if (_callerIsCharacterOwner(msg.sender, characterId)) {
            return;
        }

        // check operator permission for caller
        address caller = (msg.sender == _periphery) ? tx.origin : msg.sender;
        if (_checkBit(_operatorsPermissionBitMap[characterId][caller], permissionId)) {
            return;
        }

        revert ErrNotEnoughPermission();
    }

    function _callerIsCharacterOwner(
        address caller,
        uint256 characterId
    ) internal view returns (bool) {
        address owner = ownerOf(characterId);

        if (caller == owner) {
            // caller is character owner
            return true;
        }

        // solhint-disable-next-line avoid-tx-origin
        if (caller == _periphery && tx.origin == owner) {
            // caller is periphery, and tx.origin is character owner
            return true;
        }

        return false;
    }

    function _validateCallerPermission4Note(uint256 characterId, uint256 noteId) internal view {
        // check character owner
        if (_callerIsCharacterOwner(msg.sender, characterId)) {
            return;
        }

        // check note permission for caller
        address caller = (msg.sender == _periphery) ? tx.origin : msg.sender;
        if (_isOperatorAllowedForNote(characterId, noteId, caller)) {
            return;
        }

        revert ErrNotEnoughPermissionForThisNote();
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

    function _handleHash(string memory handle) internal pure returns (bytes32) {
        return keccak256(bytes(handle));
    }
}
