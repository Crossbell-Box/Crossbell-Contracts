// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "hardhat/console.sol";
import "./base/NFTBase.sol";
import "./interfaces/IWeb3Entry.sol";
import "./interfaces/ILinklist.sol";
import "./interfaces/ILinkModule4Note.sol";
import "./interfaces/ILinkModule4Address.sol";
import "./interfaces/ILinkModule4ERC721.sol";
import "./interfaces/ILinkModule4Linklist.sol";
import "./interfaces/IMintModule4Note.sol";
import "./storage/Web3EntryStorage.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Constants.sol";
import "./libraries/Events.sol";
import "./libraries/ProfileLogic.sol";
import "./libraries/PostLogic.sol";
import "./libraries/InteractionLogic.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract Web3Entry is IWeb3Entry, NFTBase, Web3EntryStorage, Initializable {
    using SafeMath for uint256;
    using Strings for uint256;

    uint256 internal constant REVISION = 2;

    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _linklistContract,
        address _mintNFTImpl
    ) external initializer {
        super._initialize(_name, _symbol);
        _linklist = _linklistContract;
        MINT_NFT_IMPL = _mintNFTImpl;

        emit Events.Web3EntryInitialized(block.timestamp);
    }

    function createProfile(DataTypes.CreateProfileData calldata vars) external {
        _profileCounter = _profileCounter.add(1);

        // mint profile nft
        _mint(vars.to, _profileCounter);

        ProfileLogic.createProfile(
            vars,
            true,
            _profileCounter,
            _profileIdByHandleHash,
            _profileById
        );

        // set primary profile
        if (_primaryProfileByAddress[vars.to] == 0) {
            _primaryProfileByAddress[vars.to] = _profileCounter;
        }
    }

    function setHandle(uint256 profileId, string calldata newHandle) external {
        _validateCallerIsProfileOwner(profileId);

        ProfileLogic.setHandle(profileId, newHandle, _profileIdByHandleHash, _profileById);
    }

    function setSocialToken(uint256 profileId, address tokenAddress) external {
        _validateCallerIsProfileOwner(profileId);

        ProfileLogic.setSocialToken(profileId, tokenAddress, _profileById);
    }

    function setProfileUri(uint256 profileId, string calldata newUri) external {
        _validateCallerIsProfileOwner(profileId);

        _profileById[profileId].uri = newUri;

        emit Events.SetProfileUri(profileId, newUri);
    }

    function setPrimaryProfileId(uint256 profileId) external {
        _validateCallerIsProfileOwner(profileId);

        _primaryProfileByAddress[msg.sender] = profileId;

        emit Events.SetPrimaryProfileId(msg.sender, profileId);
    }

    function attachLinklist(uint256 linklistId, uint256 profileId) public {
        bytes32 linkType = ILinklist(_linklist).getLinkType(linklistId);
        require(
            _attachedLinklists[profileId][linkType] == 0,
            "Same type linklist already existed."
        );

        _takeOverLinkList(linklistId, profileId);
        _attachedLinklists[profileId][linkType] = linklistId;

        emit Events.AttachLinklist(linklistId, profileId, linkType);
    }

    function detachLinklist(uint256 linklistId, uint256 profileId) public {
        bytes32 linkType = ILinklist(_linklist).getLinkType(linklistId);
        _attachedLinklists[profileId][linkType] = 0;

        emit Events.DetachLinklist(linklistId, profileId, linkType);
    }

    function setLinklistUri(uint256 linklistId, string calldata uri) external {
        _validateCallerIsLinklistOwner(linklistId);

        ILinklist(_linklist).setUri(linklistId, uri);
    }

    // emit a link from a profile

    function linkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        _validateProfileExists(toProfileId);

        _linkProfile(fromProfileId, toProfileId, linkType, "0x");
    }

    function _linkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType,
        bytes memory data
    ) internal {
        uint256 linklistId = _mintLinklist(fromProfileId, linkType, msg.sender);

        // add to link list
        ILinklist(_linklist).addLinkingProfileId(linklistId, toProfileId);

        // process link module
        if (_profileById[toProfileId].linkModule != address(0)) {
            address linker = ownerOf(fromProfileId);
            ILinkModule4Profile(_profileById[toProfileId].linkModule).processLink(
                linker,
                toProfileId,
                data
            );
        }

        emit Events.LinkProfile(msg.sender, fromProfileId, toProfileId, linkType, linklistId);
    }

    function linkProfileV2(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType,
        bytes calldata data
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        _validateProfileExists(toProfileId);

        _linkProfile(fromProfileId, toProfileId, linkType, data);
    }

    function unlinkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        _validateProfileExists(toProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        _validateLinklistAttached(linklistId, fromProfileId);

        // remove from link list
        ILinklist(_linklist).removeLinkingProfileId(linklistId, toProfileId);

        emit Events.UnlinkProfile(msg.sender, fromProfileId, toProfileId, linkType);
    }

    function createThenLinkProfile(
        uint256 fromProfileId,
        address to,
        bytes32 linkType
    ) external {
        _createThenLinkProfile(fromProfileId, to, linkType, "0x");
    }

    function createThenLinkProfileV2(
        uint256 fromProfileId,
        address to,
        bytes32 linkType,
        bytes calldata data
    ) external {
        _createThenLinkProfile(fromProfileId, to, linkType, data);
    }

    function _createThenLinkProfile(
        uint256 fromProfileId,
        address to,
        bytes32 linkType,
        bytes memory data
    ) internal {
        _validateCallerIsProfileOwner(fromProfileId);
        require(_primaryProfileByAddress[to] == 0, "Target address already has primary profile.");

        uint256 profileId = ++_profileCounter;
        // mint profile nft
        _mint(to, profileId);

        ProfileLogic.createProfile(
            DataTypes.CreateProfileData({
                to: to,
                handle: Strings.toHexString(uint160(to), 20),
                uri: "",
                linkModule: address(0),
                linkModuleInitData: ""
            }),
            false,
            profileId,
            _profileIdByHandleHash,
            _profileById
        );

        // set primary profile
        _primaryProfileByAddress[to] = profileId;

        // link profile
        _linkProfile(fromProfileId, profileId, linkType, data);
    }

    function linkNote(
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 toNoteId,
        bytes32 linkType,
        bytes calldata data
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        _validateProfileExists(toProfileId);

        uint256 linklistId = _mintLinklist(fromProfileId, linkType, msg.sender);

        // add to link list
        ILinklist(_linklist).addLinkingNote(linklistId, toProfileId, toNoteId);

        // process link
        address linkModule = _noteByIdByProfile[toProfileId][toNoteId].linkModule;
        if (linkModule != address(0)) {
            ILinkModule4Note(linkModule).processLink(msg.sender, toProfileId, toNoteId, data);
        }

        emit Events.LinkNote(fromProfileId, toProfileId, toNoteId, linkType, linklistId);
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
        _validateLinklistAttached(linklistId, fromProfileId);

        // remove from link list
        ILinklist(_linklist).removeLinkingNote(linklistId, toProfileId, toNoteId);

        emit Events.UnlinkNote(fromProfileId, toProfileId, toNoteId, linkType, linklistId);
    }

    function linkERC721(
        uint256 fromProfileId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);
        _validateERC721Exists(tokenAddress, tokenId);

        uint256 linklistId = _mintLinklist(fromProfileId, linkType, msg.sender);

        // add to link list
        ILinklist(_linklist).addLinkingERC721(linklistId, tokenAddress, tokenId);

        emit Events.LinkERC721(fromProfileId, tokenAddress, tokenId, linkType, linklistId);
    }

    function unlinkERC721(
        uint256 fromProfileId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        _validateLinklistAttached(linklistId, fromProfileId);

        // remove from link list
        ILinklist(_linklist).removeLinkingERC721(linklistId, tokenAddress, tokenId);

        emit Events.UnlinkERC721(fromProfileId, tokenAddress, tokenId, linkType, linklistId);
    }

    //TODO linkERC1155

    function linkAddress(
        uint256 fromProfileId,
        address ethAddress,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _mintLinklist(fromProfileId, linkType, msg.sender);

        // add to link list
        ILinklist(_linklist).addLinkingAddress(linklistId, ethAddress);

        emit Events.LinkAddress(fromProfileId, ethAddress, linkType, linklistId);
    }

    function unlinkAddress(
        uint256 fromProfileId,
        address ethAddress,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        _validateLinklistAttached(linklistId, fromProfileId);

        // remove from link list
        ILinklist(_linklist).removeLinkingAddress(linklistId, ethAddress);

        emit Events.UnlinkAddress(fromProfileId, ethAddress, linkType);
    }

    function linkAny(
        uint256 fromProfileId,
        string calldata toUri,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _mintLinklist(fromProfileId, linkType, msg.sender);

        // add to link list
        ILinklist(_linklist).addLinkingAny(linklistId, toUri);

        emit Events.LinkAny(fromProfileId, toUri, linkType, linklistId);
    }

    function unlinkAny(
        uint256 fromProfileId,
        string calldata toUri,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        _validateLinklistAttached(linklistId, fromProfileId);

        // remove from link list
        ILinklist(_linklist).removeLinkingAny(linklistId, toUri);

        emit Events.UnlinkAny(fromProfileId, toUri, linkType);
    }

    function linkProfileLink(
        uint256 fromProfileId,
        DataTypes.ProfileLinkStruct calldata linkData,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _mintLinklist(fromProfileId, linkType, msg.sender);

        // add to link list
        ILinklist(_linklist).addLinkingProfileLink(linklistId, linkData);

        // event
        emit Events.LinkProfileLink(
            fromProfileId,
            linkType,
            linkData.fromProfileId,
            linkData.toProfileId,
            linkData.linkType
        );
    }

    function unlinkProfileLink(
        uint256 fromProfileId,
        DataTypes.ProfileLinkStruct calldata linkData,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        _validateLinklistAttached(linklistId, fromProfileId);

        // remove from link list
        ILinklist(_linklist).removeLinkingProfileLink(linklistId, linkData);

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

        uint256 linklistId = _mintLinklist(fromProfileId, linkType, msg.sender);

        // add to link list
        ILinklist(_linklist).addLinkingLinklistId(linklistId, toLinkListId);

        emit Events.LinkLinklist(fromProfileId, toLinkListId, linkType, linklistId);
    }

    function unlinkLinklist(
        uint256 fromProfileId,
        uint256 toLinkListId,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwner(fromProfileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        _validateLinklistAttached(linklistId, fromProfileId);

        // add to link list
        ILinklist(_linklist).removeLinkingLinklistId(linklistId, toLinkListId);

        emit Events.UnlinkLinklist(fromProfileId, toLinkListId, linkType, linklistId);
    }

    // set link module for his profile
    function setLinkModule4Profile(
        uint256 profileId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {
        _validateCallerIsProfileOwner(profileId);

        ProfileLogic.setProfileLinkModule(
            profileId,
            linkModule,
            linkModuleInitData,
            _profileById[profileId]
        );
    }

    function setLinkModule4Note(
        uint256 profileId,
        uint256 noteId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {
        _validateCallerIsProfileOwner(profileId);
        _validateNoteExists(profileId, noteId);

        InteractionLogic.setLinkModule4Note(
            profileId,
            noteId,
            linkModule,
            linkModuleInitData,
            _noteByIdByProfile
        );
    }

    function setLinkModule4Linklist(
        uint256 linklistId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {
        _validateCallerIsLinklistOwner(linklistId);

        if (linkModule != address(0)) {
            _linkModules4Linklist[linklistId] = linkModule;
            bytes memory linkModuleReturnData = ILinkModule4Linklist(linkModule)
                .initializeLinkModule(linklistId, linkModuleInitData);

            emit Events.SetLinkModule4Linklist(
                linklistId,
                linkModule,
                linkModuleReturnData,
                block.timestamp
            );
        }
    }

    function setLinkModule4ERC721(
        address tokenAddress,
        uint256 tokenId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {
        _validateCallerIsERC721Owner(tokenAddress, tokenId);

        if (linkModule != address(0)) {
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
    }

    function setLinkModule4Address(
        address account,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {
        require(msg.sender == account, "NotAddressOwner");

        if (linkModule != address(0)) {
            _linkModules4Address[account] = linkModule;
            bytes memory linkModuleReturnData = ILinkModule4Address(linkModule)
                .initializeLinkModule(account, linkModuleInitData);

            emit Events.SetLinkModule4Address(
                account,
                linkModule,
                linkModuleReturnData,
                block.timestamp
            );
        }
    }

    function mintNote(
        uint256 profileId,
        uint256 noteId,
        address to,
        bytes calldata mintModuleData
    ) external returns (uint256) {
        return
            InteractionLogic.mintNote(
                profileId,
                noteId,
                to,
                mintModuleData,
                MINT_NFT_IMPL,
                _profileById,
                _noteByIdByProfile
            );
    }

    function setMintModule4Note(
        uint256 profileId,
        uint256 noteId,
        address mintModule,
        bytes calldata mintModuleInitData
    ) external {
        _validateCallerIsProfileOwner(profileId);
        _validateNoteExists(profileId, noteId);

        InteractionLogic.setMintModule4Note(
            profileId,
            noteId,
            mintModule,
            mintModuleInitData,
            _noteByIdByProfile
        );
    }

    function postNote(DataTypes.PostNoteData calldata vars) external returns (uint256) {
        _validateCallerIsProfileOwner(vars.profileId);

        uint256 noteId = ++_profileById[vars.profileId].noteCount;

        PostLogic.postNote4Link(vars, noteId, 0, 0, 0, _noteByIdByProfile);
        return noteId;
    }

    function deleteNote(uint256 profileId, uint256 noteId) external {
        _validateCallerIsProfileOwner(profileId);
        _validateNoteExists(profileId, noteId);

        _noteByIdByProfile[profileId][noteId].deleted = true;
    }

    function postNote4ProfileLink(
        DataTypes.PostNoteData calldata noteData,
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) external returns (uint256) {
        _validateCallerIsProfileOwner(noteData.profileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        bytes32 linkItemType = Constants.LinkItemTypeProfile;
        bytes32 linkKey = bytes32(toProfileId);

        uint256 noteId = ++_profileById[fromProfileId].noteCount;

        PostLogic.postNote4Link(
            noteData,
            noteId,
            linklistId,
            linkItemType,
            linkKey,
            _noteByIdByProfile
        );

        return noteId;
    }

    function postNote4AddressLink(
        DataTypes.PostNoteData calldata noteData,
        uint256 fromProfileId,
        address ethAddress,
        bytes32 linkType
    ) external returns (uint256) {
        _validateCallerIsProfileOwner(noteData.profileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        bytes32 linkItemType = Constants.LinkItemTypeAddress;
        bytes32 linkKey = bytes32(uint256(uint160(ethAddress)));

        uint256 noteId = ++_profileById[fromProfileId].noteCount;

        PostLogic.postNote4Link(
            noteData,
            noteId,
            linklistId,
            linkItemType,
            linkKey,
            _noteByIdByProfile
        );

        return noteId;
    }

    function postNote4LinklistLink(
        DataTypes.PostNoteData calldata noteData,
        uint256 fromProfileId,
        uint256 toLinkListId,
        bytes32 linkType
    ) external returns (uint256) {
        _validateCallerIsProfileOwner(noteData.profileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        bytes32 linkItemType = Constants.LinkItemTypeList;
        bytes32 linkKey = bytes32(toLinkListId);

        uint256 noteId = ++_profileById[fromProfileId].noteCount;

        PostLogic.postNote4Link(
            noteData,
            noteId,
            linklistId,
            linkItemType,
            linkKey,
            _noteByIdByProfile
        );

        return noteId;
    }

    function postNote4NoteLink(
        DataTypes.PostNoteData calldata noteData,
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 toNoteId,
        bytes32 linkType
    ) external returns (uint256) {
        _validateCallerIsProfileOwner(noteData.profileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        bytes32 linkItemType = Constants.LinkItemTypeNote;
        bytes32 linkKey = keccak256(abi.encodePacked(toProfileId, toNoteId));

        uint256 noteId = ++_profileById[fromProfileId].noteCount;

        PostLogic.postNote4Link(
            noteData,
            noteId,
            linklistId,
            linkItemType,
            linkKey,
            _noteByIdByProfile
        );

        return noteId;
    }

    function postNote4ERC721Link(
        DataTypes.PostNoteData calldata noteData,
        uint256 fromProfileId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType
    ) external returns (uint256) {
        _validateCallerIsProfileOwner(noteData.profileId);
        _validateERC721Exists(tokenAddress, tokenId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        bytes32 linkItemType = Constants.LinkItemTypeERC721;
        bytes32 linkKey = keccak256(abi.encodePacked(tokenAddress, tokenId));

        uint256 noteId = ++_profileById[fromProfileId].noteCount;

        PostLogic.postNote4Link(
            noteData,
            noteId,
            linklistId,
            linkItemType,
            linkKey,
            _noteByIdByProfile
        );

        return noteId;
    }

    function postNote4AnyLink(
        DataTypes.PostNoteData calldata noteData,
        uint256 fromProfileId,
        string calldata toUri,
        bytes32 linkType
    ) external returns (uint256) {
        _validateCallerIsProfileOwner(noteData.profileId);

        uint256 linklistId = _attachedLinklists[fromProfileId][linkType];
        bytes32 linkItemType = Constants.LinkItemTypeAny;
        bytes32 linkKey = keccak256(abi.encodePacked("LinkAny", toUri));

        uint256 noteId = ++_profileById[fromProfileId].noteCount;

        PostLogic.postNote4Link(
            noteData,
            noteId,
            linklistId,
            linkItemType,
            linkKey,
            _noteByIdByProfile
        );

        return noteId;
    }

    function burn(uint256 tokenId) public override {
        super.burn(tokenId);

        bytes32 handleHash = keccak256(bytes(_profileById[tokenId].handle));
        _profileIdByHandleHash[handleHash] = 0;
    }

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

    function getNote(uint256 profileId, uint256 noteId)
        external
        view
        returns (DataTypes.Note memory)
    {
        return _noteByIdByProfile[profileId][noteId];
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

    function tokenURI(uint256 profileId) public view override returns (string memory) {
        return _profileById[profileId].uri;
    }

    function getLinklistUri(uint256 profileId, bytes32 linkType)
        external
        view
        returns (string memory)
    {
        uint256 tokenId = _attachedLinklists[profileId][linkType];
        return ILinklist(_linklist).Uri(tokenId);
    }

    function getLinkingProfileIds(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory results)
    {
        uint256 linkListId = _attachedLinklists[fromProfileId][linkType];
        uint256[] memory linkingProfileIds = ILinklist(_linklist).getLinkingProfileIds(linkListId);

        uint256 l = linkingProfileIds.length;

        uint256 j = 0;
        for (uint256 i = 0; i < l; i++) {
            if (_exists(linkingProfileIds[i])) {
                j++;
            }
        }
        results = new uint256[](j);
        j = 0;
        for (uint256 i = 0; i < l; i++) {
            if (_exists(linkingProfileIds[i])) {
                results[j] = linkingProfileIds[i];
                j++;
            }
        }
    }

    function getLinklistContract() external view returns (address) {
        return _linklist;
    }

    function _takeOverLinkList(uint256 tokenId, uint256 profileId) internal {
        _validateCallerIsProfileOwner(profileId);

        ILinklist(_linklist).setTakeOver(tokenId, msg.sender, profileId);
    }

    function _mintLinklist(
        uint256 profileId,
        bytes32 linkType,
        address to
    ) internal returns (uint256 linklistId) {
        linklistId = _attachedLinklists[profileId][linkType];
        if (linklistId == 0) {
            linklistId = IERC721Enumerable(_linklist).totalSupply().add(1);
            // mint linkList nft
            ILinklist(_linklist).mint(to, linkType, linklistId);
            // set primary linkList
            attachLinklist(linklistId, profileId);
        }
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
        require(msg.sender == ownerOf(profileId), "NotProfileOwner");
    }

    function _validateCallerIsLinklistOwner(uint256 tokenId) internal view {
        require(msg.sender == IERC721(_linklist).ownerOf(tokenId), "NotLinkListOwner");
    }

    function _validateProfileExists(uint256 profileId) internal view {
        require(_exists(profileId), "ProfileNotExists");
    }

    function _validateCallerIsERC721Owner(address tokenAddress, uint256 tokenId) internal view {
        require(msg.sender == ERC721(tokenAddress).ownerOf(tokenId), "NotERC721Owner");
    }

    function _validateERC721Exists(address tokenAddress, uint256 tokenId) internal view {
        require(address(0) != IERC721(tokenAddress).ownerOf(tokenId), "REC721NotExists");
    }

    function _validateNoteExists(uint256 profileId, uint256 noteId) internal view {
        require(noteId <= _profileById[profileId].noteCount, "NoteNotExists");
    }

    function _validateLinklistAttached(uint256 linklistId, uint256 profileId) internal view {
        require(
            profileId == ILinklist(_linklist).getCurrentTakeOver(linklistId),
            "UnattachedLinklist"
        );
    }

    function getRevision() external pure returns (uint256) {
        return REVISION;
    }
}
