// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./interfaces/ILinklistNFT.sol";
import "./base/NFTBase.sol";
import "./libraries/Events.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LinkListNFT is ILinklistNFT, NFTBase {
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

    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _web3Entry
    ) external {
        require(!_initialized, "LinkListNFT: Initialized");
        _initialized = true;

        web3Entry = _web3Entry;

        super._initialize(_name, _symbol);
        emit Events.LinkListNFTInitialized(block.timestamp);
    }

    function mint(address to, uint256 tokenId) external override {
        _validateCallerIsWeb3Entry();

        _mint(to, tokenId);
    }

    function takeOver(
        uint256 tokenId,
        address to,
        uint256 profileId
    ) external {
        _validateCallerIsWeb3Entry();

        require(to == ownerOf(tokenId), "LinkList: not token owner");

        currentTakeOver[tokenId] = profileId;
    }

    function setURI(uint256 tokenId, string memory _URI) external {
        _validateCallerIsWeb3Entry();

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
        _validateCallerIsWeb3Entry();

        linkedProfileIds[tokenId][linkType].add(toProfileId);
    }

    function removeLinkedProfileId(
        uint256 tokenId,
        bytes32 linkType,
        uint256 toProfileId
    ) external {
        _validateCallerIsWeb3Entry();

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

    function _validateCallerIsWeb3Entry() internal view {
        require(msg.sender == web3Entry, "LinkList: NotWeb3Entry");
    }
}
