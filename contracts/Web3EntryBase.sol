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

    function _setCharacterUri(uint256 profileId, string memory newUri) public virtual {}

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
        uint256 characterId = ++_characterCounter;
        // mint character nft
        _safeMint(vars.to, characterId);

        CharacterLogic.createCharacter(
            vars,
            true,
            characterId,
            _characterIdByHandleHash,
            _characterById
        );

        // set primary character
        if (_primaryCharacterByAddress[vars.to] == 0) {
            _primaryCharacterByAddress[vars.to] = characterId;
        }
    }

    // owner permission
    function setHandle(uint256 characterId, string calldata newHandle) external {
        _validateCallerIsCharacterOwner(characterId);

        CharacterLogic.setHandle(characterId, newHandle, _characterIdByHandleHash, _characterById);
    }

    // owner permission
    function setSocialToken(uint256 characterId, address tokenAddress) external {
        _validateCallerIsCharacterOwner(characterId);

        CharacterLogic.setSocialToken(characterId, tokenAddress, _characterById);
    }

    // opSign permission id = 176
    function setCharacterUri(uint256 characterId, string calldata newUri) external {
        _setCharacterUri(characterId, newUri);
    }

    // owner permission
    function setPrimaryCharacterId(uint256 characterId) external {
        _validateCallerIsCharacterOwner(characterId);

        uint256 oldCharacterId = _primaryCharacterByAddress[msg.sender];
        _primaryCharacterByAddress[msg.sender] = characterId;

        emit Events.SetPrimaryCharacterId(msg.sender, characterId, oldCharacterId);
    }

    function grantOperatorPermissions(
        uint256 characterId,
        address operator,
        uint256 permissionBitMap
    ) external virtual {}

    function grantOperatorPermissions4Note(
        uint256 characterId,
        uint256 noteId,
        address operator,
        uint256 permissionBitMap
    ) external virtual {}

    function _validateCallerIsCharacterOwnerOrOperator(uint256 characterId) internal view virtual {}

    function _validateCallerIsLinklistOwnerOrOperator(uint256 tokenId) internal view virtual {}

    // opSign permission
    function setLinklistUri(uint256 linklistId, string calldata uri) external virtual {}

    function linkCharacter(DataTypes.linkCharacterData calldata vars) external virtual {}

    function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars) external virtual {}

    function createThenLinkCharacter(DataTypes.createThenLinkCharacterData calldata vars)
        external
        virtual
    {}

    function _createThenLinkCharacter(
        uint256 fromCharacterId,
        address to,
        bytes32 linkType,
        bytes memory data
    ) internal {
        require(
            _primaryCharacterByAddress[to] == 0,
            "Target address already has primary character."
        );

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

    function linkNote(DataTypes.linkNoteData calldata vars) external virtual {}

    function unlinkNote(DataTypes.unlinkNoteData calldata vars) external virtual {}

    function linkERC721(DataTypes.linkERC721Data calldata vars) external virtual {}

    function unlinkERC721(DataTypes.unlinkERC721Data calldata vars) external virtual {}

    function linkAddress(DataTypes.linkAddressData calldata vars) external virtual {}

    function unlinkAddress(DataTypes.unlinkAddressData calldata vars) external virtual {}

    function linkAnyUri(DataTypes.linkAnyUriData calldata vars) external virtual {}

    function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars) external virtual {}

    function linkLinklist(DataTypes.linkLinklistData calldata vars) external virtual {}

    function unlinkLinklist(DataTypes.unlinkLinklistData calldata vars) external virtual {}

    // set link module for his character
    function setLinkModule4Character(DataTypes.setLinkModule4CharacterData calldata vars)
        external
        virtual
    {}

    function setLinkModule4Note(DataTypes.setLinkModule4NoteData calldata vars) external virtual {}

    function setLinkModule4Linklist(DataTypes.setLinkModule4LinklistData calldata vars)
        external
        virtual
    {}

    /**
     * @notice Set linkModule for a ERC721 token that you own.
     * @dev Operators can't setLinkModule4ERC721, because operators are set for 
     characters but erc721 tokens belong to address and not characters.
     */
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

    /**
     * @notice Set linkModule for an address.
     * @dev Operators can't setLinkModule4Address, because this linkModule is for 
     addresses and is irrelevan to characters.
     */
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

    function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external virtual {}

    function postNote(DataTypes.PostNoteData calldata vars) external virtual returns (uint256) {}

    function setNoteUri(
        uint256 characterId,
        uint256 noteId,
        string calldata newUri
    ) external virtual {}

    /**
     * @notice lockNote put a note into a immutable state where no modifications are 
     allowed. You should call this method to announce that this is the final version.
     */
    function lockNote(uint256 characterId, uint256 noteId) external virtual {}

    function deleteNote(uint256 characterId, uint256 noteId) external virtual {}

    function postNote4Character(DataTypes.PostNoteData calldata postNoteData, uint256 toCharacterId)
        external
        virtual
        returns (uint256)
    {}

    function postNote4Address(DataTypes.PostNoteData calldata noteData, address ethAddress)
        external
        virtual
        returns (uint256)
    {}

    function postNote4Linklist(DataTypes.PostNoteData calldata noteData, uint256 toLinklistId)
        external
        virtual
        returns (uint256)
    {}

    function postNote4Note(
        DataTypes.PostNoteData calldata postNoteData,
        DataTypes.NoteStruct calldata note
    ) external virtual returns (uint256) {}

    function postNote4ERC721(
        DataTypes.PostNoteData calldata postNoteData,
        DataTypes.ERC721Struct calldata erc721
    ) external virtual returns (uint256) {}

    function postNote4AnyUri(DataTypes.PostNoteData calldata postNoteData, string calldata uri)
        external
        virtual
        returns (uint256)
    {}

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

    function _validateCallerIsCharacterOwner(uint256 characterId) internal view {
        address owner = ownerOf(characterId);
        require(
            msg.sender == owner || (tx.origin == owner && msg.sender == periphery),
            "Web3Entry: Not Character Owner"
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
