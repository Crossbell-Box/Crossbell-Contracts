// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

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
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Web3Entry is IWeb3Entry, NFTBase, Web3EntryStorage, Initializable, Web3EntryExtendStorage {
    using Strings for uint256;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    uint256 internal constant REVISION = 4;

    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _linklistContract,
        address _mintNFTImpl,
        address _periphery,
        address _resolver
    ) external initializer {
        super._initialize(_name, _symbol);
        _linklist = _linklistContract;
        MINT_NFT_IMPL = _mintNFTImpl;
        periphery = _periphery;
        resolver = _resolver;

        emit Events.Web3EntryInitialized(block.timestamp);
    }

    function _setCharacterUri(uint256 profileId, string memory newUri) internal {
        _validateCallerIsCharacterOwnerOrOperator(profileId);

        _characterById[profileId].uri = newUri;

        emit Events.SetCharacterUri(profileId, newUri);
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
    function createCharacter(DataTypes.CreateCharacterData calldata vars) external {
        _createCharacter(vars);
    }

    function _createCharacter(DataTypes.CreateCharacterData memory vars) internal {
        _characterCounter = _characterCounter + 1;

        // mint character nft
        _mint(vars.to, _characterCounter);

        CharacterLogic.createCharacter(
            vars,
            true,
            _characterCounter,
            _characterIdByHandleHash,
            _characterById
        );

        // set primary character
        if (_primaryCharacterByAddress[vars.to] == 0) {
            _primaryCharacterByAddress[vars.to] = _characterCounter;
        }
    }

    function setHandle(uint256 characterId, string calldata newHandle) external {
        _validateCallerIsCharacterOwner(characterId);

        CharacterLogic.setHandle(characterId, newHandle, _characterIdByHandleHash, _characterById);
    }

    function setSocialToken(uint256 characterId, address tokenAddress) external {
        _validateCallerIsCharacterOwner(characterId);

        CharacterLogic.setSocialToken(characterId, tokenAddress, _characterById);
    }

    function setCharacterUri(uint256 characterId, string calldata newUri) external {
        _setCharacterUri(characterId, newUri);
    }

    function setPrimaryCharacterId(uint256 characterId) external {
        _validateCallerIsCharacterOwner(characterId);

        uint256 oldCharacterId = _primaryCharacterByAddress[msg.sender];
        _primaryCharacterByAddress[msg.sender] = characterId;

        emit Events.SetPrimaryCharacterId(msg.sender, characterId, oldCharacterId);
    }

    function setOperator(uint256 characterId, address operator) external {
        _validateCallerIsCharacterOwner(characterId);
        _setOperator(characterId, operator);
    }

    function setOperatorList(uint256 characterId, address[] calldata operatorList) external {
        _validateCallerIsCharacterOwner(characterId);
        _setOperatorList(characterId, operatorList);
    }

    function setLinklistUri(uint256 linklistId, string calldata uri) external {
        _validateCallerIsLinklistOwner(linklistId);

        ILinklist(_linklist).setUri(linklistId, uri);
    }

    function linkCharacter(DataTypes.linkCharacterData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.fromCharacterId);
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

    function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.fromCharacterId);

        LinkLogic.unlinkCharacter(
            vars,
            IERC721Enumerable(this).ownerOf(vars.fromCharacterId),
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    function createThenLinkCharacter(DataTypes.createThenLinkCharacterData calldata vars) external {
        _createThenLinkCharacter(vars.fromCharacterId, vars.to, vars.linkType, "0x");
    }

    function _createThenLinkCharacter(
        uint256 fromCharacterId,
        address to,
        bytes32 linkType,
        bytes memory data
    ) internal {
        _validateCallerIsCharacterOwner(fromCharacterId);
        require(
            _primaryCharacterByAddress[to] == 0,
            "Target address already has primary character."
        );

        uint256 characterId = ++_characterCounter;
        // mint character nft
        _mint(to, characterId);

        CharacterLogic.createCharacter(
            DataTypes.CreateCharacterData({
                to: to,
                handle: Strings.toHexString(uint160(to), 20),
                uri: "",
                linkModule: address(0),
                linkModuleInitData: ""
            }),
            false,
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

    function linkNote(DataTypes.linkNoteData calldata vars) external {
        _validateCallerIsCharacterOwnerOrOperator(vars.fromCharacterId);
        _validateNoteExists(vars.toCharacterId, vars.toNoteId);

        LinkLogic.linkNote(
            vars,
            IERC721Enumerable(this).ownerOf(vars.fromCharacterId),
            _linklist,
            _noteByIdByCharacter,
            _attachedLinklists
        );
    }

    function unlinkNote(DataTypes.unlinkNoteData calldata vars) external {
        _validateCallerIsCharacterOwnerOrOperator(vars.fromCharacterId);

        LinkLogic.unlinkNote(vars, _linklist, _attachedLinklists);
    }

    function linkERC721(DataTypes.linkERC721Data calldata vars) external {
        _validateCallerIsCharacterOwner(vars.fromCharacterId);
        _validateERC721Exists(vars.tokenAddress, vars.tokenId);

        LinkLogic.linkERC721(
            vars,
            IERC721Enumerable(this).ownerOf(vars.fromCharacterId),
            _linklist,
            _attachedLinklists
        );
    }

    function unlinkERC721(DataTypes.unlinkERC721Data calldata vars) external {
        _validateCallerIsCharacterOwner(vars.fromCharacterId);

        LinkLogic.unlinkERC721(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    function linkAddress(DataTypes.linkAddressData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.fromCharacterId);

        LinkLogic.linkAddress(
            vars,
            IERC721Enumerable(this).ownerOf(vars.fromCharacterId),
            _linklist,
            _attachedLinklists
        );
    }

    function unlinkAddress(DataTypes.unlinkAddressData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.fromCharacterId);

        LinkLogic.unlinkAddress(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    function linkAnyUri(DataTypes.linkAnyUriData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.fromCharacterId);

        LinkLogic.linkAnyUri(
            vars,
            IERC721Enumerable(this).ownerOf(vars.fromCharacterId),
            _linklist,
            _attachedLinklists
        );
    }

    function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.fromCharacterId);

        LinkLogic.unlinkAnyUri(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    /*
    function linkCharacterLink(
        uint256 fromCharacterId,
        DataTypes.CharacterLinkStruct calldata linkData,
        bytes32 linkType
    ) external {
        _validateCallerIsCharacterOwner(fromCharacterId);

        LinkLogic.linkCharacterLink(
            fromCharacterId,
            linkData,
            msg.sender,
            linkType,
            _linklist,
            _attachedLinklists
        );
    }

    function unlinkCharacterLink(
        uint256 fromCharacterId,
        DataTypes.CharacterLinkStruct calldata linkData,
        bytes32 linkType
    ) external {
        _validateCallerIsCharacterOwner(fromCharacterId);

        LinkLogic.unlinkCharacterLink(
            fromCharacterId,
            linkData,
            linkType,
            _linklist,
            _attachedLinklists[linkData.fromCharacterId][linkData.linkType]
        );
    }
    */

    function linkLinklist(DataTypes.linkLinklistData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.fromCharacterId);

        LinkLogic.linkLinklist(
            vars,
            IERC721Enumerable(this).ownerOf(vars.fromCharacterId),
            _linklist,
            _attachedLinklists
        );
    }

    function unlinkLinklist(DataTypes.unlinkLinklistData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.fromCharacterId);

        LinkLogic.unlinkLinklist(
            vars,
            _linklist,
            _attachedLinklists[vars.fromCharacterId][vars.linkType]
        );
    }

    // set link module for his character
    function setLinkModule4Character(DataTypes.setLinkModule4CharacterData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.characterId);

        CharacterLogic.setCharacterLinkModule(
            vars.characterId,
            vars.linkModule,
            vars.linkModuleInitData,
            _characterById[vars.characterId]
        );
    }

    function setLinkModule4Note(DataTypes.setLinkModule4NoteData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.characterId);
        _validateNoteExists(vars.characterId, vars.noteId);

        LinkModuleLogic.setLinkModule4Note(
            vars.characterId,
            vars.noteId,
            vars.linkModule,
            vars.linkModuleInitData,
            _noteByIdByCharacter
        );
    }

    function setLinkModule4Linklist(DataTypes.setLinkModule4LinklistData calldata vars) external {
        _validateCallerIsLinklistOwner(vars.linklistId);

        LinkModuleLogic.setLinkModule4Linklist(
            vars.linklistId,
            vars.linkModule,
            vars.linkModuleInitData,
            _linkModules4Linklist
        );
    }

    function setLinkModule4ERC721(DataTypes.setLinkModule4ERC721Data calldata vars) external {
        require(msg.sender == ERC721(vars.tokenAddress).ownerOf(vars.tokenId), "NotERC721Owner");

        LinkModuleLogic.setLinkModule4ERC721(
            vars.tokenAddress,
            vars.tokenId,
            vars.linkModule,
            vars.linkModuleInitData,
            _linkModules4ERC721
        );
    }

    function setLinkModule4Address(DataTypes.setLinkModule4AddressData calldata vars) external {
        LinkModuleLogic.setLinkModule4Address(
            vars.account,
            vars.linkModule,
            vars.linkModuleInitData,
            _linkModules4Address
        );
    }

    function mintNote(DataTypes.MintNoteData calldata vars) external returns (uint256) {
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

    function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external {
        _validateCallerIsCharacterOwner(vars.characterId);
        _validateNoteExists(vars.characterId, vars.noteId);

        LinkModuleLogic.setMintModule4Note(
            vars.characterId,
            vars.noteId,
            vars.mintModule,
            vars.mintModuleInitData,
            _noteByIdByCharacter
        );
    }

    function postNote(DataTypes.PostNoteData calldata vars) external returns (uint256) {
        _validateCallerIsCharacterOwnerOrOperator(vars.characterId);

        uint256 noteId = ++_characterById[vars.characterId].noteCount;

        PostLogic.postNoteWithLink(vars, noteId, 0, 0, "", _noteByIdByCharacter);
        return noteId;
    }

    function setNoteUri(
        uint256 characterId,
        uint256 noteId,
        string calldata newUri
    ) external {
        _validateCallerIsCharacterOwner(characterId);
        _validateNoteExists(characterId, noteId);

        PostLogic.setNoteUri(characterId, noteId, newUri, _noteByIdByCharacter);
    }

    function lockNote(uint256 characterId, uint256 noteId) external {
        _validateCallerIsCharacterOwnerOrOperator(characterId);
        _validateNoteExists(characterId, noteId);

        _noteByIdByCharacter[characterId][noteId].locked = true;

        emit Events.LockNote(characterId, noteId);
    }

    function deleteNote(uint256 characterId, uint256 noteId) external {
        _validateCallerIsCharacterOwnerOrOperator(characterId);
        _validateNoteExists(characterId, noteId);

        _noteByIdByCharacter[characterId][noteId].deleted = true;

        emit Events.DeleteNote(characterId, noteId);
    }

    function postNote4Character(DataTypes.PostNoteData calldata postNoteData, uint256 toCharacterId)
        external
        returns (uint256)
    {
        _validateCallerIsCharacterOwnerOrOperator(postNoteData.characterId);

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
        returns (uint256)
    {
        _validateCallerIsCharacterOwnerOrOperator(noteData.characterId);

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
        returns (uint256)
    {
        _validateCallerIsCharacterOwnerOrOperator(noteData.characterId);

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
    ) external returns (uint256) {
        _validateCallerIsCharacterOwnerOrOperator(postNoteData.characterId);

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
    ) external returns (uint256) {
        _validateCallerIsCharacterOwnerOrOperator(postNoteData.characterId);
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
        returns (uint256)
    {
        _validateCallerIsCharacterOwnerOrOperator(postNoteData.characterId);

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

    function burn(uint256 tokenId) public override {
        // clear handle
        bytes32 handleHash = keccak256(bytes(_characterById[tokenId].handle));
        _characterIdByHandleHash[handleHash] = 0;

        // clear character
        delete _characterById[tokenId];

        // burn token
        super.burn(tokenId);
    }

    function getPrimaryCharacterId(address account) external view returns (uint256) {
        return _primaryCharacterByAddress[account];
    }

    function isPrimaryCharacter(uint256 characterId) external view returns (bool) {
        address account = ownerOf(characterId);
        return characterId == _primaryCharacterByAddress[account];
    }

    function getCharacter(uint256 characterId) external view returns (DataTypes.Character memory) {
        return _characterById[characterId];
    }

    function getCharacterByHandle(string calldata handle)
        external
        view
        returns (DataTypes.Character memory)
    {
        bytes32 handleHash = keccak256(bytes(handle));
        uint256 characterId = _characterIdByHandleHash[handleHash];
        return _characterById[characterId];
    }

    function getHandle(uint256 characterId) external view returns (string memory) {
        return _characterById[characterId].handle;
    }

    function getCharacterUri(uint256 characterId) external view returns (string memory) {
        return tokenURI(characterId);
    }

    function getOperator(uint256 characterId) external view returns (address) {
        return _operatorByCharacter[characterId];
    }

    function getNote(uint256 characterId, uint256 noteId)
        external
        view
        returns (DataTypes.Note memory)
    {
        return _noteByIdByCharacter[characterId][noteId];
    }

    function getLinkModule4Address(address account) external view returns (address) {
        return _linkModules4Address[account];
    }

    function getLinkModule4Linklist(uint256 tokenId) external view returns (address) {
        return _linkModules4Linklist[tokenId];
    }

    function getLinkModule4ERC721(address tokenAddress, uint256 tokenId)
        external
        view
        returns (address)
    {
        return _linkModules4ERC721[tokenAddress][tokenId];
    }

    function tokenURI(uint256 characterId) public view override returns (string memory) {
        return _characterById[characterId].uri;
    }

    function getLinklistUri(uint256 tokenId) external view returns (string memory) {
        return ILinklist(_linklist).Uri(tokenId);
    }

    function getLinklistId(uint256 characterId, bytes32 linkType) external view returns (uint256) {
        return _attachedLinklists[characterId][linkType];
    }

    function getLinklistType(uint256 linkListId) external view returns (bytes32) {
        return ILinklist(_linklist).getLinkType(linkListId);
    }

    function getLinklistContract() external view returns (address) {
        return _linklist;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        if (_operatorByCharacter[tokenId] != address(0)) {
            _setOperator(tokenId, address(0));
        }

        if (_primaryCharacterByAddress[from] != 0) {
            _primaryCharacterByAddress[from] = 0;
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _setOperator(uint256 characterId, address operator) internal {
        _operatorByCharacter[characterId] = operator;
        emit Events.SetOperator(characterId, operator, block.timestamp);
    }

    function _setOperatorList(uint256 characterId, address[] calldata operatorList) internal {
        // _validateOperatorList(operator);
        for (uint256 index = 0; index < operatorList.length; index++) {
            _operatorListByCharacter[characterId][operatorList[index]] = true; 
        }
        emit Events.SetOperatorList(characterId, operatorList, block.timestamp);
    }

    // function _validateOperatorList(address[] operator) internal { 
    // }

    function _validateCallerIsCharacterOwnerOrOperator(uint256 characterId) internal view {
        address owner = ownerOf(characterId);

        require(
            _operatorListByCharacter[characterId][msg.sender] ||
            msg.sender == owner ||
                msg.sender == _operatorByCharacter[characterId] ||
                (tx.origin == owner && msg.sender == periphery),
            "NotCharacterOwnerNorOperator"
        );
    }

    function _validateCallerIsCharacterOwner(uint256 characterId) internal view {
        address owner = ownerOf(characterId);
        require(
            msg.sender == owner || (tx.origin == owner && msg.sender == periphery),
            "NotCharacterOwner"
        );
    }

    function _validateCallerIsLinklistOwner(uint256 tokenId) internal view {
        require(msg.sender == IERC721(_linklist).ownerOf(tokenId), "NotLinkListOwner");
    }

    function _validateCharacterExists(uint256 characterId) internal view {
        require(_exists(characterId), "CharacterNotExists");
    }

    function _validateERC721Exists(address tokenAddress, uint256 tokenId) internal view {
        require(address(0) != IERC721(tokenAddress).ownerOf(tokenId), "REC721NotExists");
    }

    function _validateNoteExists(uint256 characterId, uint256 noteId) internal view {
        require(!_noteByIdByCharacter[characterId][noteId].deleted, "NoteIsDeleted");
        require(noteId <= _characterById[characterId].noteCount, "NoteNotExists");
    }

    function getRevision() external pure returns (uint256) {
        return REVISION;
    }
}
