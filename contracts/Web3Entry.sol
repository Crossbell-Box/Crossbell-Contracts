// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;
import "hardhat/console.sol";
import "./base/NFTBase.sol";
import "./interfaces/IWeb3Entry.sol";
import "./interfaces/ILinklist.sol";
import "./interfaces/ILinkModule4Profile.sol";
import "./interfaces/ILinkModule4Note.sol";
import "./interfaces/ILinkModule4Address.sol";
import "./interfaces/ILinkModule4ERC721.sol";
import "./interfaces/IMintModule4Note.sol";
import "./interfaces/IMintNFT.sol";
import "./storage/Web3EntryStorage.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Events.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Web3Entry is IWeb3Entry, NFTBase, Web3EntryStorage, Initializable {
    using SafeMath for uint256;
    using Strings for uint256;

    address MINT_NFT_IMPL;

    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _linkListContract,
        address _mintNFTImpl
    ) external initializer {
        super._initialize(_name, _symbol);
        linkList = _linkListContract;
        MINT_NFT_IMPL = _mintNFTImpl;

        emit Events.Web3EntryInitialized(block.timestamp);
    }

    function _createProfile(
        string memory handle,
        string memory uri,
        address receiver
    ) internal returns (uint256 profileId) {
        bytes32 handleHash = keccak256(bytes(handle));
        require(_profileIdByHandleHash[handleHash] == 0, "Web3Entry: HandleExists");

        profileId = ++_profileCounter;
        console.log("%d is creating.", profileId);

        _mint(receiver, profileId);

        _profileIdByHandleHash[handleHash] = profileId;

        _profileById[profileId].profileId = profileId;
        _profileById[profileId].handle = handle;
        _profileById[profileId].uri = uri;

        emit Events.ProfileCreated(profileId, msg.sender, receiver, handle, block.timestamp);
    }

    function createProfile(DataTypes.CreateProfileData calldata profileData) external {
        uint256 profileId = _createProfile(profileData.handle, profileData.uri, profileData.to);

        // set primary profile
        if (_primaryProfileByAddress[profileData.to] == 0) {
            _primaryProfileByAddress[profileData.to] = profileId;
        }

        // init link module
        if (profileData.linkModule != _profileById[profileId].linkModule) {
            _profileById[profileId].linkModule = profileData.linkModule;
        }
        bytes memory returnData;
        if (profileData.linkModule != address(0)) {
            returnData = ILinkModule4Profile(profileData.linkModule).initializeLinkModule(
                profileId,
                profileData.linkModuleInitData
            );
            emit Events.SetLinkModule4Profile(
                profileId,
                profileData.linkModule,
                returnData,
                block.timestamp
            );
        }
    }

    function setHandle(uint256 profileId, string calldata newHandle) external {
        _validateCallerIsProfileOwner(profileId);

        // remove old handle
        string memory oldHandle = _profileById[profileId].handle;
        bytes32 oldHandleHash = keccak256(bytes(oldHandle));
        delete _profileIdByHandleHash[oldHandleHash];

        // set new handle
        bytes32 handleHash = keccak256(bytes(newHandle));
        require(_profileIdByHandleHash[handleHash] == 0, "Web3Entry: HandleExists");

        _profileIdByHandleHash[handleHash] = profileId;

        _profileById[profileId].handle = newHandle;

        emit Events.SetHandle(msg.sender, profileId, newHandle);
    }

    function setSocialToken(uint256 profileId, address tokenAddress) external {
        _validateCallerIsProfileOwner(profileId);

        require(_profileById[profileId].socialToken == address(0), "Web3Entry: SocialTokenExists");

        _profileById[profileId].socialToken = tokenAddress;

        emit Events.SetSocialToken(msg.sender, profileId, tokenAddress);
    }

    function setProfileUri(uint256 profileId, string calldata newUri) external {
        _validateCallerIsProfileOwner(profileId);

        _profileById[profileId].uri = newUri;
    }

    function setPrimaryProfileId(uint256 profileId) external {
        _validateCallerIsProfileOwner(profileId);

        _primaryProfileByAddress[msg.sender] = profileId;

        emit Events.SetPrimaryProfileId(msg.sender, profileId);
    }

    function attachLinklist(uint256 linklistId, uint256 profileId) public {
        bytes32 linkType = ILinklist(linkList).getLinkType(linklistId);
        require(
            _attachedLinklists[profileId][linkType] == 0,
            "Same type linklist already existed."
        );

        _takeOverLinkList(linklistId, profileId);
        _attachedLinklists[profileId][linkType] = linklistId;

        emit Events.AttachLinklist(profileId, linkType, linklistId);
    }

    function detachLinklist(uint256 linklistId, uint256 profileId) public {
        bytes32 linkType = ILinklist(linkList).getLinkType(linklistId);
        _attachedLinklists[profileId][linkType] = 0;

        emit Events.DetachLinklist(profileId, linkType, linklistId);
    }

    function setLinklistUri(uint256 linkListId, string calldata uri) external {
        _validateCallerIsLinklistOwner(linkListId);

        ILinklist(linkList).setUri(linkListId, uri);
    }

    // emit a link from a profile
    function _linkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) internal {
        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        if (linklistId == 0) {
            linklistId = IERC721Enumerable(linkList).totalSupply().add(1);
            // mint linkList nft
            ILinklist(linkList).mint(msg.sender, linkType, linklistId);
            // set primary linkList
            attachLinklist(linklistId, fromProfileId);
        }

        // add to link list
        ILinklist(linkList).addLinkingProfileId(linklistId, toProfileId);

        emit Events.LinkProfile(msg.sender, fromProfileId, toProfileId, linkType, linklistId);
    }

    function linkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        _validateProfileExists(toProfileId);

        _linkProfile(fromProfileId, toProfileId, linkType);
    }

    function unlinkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        _validateProfileExists(toProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        uint256 profileId = ILinklist(linkList).getCurrentTakeOver(linklistId);
        require(profileId == fromProfileId, "Web3Entry: unauthorised linkList");

        // remove from link list
        ILinklist(linkList).removeLinkingProfileId(linklistId, toProfileId);

        emit Events.UnlinkProfile(msg.sender, fromProfileId, toProfileId, linkType);
    }

    function createThenLinkProfile(
        uint256 fromProfileId,
        address to,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        require(_primaryProfileByAddress[to] == 0, "Target address already has primary profile.");
        uint256 toProfileId = _createProfile(string(abi.encodePacked(to)), "", to);
        _primaryProfileByAddress[to] = toProfileId;

        _linkProfile(fromProfileId, toProfileId, linkType);
    }

    function linkNote(
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 toNoteId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        _validateProfileExists(toProfileId);

        _linkNote(fromProfileId, toProfileId, toNoteId, linkType);
    }

    function unlinkNote(
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 toNoteId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        _validateProfileExists(toProfileId);
        _validateNoteExists(toProfileId, toNoteId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        uint256 profileId = ILinklist(linkList).getCurrentTakeOver(linklistId);
        require(profileId == fromProfileId, "Web3Entry: unauthorised linkList");

        // remove from link list
        ILinklist(linkList).removeLinkingNote(linklistId, toProfileId, toNoteId);

        emit Events.UnlinkNote(fromProfileId, toProfileId, toNoteId, linkType, linklistId);
    }

    function linkERC721(
        uint256 fromProfileId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        _linkERC721(fromProfileId, tokenAddress, tokenId, linkType);
    }

    function unlinkERC721(
        uint256 fromProfileId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        _unlinkERC721(fromProfileId, tokenAddress, tokenId, linkType);
    }

    //TODO linkERC1155

    function linkAddress(
        uint256 fromProfileId,
        address ethAddress,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        if (linklistId == 0) {
            linklistId = IERC721Enumerable(linkList).totalSupply().add(1);
            // mint linkList nft
            ILinklist(linkList).mint(msg.sender, linkType, linklistId);
            // set primary linkList
            attachLinklist(linklistId, fromProfileId);
        }

        // add to link list
        ILinklist(linkList).addLinkingAddress(linklistId, ethAddress);

        emit Events.LinkAddress(fromProfileId, ethAddress, linkType, linklistId);
    }

    function unlinkAddress(
        uint256 fromProfileId,
        address ethAddress,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        uint256 profileId = ILinklist(linkList).getCurrentTakeOver(linklistId);
        require(profileId == fromProfileId, "Web3Entry: unauthorised linkList");

        // remove from link list
        ILinklist(linkList).removeLinkingAddress(linklistId, ethAddress);

        emit Events.UnlinkAddress(fromProfileId, ethAddress, linkType);
    }

    function linkAny(
        uint256 fromProfileId,
        string calldata toUri,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        if (linklistId == 0) {
            linklistId = IERC721Enumerable(linkList).totalSupply().add(1);
            // mint linkList nft
            ILinklist(linkList).mint(msg.sender, linkType, linklistId);
            // set primary linkList
            attachLinklist(linklistId, fromProfileId);
        }

        // add to link list
        ILinklist(linkList).addLinkingAny(linklistId, toUri);

        emit Events.LinkAny(fromProfileId, toUri, linkType, linklistId);
    }

    function unlinkAny(
        uint256 fromProfileId,
        string calldata toUri,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        uint256 profileId = ILinklist(linkList).getCurrentTakeOver(linklistId);
        require(profileId == fromProfileId, "Web3Entry: unauthorised linkList");

        // remove from link list
        ILinklist(linkList).removeLinkingAny(linklistId, toUri);

        emit Events.UnlinkAny(fromProfileId, toUri, linkType);
    }

    function linkProfileLink(
        uint256 fromProfileId,
        DataTypes.ProfileLinkStruct calldata linkData,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        _linkProfileLink(fromProfileId, linkType, linkData);
    }

    function unlinkProfileLink(
        uint256 fromProfileId,
        DataTypes.ProfileLinkStruct calldata linkData,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        uint256 profileId = ILinklist(linkList).getCurrentTakeOver(linklistId);
        require(profileId == fromProfileId, "Web3Entry: unauthorised linkList");

        // remove from link list
        ILinklist(linkList).removeLinkingProfileLink(linklistId, linkData);

        // event
        emit Events.UnlinkProfileLink(
            fromProfileId,
            linkType,
            linkData.fromProfileId,
            linkData.toProfileId,
            linkData.linkType
        );
    }

    function linkLinklist(
        uint256 fromProfileId,
        uint256 toLinkListId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        if (linklistId == 0) {
            linklistId = IERC721Enumerable(linkList).totalSupply().add(1);
            // mint linkList nft
            ILinklist(linkList).mint(msg.sender, linkType, linklistId);
            // set primary linkList
            attachLinklist(linklistId, fromProfileId);
        }

        // add to link list
        ILinklist(linkList).addLinkingLinklistId(linklistId, toLinkListId);

        emit Events.LinkLinklist(fromProfileId, toLinkListId, linkType, linklistId);
    }

    function unlinkLinklist(
        uint256 fromProfileId,
        uint256 toLinkListId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        uint256 profileId = ILinklist(linkList).getCurrentTakeOver(linklistId);
        require(profileId == fromProfileId, "Web3Entry: unauthorised linkList");

        // add to link list
        ILinklist(linkList).removeLinkingLinklistId(linklistId, toLinkListId);

        emit Events.UninkLinklist(fromProfileId, toLinkListId, linkType, linklistId);
    }

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

        emit Events.SetLinkModule4Profile(profileId, linkModule, returnData, block.timestamp);
    }

    function setLinkModule4Note(
        uint256 profileId,
        uint256 noteId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {
        _validateCallerIsProfileOwner(profileId);
        _validateNoteExists(profileId, noteId);

        if (linkModule != address(0)) {
            _noteByIdByProfile[profileId][noteId].linkModule = linkModule;
        }

        bytes memory returnData = ILinkModule4Note(linkModule).initializeLinkModule(
            profileId,
            noteId,
            linkModuleInitData
        );

        emit Events.SetLinkModule4Note(profileId, noteId, linkModule, returnData, block.timestamp);
    }

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
    ) external {
        require(
            msg.sender == IERC721Metadata(tokenAddress).ownerOf(tokenId),
            "Web3Entry: NotERC721TokenOwner"
        );

        _linkModules4ERC721[tokenAddress][tokenId] = linkModule;
        bytes memory linkModuleReturnData = ILinkModule4ERC721(linkModule).initializeLinkModule(
            tokenAddress,
            tokenId,
            linkModuleInitData
        );

        emit Events.SetLinkModule4ERC721(
            tokenAddress,
            tokenId,
            linkModule,
            linkModuleReturnData,
            block.timestamp
        );
    }

    function setLinkModule4Address(
        address account,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {
        require(msg.sender == account, "Web3Entry: NotAddressOwner");

        _linkModules4Address[account] = linkModule;
        bytes memory linkModuleReturnData = ILinkModule4Address(linkModule).initializeLinkModule(
            account,
            linkModuleInitData
        );

        emit Events.SetLinkModule4Address(
            account,
            linkModule,
            linkModuleReturnData,
            block.timestamp
        );
    }

    function mintNote(
        uint256 profileId,
        uint256 noteId,
        address to,
        bytes calldata mintModuleData
    ) external returns (uint256) {
        uint256 tokenId;

        address mintNFT = _noteByIdByProfile[profileId][noteId].mintNFT;
        if (mintNFT == address(0)) {
            mintNFT = _deployMintNFT(
                profileId,
                noteId,
                _profileById[profileId].handle,
                MINT_NFT_IMPL
            );
            _noteByIdByProfile[profileId][noteId].mintNFT = mintNFT;
        }
        tokenId = IMintNFT(mintNFT).mint(to);

        address mintModule = _noteByIdByProfile[profileId][noteId].mintModule;
        IMintModule4Note(mintModule).processMint(profileId, noteId, mintModuleData);

        emit Events.MintNote(to, profileId, noteId, tokenId, mintModuleData, block.timestamp);

        return tokenId;
    }

    function _deployMintNFT(
        uint256 profileId,
        uint256 noteId,
        string memory handle,
        address mintNFTImpl
    ) internal returns (address) {
        address mintNFT = Clones.clone(mintNFTImpl);

        bytes4 firstBytes = bytes4(bytes(handle));

        string memory NFTName = string(
            abi.encodePacked(handle, "-Mint-", profileId.toString(), "-", noteId.toString())
        );
        string memory NFTSymbol = string(
            abi.encodePacked(firstBytes, "-Mint-", profileId.toString(), "-", noteId.toString())
        );

        IMintNFT(mintNFT).initialize(profileId, noteId, address(this), NFTName, NFTSymbol);
        return mintNFT;
    }

    function setMintModule4Note(
        uint256 profileId,
        uint256 noteId,
        address mintModule,
        bytes calldata mintModuleInitData
    ) external {
        _validateCallerIsProfileOwner(profileId);
        _validateNoteExists(profileId, noteId);

        bytes memory returnData = _initMintModule4Note(
            profileId,
            noteId,
            mintModule,
            mintModuleInitData
        );

        emit Events.SetMintModule4Note(profileId, noteId, mintModule, returnData, block.timestamp);
    }

    function _initMintModule4Note(
        uint256 profileId,
        uint256 noteId,
        address mintModule,
        bytes memory mintModuleInitData
    ) internal returns (bytes memory) {
        _noteByIdByProfile[profileId][noteId].mintModule = mintModule;
        return
            IMintModule4Note(mintModule).initializeMintModule(
                profileId,
                noteId,
                mintModuleInitData
            );
    }

    function postNote(DataTypes.PostNoteData calldata noteData) external returns (uint256) {
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

    function getPrimaryProfileId(address account) external view returns (uint256) {
        return _primaryProfileByAddress[account];
    }

    function isPrimaryProfile(uint256 profileId) external view returns (bool) {
        address account = ownerOf(profileId);
        return profileId == _primaryProfileByAddress[account];
    }

    function getProfile(uint256 profileId) external view returns (DataTypes.Profile memory) {
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

    function getHandle(uint256 profileId) external view returns (string memory) {
        return _profileById[profileId].handle;
    }

    function getProfileUri(uint256 profileId) external view returns (string memory) {
        return tokenURI(profileId);
    }

    function getLinkModule4Profile(uint256 profileId) external view returns (address) {
        return _profileById[profileId].linkModule;
    }

    function getLinkModule4Address(address account) external view returns (address) {
        return _linkModules4Address[account];
    }

    function getLinkModule4Linklist(uint256 tokenId) external view returns (address) {
        return _linkModules4Linklist[tokenId];
    }

    function getLinkModule4ERC721(address tokenAddress, uint256 tokenId)
        external
        view
        returns (address)
    {
        return _linkModules4ERC721[tokenAddress][tokenId];
    }

    function getMintModule4Note(uint256 profileId, uint256 noteId) external view returns (address) {
        return _noteByIdByProfile[profileId][noteId].mintModule;
    }

    function tokenURI(uint256 profileId) public view override returns (string memory) {
        return _profileById[profileId].uri;
    }

    function getLinklistUri(uint256 profileId, bytes32 linkType)
        external
        view
        returns (string memory)
    {
        uint256 tokenId = _attachedLinklists[profileId][linkType];
        return ILinklist(linkList).Uri(tokenId);
    }

    function getLinkingProfileIds(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory)
    {
        uint256 linkListId = _attachedLinklists[fromProfileId][linkType];
        return ILinklist(linkList).getLinkingProfileIds(linkListId);
    }

    function getNoteUri(uint256 profileId, uint256 noteId) external view returns (string memory) {
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
            linkModuleReturnData = ILinkModule4Note(linkModule).initializeLinkModule(
                profileId,
                noteId,
                linkModuleInitData
            );
        }
        // init mint module
        bytes memory mintModuleReturnData;
        if (mintModule != address(0)) {
            mintModuleReturnData = IMintModule4Note(mintModule).initializeMintModule(
                profileId,
                noteId,
                mintModuleInitData
            );
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

    function _linkNote(
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 toNoteId,
        bytes32 linkType
    ) internal {
        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        if (linklistId == 0) {
            linklistId = IERC721Enumerable(linkList).totalSupply().add(1);
            // mint linkList nft
            ILinklist(linkList).mint(msg.sender, linkType, linklistId);
            // set primary linkList
            attachLinklist(linklistId, fromProfileId);
        }

        // add to link list
        ILinklist(linkList).addLinkingNote(linklistId, toProfileId, toNoteId);

        emit Events.LinkNote(fromProfileId, toProfileId, toNoteId, linkType, linklistId);
    }

    function _linkERC721(
        uint256 fromProfileId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType
    ) internal {
        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        if (linklistId == 0) {
            linklistId = IERC721Enumerable(linkList).totalSupply().add(1);
            // mint linkList nft
            ILinklist(linkList).mint(msg.sender, linkType, linklistId);
            // set primary linkList
            attachLinklist(linklistId, fromProfileId);
        }

        // add to link list
        ILinklist(linkList).addLinkingERC721(linklistId, tokenAddress, tokenId);

        emit Events.LinkERC721(fromProfileId, tokenAddress, tokenId, linkType, linklistId);
    }

    function _unlinkERC721(
        uint256 fromProfileId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType
    ) internal {
        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        uint256 profileId = ILinklist(linkList).getCurrentTakeOver(linklistId);
        require(profileId == fromProfileId, "Web3Entry: unauthorised linkList");

        // remove from link list
        ILinklist(linkList).removeLinkingERC721(linklistId, tokenAddress, tokenId);

        emit Events.UnlinkERC721(fromProfileId, tokenAddress, tokenId, linkType, linklistId);
    }

    function _linkProfileLink(
        uint256 fromProfileId,
        bytes32 linkType,
        DataTypes.ProfileLinkStruct memory linkData
    ) internal {
        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        if (linklistId == 0) {
            linklistId = IERC721Enumerable(linkList).totalSupply().add(1);
            // mint linkList nft
            ILinklist(linkList).mint(msg.sender, linkType, linklistId);
            // set primary linkList
            attachLinklist(linklistId, fromProfileId);
        }

        // add to link list
        ILinklist(linkList).addLinkingProfileLink(linklistId, linkData);

        // event
        emit Events.LinkProfileLink(
            fromProfileId,
            linkType,
            linkData.fromProfileId,
            linkData.toProfileId,
            linkData.linkType
        );
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
        require(msg.sender == ERC721(linkList).ownerOf(tokenId), "Web3Entry: NotLinkListOwner");
    }

    function _validateProfileExists(uint256 profileId) internal view {
        require(_exists(profileId), "Web3Entry: ProfileNotExists");
    }

    function _validateNoteExists(uint256 profileId, uint256 noteId) internal view {
        require(noteId <= _profileById[profileId].noteCount, "Web3Entry: NoteNotExists");
    }
}
