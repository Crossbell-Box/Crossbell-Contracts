// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./interfaces/ILinklist.sol";
import "./interfaces/IWeb3Entry.sol";
import "./base/NFTBase.sol";
import "./libraries/Events.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Constants.sol";
import "./libraries/Error.sol";
import "./storage/LinklistStorage.sol";
import "./storage/LinklistExtendStorage.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Linklist is ILinklist, NFTBase, LinklistStorage, Initializable, LinklistExtendStorage {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    event Transfer(address indexed from, uint256 indexed characterId, uint256 indexed tokenId);

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address web3Entry_
    ) external override initializer {
        Web3Entry = web3Entry_;

        super._initialize(name_, symbol_);
        emit Events.LinklistNFTInitialized(block.timestamp);
    }

    function mint(
        uint256 characterId,
        bytes32 linkType,
        uint256 tokenId
    ) external override {
        _validateCallerIsWeb3Entry();
        if (_linklistOwners[tokenId] != 0) revert ErrTokenIdAlreadyExists();

        _linkTypes[tokenId] = linkType;

        // mint tokenId to characterId
        _linklistOwners[tokenId] = characterId;
        _linklistBalances[characterId] += 1;
        _tokenCount += 1;

        emit Transfer(address(0), characterId, tokenId);

        // emit erc721 transfer event
        emit IERC721.Transfer(
            address(0),
            IERC721Enumerable(Web3Entry).ownerOf(characterId),
            tokenId
        );
    }

    function setUri(uint256 tokenId, string memory newUri) external override {
        _validateCallerIsWeb3EntryOrOwner(tokenId);
        _uris[tokenId] = newUri;
    }

    /////////////////////////////////
    // linking Character
    /////////////////////////////////
    function addLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external override {
        _validateCallerIsWeb3Entry();
        _linkingCharacters[tokenId].add(toCharacterId);
    }

    function removeLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external override {
        _validateCallerIsWeb3Entry();
        _linkingCharacters[tokenId].remove(toCharacterId);
    }

    /////////////////////////////////
    // linking Note
    /////////////////////////////////
    function addLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId
    ) external override returns (bytes32) {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("Note", toCharacterId, toNoteId));
        if (tokenId != 0) {
            _linkNoteKeys[tokenId].add(linkKey);
        }
        _linkNotes[linkKey] = DataTypes.NoteStruct({characterId: toCharacterId, noteId: toNoteId});

        return linkKey;
    }

    function removeLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId
    ) external override {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("Note", toCharacterId, toNoteId));
        _linkNoteKeys[tokenId].remove(linkKey);

        // do note delete
        // delete linkNoteList[linkKey];
    }

    /////////////////////////////////
    // linking CharacterLink
    /////////////////////////////////
    function addLinkingCharacterLink(
        uint256 tokenId,
        DataTypes.CharacterLinkStruct calldata linkData
    ) external override {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(
            abi.encodePacked(
                "CharacterLink",
                linkData.fromCharacterId,
                linkData.toCharacterId,
                linkData.linkType
            )
        );
        if (tokenId != 0) {
            _linkingCharacterLinkKeys[tokenId].add(linkKey);
        }
        _linkingCharacterLinks[linkKey] = linkData;
    }

    function removeLinkingCharacterLink(
        uint256 tokenId,
        DataTypes.CharacterLinkStruct calldata linkData
    ) external override {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(
            abi.encodePacked(
                "CharacterLink",
                linkData.fromCharacterId,
                linkData.toCharacterId,
                linkData.linkType
            )
        );
        _linkingCharacterLinkKeys[tokenId].remove(linkKey);

        // do note delete
        // delete linkingCharacterLinkList[linkKey];
    }

    /////////////////////////////////
    // linking ERC721
    /////////////////////////////////
    function addLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external override returns (bytes32) {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("ERC721", tokenAddress, erc721TokenId));
        if (tokenId != 0) {
            _linkingERC721Keys[tokenId].add(linkKey);
        }
        _linkingERC721s[linkKey] = DataTypes.ERC721Struct({
            tokenAddress: tokenAddress,
            erc721TokenId: erc721TokenId
        });

        return linkKey;
    }

    function removeLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external override {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("ERC721", tokenAddress, erc721TokenId));
        _linkingERC721Keys[tokenId].remove(linkKey);

        // do not delete, maybe others link the same token
        // delete linkingERC721List[linkKey];
    }

    /////////////////////////////////
    // linking Address
    /////////////////////////////////
    function addLinkingAddress(uint256 tokenId, address ethAddress) external override {
        _validateCallerIsWeb3Entry();
        _linkingAddresses[tokenId].add(ethAddress);
    }

    function removeLinkingAddress(uint256 tokenId, address ethAddress) external override {
        _validateCallerIsWeb3Entry();
        _linkingAddresses[tokenId].remove(ethAddress);
    }

    /////////////////////////////////
    // linking Any Uri
    /////////////////////////////////
    function addLinkingAnyUri(uint256 tokenId, string memory toUri)
        external
        override
        returns (bytes32)
    {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", toUri));
        if (tokenId != 0) {
            _linkingAnyKeys[tokenId].add(linkKey);
        }
        _linkingAnys[linkKey] = toUri;
        return linkKey;
    }

    function removeLinkingAnyUri(uint256 tokenId, string memory toUri) external override {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", toUri));
        _linkingAnyKeys[tokenId].remove(linkKey);

        // do note delete
        // delete linkingAnylist[linkKey];
    }

    /////////////////////////////////
    // linking Linklist
    /////////////////////////////////
    function addLinkingLinklistId(uint256 tokenId, uint256 linklistId) external override {
        _validateCallerIsWeb3Entry();
        _linkingLinklists[tokenId].add(linklistId);
    }

    function removeLinkingLinklistId(uint256 tokenId, uint256 linklistId) external override {
        _validateCallerIsWeb3Entry();
        _linkingLinklists[tokenId].remove(linklistId);
    }

    function getLinkingCharacterIds(uint256 tokenId)
        external
        view
        override
        returns (uint256[] memory)
    {
        return _linkingCharacters[tokenId].values();
    }

    function getLinkingCharacterListLength(uint256 tokenId)
        external
        view
        override
        returns (uint256)
    {
        return _linkingCharacters[tokenId].length();
    }

    function getOwnerCharacterId(uint256 tokenId) external view override returns (uint256) {
        uint256 characterId = _linklistOwners[tokenId];
        return characterId;
    }

    function getLinkingNotes(uint256 tokenId)
        external
        view
        override
        returns (DataTypes.NoteStruct[] memory results)
    {
        bytes32[] memory linkKeys = _linkNoteKeys[tokenId].values();
        results = new DataTypes.NoteStruct[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = _linkNotes[key];
        }
    }

    function getLinkingNote(bytes32 linkKey)
        external
        view
        override
        returns (DataTypes.NoteStruct memory)
    {
        return _linkNotes[linkKey];
    }

    function getLinkingNoteListLength(uint256 tokenId) external view override returns (uint256) {
        return _linkNoteKeys[tokenId].length();
    }

    function getLinkingCharacterLinks(uint256 tokenId)
        external
        view
        override
        returns (DataTypes.CharacterLinkStruct[] memory results)
    {
        bytes32[] memory linkKeys = _linkingCharacterLinkKeys[tokenId].values();
        results = new DataTypes.CharacterLinkStruct[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = _linkingCharacterLinks[key];
        }
    }

    function getLinkingCharacterLink(bytes32 linkKey)
        external
        view
        override
        returns (DataTypes.CharacterLinkStruct memory)
    {
        return _linkingCharacterLinks[linkKey];
    }

    function getLinkingCharacterLinkListLength(uint256 tokenId)
        external
        view
        override
        returns (uint256)
    {
        return _linkingCharacterLinkKeys[tokenId].length();
    }

    function getLinkingERC721s(uint256 tokenId)
        external
        view
        override
        returns (DataTypes.ERC721Struct[] memory results)
    {
        bytes32[] memory linkKeys = _linkingERC721Keys[tokenId].values();
        results = new DataTypes.ERC721Struct[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = _linkingERC721s[key];
        }
    }

    function getLinkingERC721(bytes32 linkKey)
        external
        view
        override
        returns (DataTypes.ERC721Struct memory)
    {
        return _linkingERC721s[linkKey];
    }

    function getLinkingERC721ListLength(uint256 tokenId) external view override returns (uint256) {
        return _linkingERC721Keys[tokenId].length();
    }

    function getLinkingAddresses(uint256 tokenId)
        external
        view
        override
        returns (address[] memory)
    {
        return _linkingAddresses[tokenId].values();
    }

    function getLinkingAddressListLength(uint256 tokenId) external view override returns (uint256) {
        return _linkingAddresses[tokenId].length();
    }

    function getLinkingAnyUris(uint256 tokenId)
        external
        view
        override
        returns (string[] memory results)
    {
        bytes32[] memory linkKeys = _linkingAnyKeys[tokenId].values();
        results = new string[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = _linkingAnys[key];
        }
    }

    function getLinkingAnyUri(bytes32 linkKey) external view override returns (string memory) {
        return _linkingAnys[linkKey];
    }

    function getLinkingAnyUriKeys(uint256 tokenId)
        external
        view
        override
        returns (bytes32[] memory)
    {
        return _linkingAnyKeys[tokenId].values();
    }

    function getLinkingAnyListLength(uint256 tokenId) external view override returns (uint256) {
        return _linkingAnyKeys[tokenId].length();
    }

    function getLinkingLinklistIds(uint256 tokenId)
        external
        view
        override
        returns (uint256[] memory)
    {
        return _linkingLinklists[tokenId].values();
    }

    function getLinkingLinklistLength(uint256 tokenId) external view override returns (uint256) {
        return _linkingLinklists[tokenId].length();
    }

    /////////////////////////////////
    // common
    /////////////////////////////////
    function getCurrentTakeOver(uint256 tokenId)
        external
        view
        override
        returns (uint256 characterId)
    {} // solhint-disable-line no-empty-blocks

    function getLinkType(uint256 tokenId) external view override returns (bytes32) {
        return _linkTypes[tokenId];
    }

    // solhint-disable-next-line func-name-mixedcase
    function Uri(uint256 tokenId) external view override returns (string memory) {
        return _getTokenUri(tokenId);
    }

    function totalSupply() public view override returns (uint256) {
        return _tokenCount;
    }

    function balanceOf(uint256 characterId) public view override returns (uint256) {
        return _linklistBalances[characterId];
    }

    function balanceOf(address account)
        public
        view
        override(IERC721, ERC721)
        returns (uint256 balance)
    {
        uint256 characterCount = IERC721Enumerable(Web3Entry).balanceOf(account);
        for (uint256 i = 0; i < characterCount; i++) {
            uint256 characterId = IERC721Enumerable(Web3Entry).tokenOfOwnerByIndex(account, i);
            balance += balanceOf(characterId);
        }
    }

    /**
     * @notice returns the characterId who owns the given tokenId.
     * @param tokenId The token id of the linklist.
     */
    function characterOwnerOf(uint256 tokenId) public view override returns (uint256) {
        uint256 characterId = _linklistOwners[tokenId];
        return characterId;
    }

    function ownerOf(uint256 tokenId) public view override(IERC721, ERC721) returns (address) {
        uint256 characterId = characterOwnerOf(tokenId);
        address owner = IERC721Enumerable(Web3Entry).ownerOf(characterId);
        return owner;
    }

    function _getTokenUri(uint256 tokenId) internal view returns (string memory) {
        return _uris[tokenId];
    }

    function _validateCallerIsWeb3Entry() internal view {
        if (msg.sender != Web3Entry) revert ErrCallerNotWeb3Entry();
    }

    function _validateCallerIsWeb3EntryOrOwner(uint256 tokenId) internal view {
        if (msg.sender != Web3Entry && msg.sender != ownerOf(tokenId))
            revert ErrCallerNotWeb3EntryOrNotOwner();
    }

    function _safeTransfer(
        address,
        address,
        uint256,
        bytes memory // solhint-disable-next-line no-empty-blocks
    ) internal pure override {
        // this function will do nothing, as linklist is a character bounded token
        // users should never transfer a linklist directly
    }

    function _transfer(
        address,
        address,
        uint256 // solhint-disable-next-line no-empty-blocks
    ) internal pure override {
        // this function will do nothing, as linklist is a character bounded token
        // users should never transfer a linklist directly
    }
}
