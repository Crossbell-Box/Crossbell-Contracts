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

    function setSocialToken(uint256 profileId, address tokenAddress) external {
        _validateCallerIsProfileOwner(profileId);

        require(
            _profileById[profileId].socialTokenAddress == address(0),
            "Web3Entry: SocialTokenExists"
        );

        _profileById[profileId].socialTokenAddress = tokenAddress;

        emit Events.SetSocialToken(msg.sender, profileId, tokenAddress);
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

    function setPrimaryLinkList(uint256 linkListId, uint256 profileId) public {
        _takeOverLinkList(linkListId, profileId);
        _primaryLinkListByProfileId[profileId] = linkListId;
    }

    function setLinklistUri(uint256 linkListId, string calldata linklistUri)
        external
    {
        _validateCallerIsLinklistOwner(linkListId);

        ILinklistNFT(linkList).setUri(linkListId, linklistUri);
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

        uint256 linkListId = _primaryLinkListByProfileId[fromProfileId];
        if (linkListId == 0) {
            linkListId = IERC721Enumerable(linkList).totalSupply().add(1);
            // mint linkList nft
            ILinklistNFT(linkList).mint(msg.sender, linkListId);
            // set primary linkList
            setPrimaryLinkList(linkListId, fromProfileId);
        }

        // add to link list
        ILinklistNFT(linkList).addLinking2ProfileId(
            linkListId,
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

        uint256 linkListId = _primaryLinkListByProfileId[fromProfileId];
        uint256 profileId = ILinklistNFT(linkList).getCurrentTakeOver(
            linkListId
        );
        require(profileId == fromProfileId, "Web3Entry: unauthorised linkList");

        // remove from link list
        ILinklistNFT(linkList).removeLinking2ProfileId(
            linkListId,
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

    function linkLink(
        uint256 fromProfileId,
        DataTypes.LinkData calldata linkData
    ) external {}

    function linkLinklist(
        uint256 fromProfileId,
        uint256 linkListId,
        bytes32 linkType
    ) external {}

    function setProfileLinkModule(uint256 profileId, address moduleAddress)
        external
    {} // set link module for his profile

    function setNoteLinkModule(
        uint256 profileId,
        uint256 noteId,
        address moduleAddress
    ) external {} // set link module for his profile

    function setLinkListLinkModule(uint256 tokenId, address moduleAddress)
        external
    {}

    function setERC721LinkModule(
        address tokenAddress,
        uint256 tokenId,
        address moduleAddress
    ) external {}

    function setAddressLinkModule(address account, address moduleAddress)
        external
    {}

    function setLinkLinkModule(
        DataTypes.LinkData calldata linkData,
        address moduleAddress
    ) external {}

    function mintNote(
        uint256 profileId,
        uint256 noteId,
        address to
    ) external {}

    function mintLink(DataTypes.LinkData calldata linkData, address receiver)
        external
    {}

    function setMintModuleForNote(
        uint256 profileId,
        uint256 toNoteId,
        address moduleAddress
    ) external {} // set mint module for himself

    function setMintModuleForLink(
        DataTypes.LinkData calldata linkData,
        address moduleAddress
    ) external {} // set mint module for his single link item

    function postNote(DataTypes.PostNoteData calldata vars)
        external
        returns (uint256)
    {
        _validateCallerIsProfileOwner(vars.profileId);

        return
            _postNote(
                vars.profileId,
                vars.contentURI,
                vars.linkModule,
                vars.linkModuleInitData,
                vars.mintModule,
                vars.mintModuleInitData
            );
    }

    function postNoteWithLink(
        DataTypes.PostNoteData calldata vars,
        DataTypes.LinkData calldata linkData
    ) external {}

    function setLinkListUri(
        uint256 profileId,
        bytes32 linkType,
        string memory uri
    ) external {}

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
        uint256 linkListId = _primaryLinkListByProfileId[fromProfileId];
        return
            ILinklistNFT(linkList).getLinking2ProfileIds(linkListId, linkType);
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
        bytes memory linkModuleInitData,
        address mintModule,
        bytes memory mintModuleInitData
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
