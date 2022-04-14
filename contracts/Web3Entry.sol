// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./base/NFTBase.sol";
import "./interfaces/IWeb3Entry.sol";
import "./interfaces/ILinklist.sol";
import "./interfaces/ILinkModule4Profile.sol";
import "./interfaces/ILinkModule4Note.sol";
import "./interfaces/IMintModule4Note.sol";
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

    function createProfile(DataTypes.CreateProfileData calldata vars) external {
        uint256 profileId = ++_profileCounter;
        _mint(vars.to, profileId);

        bytes32 handleHash = keccak256(bytes(vars.handle));
        require(
            _profileIdByHandleHash[handleHash] == 0,
            "Web3Entry: HandleExists"
        );
        _profileIdByHandleHash[handleHash] = profileId;

        _profileById[profileId].profileId = profileId;
        _profileById[profileId].handle = vars.handle;
        _profileById[profileId].metadataUri = vars.metadataUri;

        // set primary profile
        if (_primaryProfileByAddress[vars.to] == 0) {
            _primaryProfileByAddress[vars.to] = profileId;
        }

        // init link module
        if (vars.linkModule != _profileById[profileId].linkModule) {
            _profileById[profileId].linkModule = vars.linkModule;
        }
        bytes memory returnData;
        if (vars.linkModule != address(0)) {
            returnData = ILinkModule4Profile(vars.linkModule)
                .initializeLinkModule(profileId, vars.linkModuleInitData);
        }

        emit Events.SetLinkModule4Profile(
            profileId,
            vars.linkModule,
            returnData,
            block.timestamp
        );
        emit Events.ProfileCreated(
            profileId,
            msg.sender,
            vars.to,
            vars.handle,
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
            _profileById[profileId].socialToken == address(0),
            "Web3Entry: SocialTokenExists"
        );

        _profileById[profileId].socialToken = tokenAddress;

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

    function setPrimaryLinklist(uint256 linkListId, uint256 profileId) public {
        _takeOverLinkList(linkListId, profileId);
        bytes32 linkType = ILinklist(linkList).getLinkType(linkListId);
        _primaryLinkListsByProfileId[profileId][linkType] = linkListId;
    }

    function setLinklistUri(uint256 linkListId, string calldata uri) external {
        _validateCallerIsLinklistOwner(linkListId);

        ILinklist(linkList).setUri(linkListId, uri);
    }

    // emit a link from a profile
    function linkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        require(_exists(toProfileId), "Web3Entry: toProfileId not exist");

        uint256 linkListId = _primaryLinkListsByProfileId[fromProfileId][
            linkType
        ];
        if (linkListId == 0) {
            linkListId = IERC721Enumerable(linkList).totalSupply().add(1);
            // mint linkList nft
            ILinklist(linkList).mint(msg.sender, linkType, linkListId);
            // set primary linkList
            setPrimaryLinklist(linkListId, fromProfileId);
        }

        // add to link list
        ILinklist(linkList).addLinkingProfileId(linkListId, toProfileId);

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

        uint256 linkListId = _primaryLinkListsByProfileId[fromProfileId][
            linkType
        ];
        uint256 profileId = ILinklist(linkList).getCurrentTakeOver(linkListId);
        require(profileId == fromProfileId, "Web3Entry: unauthorised linkList");

        // remove from link list
        ILinklist(linkList).removeLinkingProfileId(linkListId, toProfileId);

        emit Events.UnlinkProfile(
            msg.sender,
            fromProfileId,
            toProfileId,
            linkType
        );
    }

    function linkNote(
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 toNoteId,
        bytes32 linkType
    ) external {}

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

    // set link module for his profile
    function setLinkModule4Profile(
        uint256 profileId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {
        _validateCallerIsProfileOwner(profileId);

        if (linkModule != _profileById[profileId].linkModule) {
            _profileById[profileId].linkModule = linkModule;
        }

        bytes memory returnData;
        if (linkModule != address(0)) {
            returnData = ILinkModule4Profile(linkModule).initializeLinkModule(
                profileId,
                linkModuleInitData
            );
        }

        emit Events.SetLinkModule4Profile(
            profileId,
            linkModule,
            returnData,
            block.timestamp
        );
    }

    function setLinkModule4Note(
        uint256 profileId,
        uint256 noteId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {} // set link module for his profile

    function setLinkModule4Linklist(
        uint256 tokenId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {}

    function setLinkModule4ERC721(
        address tokenAddress,
        uint256 tokenId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {}

    function setLinkModule4Address(
        address account,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {}

    function setLinkModule4Link(
        DataTypes.LinkData calldata linkData,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {}

    function mintNote(
        uint256 profileId,
        uint256 noteId,
        address to
    ) external {}

    function mintLink(DataTypes.LinkData calldata linkData, address to)
        external
    {}

    function setMintModule4Note(
        uint256 profileId,
        uint256 toNoteId,
        address mintModule,
        bytes calldata mintModuleInitData
    ) external {} // set mint module for himself

    function setMintModule4Link(
        DataTypes.LinkData calldata linkData,
        address mintModule,
        bytes calldata mintModuleInitData
    ) external {} // set mint module for his single link item

    function postNote(DataTypes.PostNoteData calldata noteData)
        external
        returns (uint256)
    {
        _validateCallerIsProfileOwner(noteData.profileId);

        return
            _postNote(
                noteData.profileId,
                noteData.contentUri,
                noteData.linkModule,
                noteData.linkModuleInitData,
                noteData.mintModule,
                noteData.mintModuleInitData
            );
    }

    function postNoteWithLink(
        DataTypes.PostNoteData calldata noteData,
        DataTypes.LinkData calldata linkData
    ) external {}

    function getPrimaryProfileId(address account)
        external
        view
        returns (uint256)
    {
        return _primaryProfileByAddress[account];
    }

    function isPrimaryProfile(uint256 profileId) external view returns (bool) {
        address account = ownerOf(profileId);
        return profileId == _primaryProfileByAddress[account];
    }

    function getProfile(uint256 profileId)
        external
        view
        returns (DataTypes.Profile memory)
    {
        return _profileById[profileId];
    }

    function getProfileByHandle(string calldata handle)
        external
        view
        returns (DataTypes.Profile memory)
    {
        bytes32 handleHash = keccak256(bytes(handle));
        uint256 profileId = _profileIdByHandleHash[handleHash];
        return _profileById[profileId];
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

    function getLinkModule4Profile(uint256 profileId)
        external
        view
        returns (address)
    {}

    function getLinkModule4Address(address account)
        external
        view
        returns (address)
    {}

    function getLinkModule4Linklist(uint256 tokenId)
        external
        view
        returns (address)
    {}

    function getLinkModule4ERC721(address tokenAddress, uint256 tokenId)
        external
        view
        returns (address)
    {}

    function getLinkModule4Link(DataTypes.LinkData calldata linkData)
        external
        view
        returns (address)
    {}

    function getMintModule4Note(uint256 profileId, uint256 toNoteId)
        external
        view
        returns (address)
    {}

    function getMintModule4Link(DataTypes.LinkData calldata linkData)
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

    function getLinkListUri(uint256 profileId, bytes32 linkType)
        external
        view
        returns (string memory)
    {
        uint256 tokenId = _primaryLinkListsByProfileId[profileId][linkType];
        return ILinklist(linkList).Uri(tokenId);
    }

    function getLinkingProfileIds(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory)
    {
        uint256 linkListId = _primaryLinkListsByProfileId[fromProfileId][
            linkType
        ];
        return ILinklist(linkList).getLinkingProfileIds(linkListId);
    }

    function getNoteUri(uint256 profileId, uint256 noteId)
        external
        view
        returns (string memory)
    {
        return _noteByIdByProfile[profileId][noteId].contentUri;
    }

    function getLinklistContract() external view returns (address) {
        return linkList;
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
        _noteByIdByProfile[profileId][noteId].contentUri = contentURI;
        _noteByIdByProfile[profileId][noteId].linkModule = linkModule;
        _noteByIdByProfile[profileId][noteId].mintModule = mintModule;

        // init link module
        bytes memory linkModuleReturnData;
        if (linkModule != address(0)) {
            linkModuleReturnData = ILinkModule4Note(linkModule)
                .initializeLinkModule(profileId, noteId, linkModuleInitData);
        }
        // init mint module
        bytes memory mintModuleReturnData;
        if (mintModule != address(0)) {
            mintModuleReturnData = IMintModule4Note(mintModule)
                .initializeMintModule(profileId, noteId, mintModuleInitData);
        }

        emit Events.SetLinkModule4Note(
            profileId,
            noteId,
            linkModule,
            linkModuleReturnData,
            block.timestamp
        );
        emit Events.SetMintModule4Note(
            profileId,
            noteId,
            mintModule,
            mintModuleReturnData,
            block.timestamp
        );

        return noteId;
    }

    function _takeOverLinkList(uint256 tokenId, uint256 profileId) internal {
        _validateCallerIsProfileOwner(profileId);

        ILinklist(linkList).setTakeOver(tokenId, msg.sender, profileId);
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
