// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./interfaces/ILinklist.sol";
import "./base/NFTBase.sol";
import "./libraries/Events.sol";
import "./libraries/DataTypes.sol";
import "./storage/LinklistStorage.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Linklist is ILinklist, NFTBase, LinklistStorage, Initializable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _web3Entry
    ) external initializer {
        web3Entry = _web3Entry;

        super._initialize(_name, _symbol);
        emit Events.LinklistNFTInitialized(block.timestamp);
    }

    function getWeb3Entry() external view returns (address) {
        return web3Entry;
    }

    function mint(
        address to,
        bytes32 linkType,
        uint256 tokenId
    ) external override {
        _validateCallerIsWeb3Entry();

        linkTypes[tokenId] = linkType;
        _mint(to, tokenId);
    }

    function setTakeOver(
        uint256 tokenId,
        address to,
        uint256 profileId
    ) external {
        _validateCallerIsWeb3Entry();
        require(to == ownerOf(tokenId), "Linklist: not token owner");

        currentTakeOver[tokenId] = profileId;
    }

    function setUri(uint256 tokenId, string memory _uri) external {
        require(_exists(tokenId), "Linklist: setUri for nonexistent token");
        _validateCallerIsWeb3EntryOrOwner(tokenId);

        _uris[tokenId] = _uri;
    }

    function addLinkingProfileId(uint256 tokenId, uint256 toProfileId) external {
        _validateCallerIsWeb3Entry();
        linkingProfileList[tokenId].add(toProfileId);
    }

    function removeLinkingProfileId(uint256 tokenId, uint256 toProfileId) external {
        _validateCallerIsWeb3Entry();
        linkingProfileList[tokenId].remove(toProfileId);
    }

    function getLinkingProfileIds(uint256 tokenId) external view returns (uint256[] memory) {
        return linkingProfileList[tokenId].values();
    }

    function getLinkingProfileListLength(uint256 tokenId) external view returns (uint256) {
        return linkingProfileList[tokenId].length();
    }

    function addLinkingNote(
        uint256 tokenId,
        uint256 toProfileId,
        uint256 toNoteId
    ) external {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked(toProfileId, toNoteId));
        linkKeysList[tokenId].add(linkKey);

        linkNoteList[linkKey] = DataTypes.linkNoteItem({profileId: toProfileId, noteId: toNoteId});
    }

    function removeLinkingNote(
        uint256 tokenId,
        uint256 toProfileId,
        uint256 toNoteId
    ) external {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked(toProfileId, toNoteId));
        linkKeysList[tokenId].remove(linkKey);

        delete linkNoteList[linkKey];
    }

    function getLinkingNotes(uint256 tokenId)
        external
        view
        returns (DataTypes.linkNoteItem[] memory results)
    {
        bytes32[] memory linkKeys = linkKeysList[tokenId].values();

        results = new DataTypes.linkNoteItem[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = linkNoteList[key];
        }
    }

    function getLinkingNoteListLength(uint256 tokenId) external view returns (uint256) {
        return linkKeysList[tokenId].length();
    }

    function addLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked(tokenAddress, erc721TokenId));
        linkKeysList[tokenId].add(linkKey);

        linkingERC721list[linkKey] = DataTypes.linkERC721Item({
            tokenAddress: tokenAddress,
            erc721TokenId: erc721TokenId
        });
    }

    function removeLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked(tokenAddress, erc721TokenId));
        linkKeysList[tokenId].remove(linkKey);

        delete linkingERC721list[linkKey];
    }

    function getLinkingERC721s(uint256 tokenId)
        external
        view
        returns (DataTypes.linkERC721Item[] memory results)
    {
        bytes32[] memory linkKeys = linkKeysList[tokenId].values();

        results = new DataTypes.linkERC721Item[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = linkingERC721list[key];
        }
    }

    function getLinkingERC721ListLength(uint256 tokenId) external view returns (uint256) {
        return linkKeysList[tokenId].length();
    }

    function getCurrentTakeOver(uint256 tokenId) external view returns (uint256 profileId) {
        profileId = currentTakeOver[tokenId];
    }

    function getLinkType(uint256 tokenId) external view returns (bytes32) {
        return linkTypes[tokenId];
    }

    function Uri(uint256 tokenId) external view returns (string memory) {
        return _getTokenUri(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return _getTokenUri(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        currentTakeOver[tokenId] = 0;

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _getTokenUri(uint256 tokenId) internal view returns (string memory) {
        require(_exists(tokenId), "Linklist: URI query for nonexistent token");

        return _uris[tokenId];
    }

    function _validateCallerIsWeb3Entry() internal view {
        require(msg.sender == web3Entry, "Linklist: NotWeb3Entry");
    }

    function _validateCallerIsWeb3EntryOrOwner(uint256 tokenId) internal view {
        require(
            msg.sender == web3Entry || msg.sender == ownerOf(tokenId),
            "Linklist: NotWeb3EntryOrNotOwner"
        );
    }
}
