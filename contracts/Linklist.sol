// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./interfaces/ILinklist.sol";
import "./base/NFTBase.sol";
import "./libraries/Events.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Linklist is ILinklist, NFTBase {
    using EnumerableSet for EnumerableSet.UintSet;

    // tokenId => linkType
    mapping(uint256 => bytes32) internal linkTypes;

    // tokenId =>  profileIds
    mapping(uint256 => EnumerableSet.UintSet) internal linkingProfileList;
    // tokenId => external addresses
    mapping(uint256 => EnumerableSet.AddressSet) internal linkingAddressList;
    // tokenId => noteIds
    mapping(uint256 => EnumerableSet.UintSet) internal linkingNoteList;

    // tokenId => profileId
    mapping(uint256 => uint256) internal currentTakeOver;
    mapping(uint256 => string) internal _uris; // tokenId => tokenURI

    bool private _initialized;
    address public web3Entry;

    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _web3Entry
    ) external {
        require(!_initialized, "LinklistNFT: Initialized");
        _initialized = true;

        web3Entry = _web3Entry;

        super._initialize(_name, _symbol);
        emit Events.LinklistNFTInitialized(block.timestamp);
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