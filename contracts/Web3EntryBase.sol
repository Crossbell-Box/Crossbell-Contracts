// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./base/NFTBase.sol";
import "./interfaces/IWeb3Entry.sol";
import "./interfaces/ILinklist.sol";
import "./interfaces/ILinkModule4Note.sol";
import "./interfaces/IResolver.sol";
import "./storage/Web3EntryStorage.sol";
import "./storage/Web3EntryExtendStorage.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Constants.sol";
import "./libraries/Events.sol";
import "./libraries/CharacterLogic.sol";
import "./libraries/PostLogic.sol";
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
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    // solhint-disable-next-line private-vars-leading-underscore
    uint256 internal constant REVISION = 4;

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address linklist_,
        address mintNFTImpl_,
        address periphery_
    ) external override initializer {
        super._initialize(name_, symbol_);
        _linklist = linklist_;
        MINT_NFT_IMPL = mintNFTImpl_;
        _periphery = periphery_;

        emit Events.Web3EntryInitialized(block.timestamp);
    }

    // overridden in web3Entry
    function grantOperatorPermissions(
        uint256,
        address,
        uint256
    ) external virtual override {} // solhint-disable-line no-empty-blocks

    function grantOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blocklist,
        address[] calldata allowlist
    ) external virtual override {} // solhint-disable-line no-empty-blocks

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
    function createCharacter(DataTypes.CreateCharacterData calldata vars)
        external
        override
        returns (uint256 characterId)
    {
        // check if the handle exists
        bytes32 handleHash = keccak256(bytes(vars.handle));
        if (_characterIdByHandleHash[handleHash] != 0) revert ErrHandleExists();

        // check if the handle is valid
        CharacterLogic.validateHandle(vars.handle);

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
        bytes32 handleHash = keccak256(bytes(newHandle));
        if (_characterIdByHandleHash[handleHash] != 0) revert ErrHandleExists();

        // check if the handle is valid
        CharacterLogic.validateHandle(newHandle);

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

    function setLinkModule4Linklist(DataTypes.setLinkModule4LinklistData calldata vars)
        external
        override
    {
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
    function setLinkModule4Address(DataTypes.setLinkModule4AddressData calldata vars)
        external
        override
    {
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
        _validateCallerPermission(noteData.characterId, OP.POST_NOTE_FOR_LINKLIST);

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
        _validateCallerPermission(postNoteData.characterId, OP.POST_NOTE_FOR_ANYURI);

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

    // overridden in web3Entry
    function getOperatorPermissions(uint256, address)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return 0;
    }

    // overridden in web3Entry
    function getOperators4Note(uint256 characterId, uint256 noteId)
        external
        view
        virtual
        override
        returns (address[] memory blocklist, address[] memory allowlist)
    {} // solhint-disable-line no-empty-blocks

    // overridden in web3Entry
    function isOperatorAllowedForNote(
        uint256 characterId,
        uint256 noteId,
        address operator
    ) external view virtual override returns (bool) {} // solhint-disable-line no-empty-blocks

    function getPrimaryCharacterId(address account) external view override returns (uint256) {
        return _primaryCharacterByAddress[account];
    }

    function isPrimaryCharacter(uint256 characterId) external view override returns (bool) {
        address account = ownerOf(characterId);
        return characterId == _primaryCharacterByAddress[account];
    }

    function getCharacter(uint256 characterId)
        external
        view
        override
        returns (DataTypes.Character memory)
    {
        return _characterById[characterId];
    }

    function getCharacterByHandle(string calldata handle)
        external
        view
        override
        returns (DataTypes.Character memory)
    {
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

    function getNote(uint256 characterId, uint256 noteId)
        external
        view
        override
        returns (DataTypes.Note memory)
    {
        return _noteByIdByCharacter[characterId][noteId];
    }

    function getLinkModule4Address(address account) external view override returns (address) {
        return _linkModules4Address[account];
    }

    function getLinkModule4Linklist(uint256 tokenId) external view override returns (address) {
        return _linkModules4Linklist[tokenId];
    }

    function getLinkModule4ERC721(address tokenAddress, uint256 tokenId)
        external
        view
        override
        returns (address)
    {
        return _linkModules4ERC721[tokenAddress][tokenId];
    }

    function getLinklistUri(uint256 tokenId) external view override returns (string memory) {
        return ILinklist(_linklist).Uri(tokenId);
    }

    function getLinklistId(uint256 characterId, bytes32 linkType)
        external
        view
        override
        returns (uint256)
    {
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
        bytes32 handleHash = keccak256(bytes(Strings.toHexString(uint160(to), 20)));
        if (_characterIdByHandleHash[handleHash] != 0) revert ErrHandleExists();

        uint256 characterId = ++_characterCounter;
        // mint character nft
        _safeMint(to, characterId);

        CharacterLogic.createCharacter(
            DataTypes.CreateCharacterData({
                to: to,
                handle: Strings.toHexString(uint160(to), 20),
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
            IERC721Enumerable(this).ownerOf(fromCharacterId),
            _linklist,
            address(0),
            _attachedLinklists
        );
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

    // overridden in web3Entry
    // solhint-disable-next-line no-empty-blocks
    function _validateCallerPermission(uint256, uint256) internal view virtual {}

    // overridden in web3Entry
    function _validateCallerPermission4Note(uint256 characterId, uint256 noteId)
        internal
        view
        virtual
    {} // solhint-disable-line no-empty-blocks

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
}
