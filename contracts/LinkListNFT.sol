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

    bool private _initialized;
    address public web3Entry;

    mapping(uint256 => string) internal _URIs; // tokenId => tokenURI

    // link NFT contract vars
    // TODO: add category ? profileId => category => linkType => []linkId
    mapping(uint256 => mapping(bytes32 => EnumerableSet.UintSet))
        internal linkList;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}

    function _getTokenId(uint256 profileId, bytes32 linkType)
        internal
        pure
        returns (uint256)
    {
        bytes32 label = keccak256(abi.encodePacked(profileId, linkType));
        return uint256(label);
    }

    function getTokenId(uint256 profileId, bytes32 linkType)
        external
        pure
        returns (uint256)
    {
        return _getTokenId(profileId, linkType);
    }

    // TODO: maybe there is a more elegant way setting web3Entry address
    function initialize(address _web3Entry) external {
        if (_initialized) revert Errors.Initialized();

        _initialized = true;
        web3Entry = _web3Entry;
    }

    function mint(
        uint256 profileId,
        bytes32 linkType,
        address to
    ) external override {
        if (msg.sender != web3Entry) revert Errors.NotWeb3Entry();

        _mint(to, _getTokenId(profileId, linkType));
    }

    function setURI(uint256 tokenId, string memory _URI) external {
        if (msg.sender != web3Entry) revert Errors.NotWeb3Entry();
        require(
            _exists(tokenId),
            "LinkList: setTokenURI for nonexistent token"
        );

        _URIs[tokenId] = _URI;
    }

    function addLinkList(
        uint256 profileId,
        bytes32 linkType,
        uint256 linkId
    ) external {
        if (msg.sender != web3Entry) revert Errors.NotWeb3Entry();

        linkList[profileId][linkType].add(linkId);
    }

    function removeLinkList(
        uint256 profileId,
        bytes32 linkType,
        uint256 linkId
    ) external {
        if (msg.sender != web3Entry) revert Errors.NotWeb3Entry();

        linkList[profileId][linkType].add(linkId);
    }

    function getLinkList(uint256 profileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory)
    {
        return linkList[profileId][linkType].values();
    }

    function getLinkListLength(uint256 profileId, bytes32 linkType)
        external
        view
        returns (uint256)
    {
        return linkList[profileId][linkType].length();
    }

    function existsLinkList(uint256 profileId, bytes32 linkType)
        external
        view
        returns (bool)
    {
        return _exists(_getTokenId(profileId, linkType));
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
