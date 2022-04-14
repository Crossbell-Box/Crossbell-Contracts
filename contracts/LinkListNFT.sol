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
        internal link2ProfileList;
    // profileId => linkType  => external addresses
    mapping(uint256 => mapping(bytes32 => EnumerableSet.AddressSet))
        internal link2AddressList;
    // tokenId => profileId

    mapping(uint256 => uint256) internal currentTakeOver;
    mapping(uint256 => string) internal _Uris; // tokenId => tokenURI

    bool private _initialized;
    address public web3Entry;

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

    function setTakeOver(
        uint256 tokenId,
        address to,
        uint256 profileId
    ) external {
        _validateCallerIsWeb3Entry();

        require(to == ownerOf(tokenId), "LinkList: not token owner");

        currentTakeOver[tokenId] = profileId;
    }

    function setUri(uint256 tokenId, string memory _Uri) external {
        _validateCallerIsWeb3Entry();

        require(
            _exists(tokenId),
            "LinkList: setTokenURI for nonexistent token"
        );

        _Uris[tokenId] = _Uri;
    }

    function addLinking2ProfileId(
        uint256 tokenId,
        bytes32 linkType,
        uint256 toProfileId
    ) external {
        _validateCallerIsWeb3Entry();

        link2ProfileList[tokenId][linkType].add(toProfileId);
    }

    function removeLinking2ProfileId(
        uint256 tokenId,
        bytes32 linkType,
        uint256 toProfileId
    ) external {
        _validateCallerIsWeb3Entry();

        link2ProfileList[tokenId][linkType].remove(toProfileId);
    }

    function getLinking2ProfileIds(uint256 tokenId, bytes32 linkType)
        external
        view
        returns (uint256[] memory)
    {
        return link2ProfileList[tokenId][linkType].values();
    }

    function getLinking2ProfileListLength(uint256 tokenId, bytes32 linkType)
        external
        view
        returns (uint256)
    {
        return link2ProfileList[tokenId][linkType].length();
    }

    function getCurrentTakeOver(uint256 tokenId)
        external
        view
        returns (uint256 profileId)
    {
        profileId = currentTakeOver[tokenId];
    }

    function Uri(uint256 tokenId) external view returns (string memory) {
        return _getTokenUri(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
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

    function _getTokenUri(uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        require(_exists(tokenId), "LinkList: URI query for nonexistent token");

        return _Uris[tokenId];
    }

    function _validateCallerIsWeb3Entry() internal view {
        //TODO: Or token owner?
        require(msg.sender == web3Entry, "LinkList: NotWeb3Entry");
    }
}
