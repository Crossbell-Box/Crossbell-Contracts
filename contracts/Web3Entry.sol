// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./base/NFTBase.sol";
import "./interfaces/IWeb3Entry.sol";
import "./interfaces/ILinklistNFT.sol";
import "./storage/Web3EntryStorage.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Web3Entry is IWeb3Entry, NFTBase, Web3EntryStorage {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    bool private _initialized;

    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _linkListContract
    ) external {
        require(!_initialized, "Web3Entry: Initialized");

        super._initialize(_name, _symbol);
        linkList = _linkListContract;

        emit Events.Web3EntryInitialized(block.timestamp);
    }

    function createProfile(
        address to,
        string calldata handle,
        string calldata metadataURI
    ) external {
        uint256 profileId = ++_profileCounter;
        _mint(to, profileId);

        bytes32 handleHash = keccak256(bytes(handle));
        require(
            _profileIdByHandleHash[handleHash] == 0,
            "Web3Entry: HandleExists"
        );
        _profileIdByHandleHash[handleHash] = profileId;

        _profileById[profileId].handle = handle;
        _profileById[profileId].metadataURI = metadataURI;

        emit Events.ProfileCreated(
            profileId,
            msg.sender,
            to,
            handle,
            block.timestamp
        );
    }

    function setHandle(uint256 profileId, string calldata newHandle) external {
        _validateCallerIsProfileOwner(profileId);

        // remove old handle
        string memory oldHandle = _profileById[profileId].handle;
        bytes32 oldHandleHash = keccak256(bytes(oldHandle));
        delete _profileIdByHandleHash[oldHandleHash];

        // set new handle
        bytes32 handleHash = keccak256(bytes(newHandle));
        require(
            _profileIdByHandleHash[handleHash] == 0,
            "Web3Entry: HandleExists"
        );

        _profileIdByHandleHash[handleHash] = profileId;

        _profileById[profileId].handle = newHandle;

        emit Events.SetHandle(msg.sender, profileId, newHandle);
    }

    function setProfileMetadataURI(
        uint256 profileId,
        string calldata newMetadataURI
    ) external {
        _validateCallerIsProfileOwner(profileId);

        _profileById[profileId].metadataURI = newMetadataURI;
    }

    function setPrimaryProfile(uint256 profileId) external {
        _validateCallerIsProfileOwner(profileId);

        _primaryProfileByAddress[msg.sender] = profileId;

        emit Events.SetPrimaryProfile(msg.sender, profileId);
    }

    function setPrimaryLinkList(uint256 linkListTokenId, uint256 profileId)
        public
    {
        _takeOverLinkList(linkListTokenId, profileId);
        _primaryLinkListByProfileId[profileId] = linkListTokenId;
    }

    function setLinklistURI(
        uint256 linkListTokenId,
        string calldata linklistURI
    ) external {
        _validateCallerIsLinklistOwner(linkListTokenId);

        ILinklistNFT(linkList).setURI(linkListTokenId, linklistURI);
    }

    //
    // function setSocialTokenAddress(uint256 profileId, address tokenAddress) external {} // next launch

    // TODO: add a arbitrary data param passed to link/mint. Is there any cons?

    // emit a link from a profile
    function linkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        require(_exists(toProfileId), "Web3Entry: toProfileId not exist");

        uint256 linkListTokenId = _primaryLinkListByProfileId[fromProfileId];
        if (linkListTokenId == 0) {
            linkListTokenId = IERC721Enumerable(linkList).totalSupply().add(1);
            // mint linkList nft
            ILinklistNFT(linkList).mint(msg.sender, linkListTokenId);
            // set primary linkList
            setPrimaryLinkList(linkListTokenId, fromProfileId);
        }

        // add to link list
        ILinklistNFT(linkList).addLinkedProfileId(
            linkListTokenId,
            linkType,
            toProfileId
        );

        emit Events.LinkProfile(
            msg.sender,
            fromProfileId,
            toProfileId,
            linkType
        );
    }

    function unlinkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        require(_exists(toProfileId), "Web3Entry: toProfileId not exist");

        uint256 linkListTokenId = _primaryLinkListByProfileId[fromProfileId];
        uint256 profileId = ILinklistNFT(linkList).getCurrentTakeOver(
            linkListTokenId
        );
        require(profileId == fromProfileId, "Web3Entry: unauthorised linkList");

        // remove from link list
        ILinklistNFT(linkList).removeLinkedProfileId(
            linkListTokenId,
            linkType,
            toProfileId
        );

        emit Events.UnlinkProfile(
            msg.sender,
            fromProfileId,
            toProfileId,
            linkType
        );
    }

    function _takeOverLinkList(uint256 tokenId, uint256 profileId) internal {
        _validateCallerIsProfileOwner(profileId);

        ILinklistNFT(linkList).takeOver(tokenId, msg.sender, profileId);
    }

    //    function linkNote(
    //        uint256 fromProfileId,
    //        uint256 toProfileId,
    //        uint256 toNoteId,
    //        bytes32 linkType
    //    ) external {}

    // next launch
    // When implement, should check if ERC721 is linklist contract
    function linkERC721(
        uint256 fromProfileId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType
    ) external {}

    //TODO linkERC1155
    function linkAddress(
        uint256 fromProfileId,
        address ethAddress,
        bytes32 linkType
    ) external {}

    function linkAny(
        uint256 fromProfileId,
        string calldata toURI,
        bytes32 linkType
    ) external {}

    function linkSingleLinkItem(
        uint256 fromProfileId,
        uint256 linkListNFTId,
        uint256 linkId,
        bytes32 linkType
    ) external {}

    function linkLinklist(
        uint256 fromProfileId,
        uint256 linkListNFTId,
        bytes32 linkType
    ) external {}

    function setLinkModule4Profile(uint256 profileId, address moduleAddress)
        external
    {} // set link module for his profile

    function setLinkModule4Note(
        uint256 profileId,
        uint256 toNoteId,
        address moduleAddress
    ) external {} // set link module for his profile

    // ERC721? // add to discussion
    // address?
    // single link item?
    // link list?

    // function mintNote( uint256 toProfileId, uint256 toNoteId, address receiver) external {}// next launch
    function mintSingleLinkItem(
        uint256 linkListNFTId,
        uint256 linkId,
        address receiver
    ) external {}

    function setMintModule4Note(
        uint256 profileId,
        uint256 toNoteId,
        address moduleAddress
    ) external {} // set mint module for himself

    function setMintModule4SingleLinkItem(
        uint256 linkListNFTId,
        uint256 linkId,
        address moduleAddress
    ) external {} // set mint module for his single link item

    //     function setMintModule4Note() // next launch

    // function postNote() // next launch
    // function postNoteWithLink() // next launch

    function setLinkListURI(
        uint256 profileId,
        bytes32 linkType,
        string memory URI
    ) external {}

    // TODO: View functions
    function getPrimaryProfile(address account)
        external
        view
        returns (uint256)
    {
        return _primaryProfileByAddress[account];
    }

    function getProfile(uint256 profileId)
        external
        view
        returns (DataTypes.Profile memory)
    {
        return _profileById[profileId];
    }

    function getProfileIdByHandle(string calldata handle)
        external
        view
        returns (uint256)
    {
        bytes32 handleHash = keccak256(bytes(handle));
        return _profileIdByHandleHash[handleHash];
    }

    function getHandle(uint256 profileId)
        external
        view
        returns (string memory)
    {
        return _profileById[profileId].handle;
    }

    function getProfileMetadataURI(uint256 profileId)
        external
        view
        returns (string memory)
    {
        return tokenURI(profileId);
    }

    function getLinkModuleByProfile(uint256 profileId)
        external
        view
        returns (address)
    {}

    function tokenURI(uint256 profileId)
        public
        view
        override
        returns (string memory)
    {
        return _profileById[profileId].metadataURI;
    }

    function getLinkListURI(uint256 profileId)
        external
        view
        returns (string memory)
    {
        uint256 tokenId = _primaryLinkListByProfileId[profileId];
        return ILinklistNFT(linkList).URI(tokenId);
    }

    function getLinkedProfileIds(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory)
    {
        uint256 linkListTokenId = _primaryLinkListByProfileId[fromProfileId];
        return
            ILinklistNFT(linkList).getLinkedProfileIds(
                linkListTokenId,
                linkType
            );
    }

    function _validateCallerIsProfileOwner(uint256 profileId) internal view {
        require(msg.sender == ownerOf(profileId), "Web3Entry: NotProfileOwner");
    }

    function _validateCallerIsLinklistOwner(uint256 tokenId) internal view {
        require(
            msg.sender == ERC721(linkList).ownerOf(tokenId),
            "NotLinkListOwner"
        );
    }

    function _getLinkListTokenId(uint256 profileId, bytes32 linkType)
        internal
        pure
        returns (uint256)
    {
        bytes32 label = keccak256(abi.encodePacked(profileId, linkType));
        return uint256(label);
    }
}
