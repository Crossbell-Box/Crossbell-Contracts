// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/ILinklistNFT.sol";
import "./libraries/Errors.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LinkListNFT is ILinklistNFT, ERC721Enumerable {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeMath for uint256;

    // tokenId => linkType  => profileIds
    mapping(uint256 => mapping(bytes32 => EnumerableSet.UintSet))
        internal linkedProfileIds;
    // profileId => linkType  => external addresses
    mapping(uint256 => mapping(bytes32 => EnumerableSet.AddressSet))
        internal profile2AddressLinks;
    // tokenId => profileId
    mapping(uint256 => uint256) internal currentTakeOver;

    bool private _initialized;
    address public web3Entry;

    mapping(uint256 => string) internal _URIs; // tokenId => tokenURI

    // link NFT contract vars
    //  profileId => category => linkType => []linkId
    mapping(uint256 => mapping(bytes32 => EnumerableSet.UintSet))
        internal linkList;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}

    // TODO: maybe there is a more elegant way setting web3Entry address
    function initialize(address _web3Entry) external {
        if (_initialized) revert Errors.Initialized();

        _initialized = true;
        web3Entry = _web3Entry;
    }

    function mint(address to, uint256 tokenId) external override {
        if (msg.sender != web3Entry) revert Errors.NotWeb3Entry();

        _mint(to, tokenId);
    }

    function takeOver(
        uint256 tokenId,
        address to,
        uint256 profileId
    ) external {
        if (msg.sender != web3Entry) revert Errors.NotWeb3Entry();
        require(to == ownerOf(tokenId), "LinkList: not token owner");

        currentTakeOver[tokenId] = profileId;
    }

    function setURI(uint256 tokenId, string memory _URI) external {
        if (msg.sender != web3Entry) revert Errors.NotWeb3Entry();
        require(
            _exists(tokenId),
            "LinkList: setTokenURI for nonexistent token"
        );

        _URIs[tokenId] = _URI;
    }

    function addLinkedProfileId(
        uint256 tokenId,
        bytes32 linkType,
        uint256 toProfileId
    ) external {
        if (msg.sender != web3Entry) revert Errors.NotWeb3Entry();

        linkedProfileIds[tokenId][linkType].add(toProfileId);
    }

    function removeLinkedProfileId(
        uint256 tokenId,
        bytes32 linkType,
        uint256 toProfileId
    ) external {
        if (msg.sender != web3Entry) revert Errors.NotWeb3Entry();

        linkedProfileIds[tokenId][linkType].remove(toProfileId);
    }

    function getLinkedProfileIds(uint256 tokenId, bytes32 linkType)
        external
        view
        returns (uint256[] memory)
    {
        return linkedProfileIds[tokenId][linkType].values();
    }

    function getLinkedProfileIdsLength(uint256 tokenId, bytes32 linkType)
        external
        view
        returns (uint256)
    {
        return linkedProfileIds[tokenId][linkType].length();
    }

    function getCurrentTakeOver(uint256 tokenId)
        external
        view
        returns (uint256)
    {
        return currentTakeOver[tokenId];
    }

    function URI(uint256 tokenId) external view returns (string memory) {
        return _getTokenURI(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return _getTokenURI(tokenId);
    }

    function _getTokenURI(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        require(_exists(tokenId), "LinkList: URI query for nonexistent token");

        return _URIs[tokenId];
    }
}
