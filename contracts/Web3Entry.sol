// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IWeb3Entry.sol";
import "./interfaces/ILinklistNFT.sol";
import "./storage/Web3EntryStorage.sol";
import "./libraries/Errors.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";

contract Web3Entry is IWeb3Entry, ERC721Enumerable, Web3EntryStorage {
    using Counters for Counters.Counter;

    constructor(
        string memory _name,
        string memory _symbol,
        address _linkListContract
    ) ERC721(_name, _symbol) {
        linkList = _linkListContract;
    }

    function createProfile(
        address to,
        string calldata handle,
        string calldata metadataURI
    ) external {
        uint256 profileId = ++_profileCounter;
        _mint(to, profileId);

        bytes32 handleHash = keccak256(bytes(handle));
        if (_profileIdByHandleHash[handleHash] != 0)
            revert Errors.HandleExists();
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
        if (_profileIdByHandleHash[handleHash] != 0)
            revert Errors.HandleExists();
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

    function setLinklistURI(
        uint256 profileId,
        bytes32 linkType,
        string calldata linklistURI
    ) external {
        _validateCallerIsLinklistOwner(profileId, linkType);

        uint256 tokenId = ILinklistNFT(linkList).getTokenId(
            profileId,
            linkType
        );
        ILinklistNFT(linkList).setURI(tokenId, linklistURI);
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

        if (!ILinklistNFT(linkList).existsLinkList(fromProfileId, linkType)) {
            // mint linkList nft
            ILinklistNFT(linkList).mint(fromProfileId, linkType, msg.sender);
        }

        // create and save link item
        linkCounts[fromProfileId][linkType].increment();
        uint256 linkId = linkCounts[fromProfileId][linkType].current();
        profile2ProfileCount.increment();

        profile2ProfileLinks[linkType][linkId].fromProfileId = fromProfileId;
        profile2ProfileLinks[linkType][linkId].toProfileId = toProfileId;
        profile2ProfileLinks[linkType][linkId].linkId = linkId;
        // add linkList
        ILinklistNFT(linkList).addLinkList(fromProfileId, linkType, linkId);

        emit Events.LinkProfile(
            msg.sender,
            fromProfileId,
            toProfileId,
            linkType
        );
    }

    function unlinkProfile(
        uint256 fromProfileId,
        bytes32 linkType,
        uint256 linkId
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        // TODO: check linkId

        linkCounts[fromProfileId][linkType].decrement();
        profile2ProfileCount.decrement();

        delete profile2ProfileLinks[linkType][linkId];
        // remove linkList
        ILinklistNFT(linkList).removeLinkList(fromProfileId, linkType, linkId);

        emit Events.UnlinkProfile(msg.sender, fromProfileId, linkType, linkId);
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

    // returns profileId array
    function getLinkListByProfile(uint256 profileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory)
    {
        return ILinklistNFT(linkList).getLinkList(profileId, linkType);
    }

    function tokenURI(uint256 profileId)
        public
        view
        override
        returns (string memory)
    {
        return _profileById[profileId].metadataURI;
    }

    function getLinkListURI(uint256 profileId, bytes32 linkType)
        external
        view
        returns (string memory)
    {
        uint256 tokenId = ILinklistNFT(linkList).getTokenId(
            profileId,
            linkType
        );
        return ILinklistNFT(linkList).URI(tokenId);
    }

    function getProfile2ProfileLinkItem(bytes32 linkType, uint256 linkId)
        external
        view
        returns (DataTypes.Profile2ProfileLink memory)
    {
        return profile2ProfileLinks[linkType][linkId];
    }

    function getProfile2ProfileLinkItems(
        uint256 fromProfileId,
        bytes32 linkType
    ) external view returns (DataTypes.Profile2ProfileLink[] memory results) {
        uint256 total = linkCounts[fromProfileId][linkType].current();
        results = new DataTypes.Profile2ProfileLink[](total);
        uint256 j = 0;
        for (uint256 i = 0; i < profile2ProfileCount.current(); i++) {
            if (
                profile2ProfileLinks[linkType][i].fromProfileId == fromProfileId
            ) {
                results[j] = profile2ProfileLinks[linkType][i];
            }
            j++;
        }
    }

    function _validateCallerIsProfileOwner(uint256 profileId) internal view {
        require(msg.sender == ownerOf(profileId), "NotProfileOwner");
    }

    function _validateCallerIsLinklistOwner(uint256 profileId, bytes32 linkType)
        internal
        view
    {
        require(
            msg.sender ==
                ERC721(linkList).ownerOf(
                    ILinklistNFT(linkList).getTokenId(profileId, linkType)
                ),
            "NotLinkListOwner"
        );
    }
}
