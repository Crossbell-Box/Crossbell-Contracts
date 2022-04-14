// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./base/NFTBase.sol";
import "./interfaces/IWeb3Entry.sol";
import "./interfaces/ILinklistNFT.sol";
import "./storage/Web3EntryStorage.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Web3Entry is IWeb3Entry, NFTBase, Web3EntryStorage {
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
        string calldata metadataUri
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
        _profileById[profileId].metadataUri = metadataUri;

        // set primary profile
        if (_primaryProfileByAddress[to] == 0) {
            _primaryProfileByAddress[to] = profileId;
        }
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

    function setProfileMetadataUri(
        uint256 profileId,
        string calldata newMetadataUri
    ) external {
        _validateCallerIsProfileOwner(profileId);

        _profileById[profileId].metadataUri = newMetadataUri;
    }

    function setPrimaryProfileId(uint256 profileId) external {
        _validateCallerIsProfileOwner(profileId);

        _primaryProfileByAddress[msg.sender] = profileId;

        emit Events.SetPrimaryProfileId(msg.sender, profileId);
    }

    function setPrimaryLinkList(uint256 linkListTokenId, uint256 profileId)
        public
    {
        _takeOverLinkList(linkListTokenId, profileId);
        _primaryLinkListByProfileId[profileId] = linkListTokenId;
    }

    function setLinklistUri(
        uint256 linkListTokenId,
        string calldata linklistUri
    ) external {
        _validateCallerIsLinklistOwner(linkListTokenId);

        ILinklistNFT(linkList).setUri(linkListTokenId, linklistUri);
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
        ILinklistNFT(linkList).addLinking2ProfileId(
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
        ILinklistNFT(linkList).removeLinking2ProfileId(
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

        ILinklistNFT(linkList).setTakeOver(tokenId, msg.sender, profileId);
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
        string calldata toUri,
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

    function postNote(
        uint256 profileId,
        string calldata contentURI,
        address linkModule,
        bytes calldata linkModuleInitData,
        address mintModule,
        bytes calldata mintModuleInitData
    ) external returns (uint256) {
        _validateCallerIsProfileOwner(profileId);

        return
            _postNote(
                profileId,
                contentURI,
                linkModule,
                linkModuleInitData,
                mintModule,
                mintModuleInitData
            );
    }

    //    function postNoteWithLink(uint256 profileId, string calldata contentURI)
    //        external;

    function setLinkListUri(
        uint256 profileId,
        bytes32 linkType,
        string memory Uri
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

    function getProfileId(string calldata handle)
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

    function getProfileMetadataUri(uint256 profileId)
        external
        view
        returns (string memory)
    {
        return tokenURI(profileId);
    }

    function getProfileLinkModule(uint256 profileId)
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
        return _profileById[profileId].metadataUri;
    }

    function getLinkListUri(uint256 profileId)
        external
        view
        returns (string memory)
    {
        uint256 tokenId = _primaryLinkListByProfileId[profileId];
        return ILinklistNFT(linkList).Uri(tokenId);
    }

    function getLinkedProfileIds(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory)
    {
        uint256 linkListTokenId = _primaryLinkListByProfileId[fromProfileId];
        return
            ILinklistNFT(linkList).getLinking2ProfileIds(
                linkListTokenId,
                linkType
            );
    }

    function getNoteURI(uint256 profileId, uint256 noteId)
        external
        view
        returns (string memory)
    {
        return _noteByIdByProfile[profileId][noteId].contentURI;
    }

    function _postNote(
        uint256 profileId,
        string calldata contentURI,
        address linkModule,
        bytes calldata linkModuleInitData,
        address mintModule,
        bytes calldata mintModuleInitData
    ) internal returns (uint256) {
        uint256 noteId = ++_profileById[profileId].noteCount;

        // save note
        _noteByIdByProfile[profileId][noteId].noteType = DataTypes.NoteTypeNote;
        _noteByIdByProfile[profileId][noteId].contentURI = contentURI;
        _noteByIdByProfile[profileId][noteId].linkModule = linkModule;
        _noteByIdByProfile[profileId][noteId].mintModule = mintModule;
        // TODO: init mint module
        // init link module

        return noteId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        if (_primaryProfileByAddress[from] != 0) {
            _primaryProfileByAddress[from] = 0;
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _validateCallerIsProfileOwner(uint256 profileId) internal view {
        require(msg.sender == ownerOf(profileId), "Web3Entry: NotProfileOwner");
    }

    function _validateCallerIsLinklistOwner(uint256 tokenId) internal view {
        require(
            msg.sender == ERC721(linkList).ownerOf(tokenId),
            "Web3Entry: NotLinkListOwner"
        );
    }
}
