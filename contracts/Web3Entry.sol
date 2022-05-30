// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "hardhat/console.sol";
import "./base/NFTBase.sol";
import "./interfaces/IWeb3Entry.sol";
import "./interfaces/ILinklist.sol";
import "./interfaces/ILinkModule4Note.sol";
import "./interfaces/IResolver.sol";
import "./storage/Web3EntryStorage.sol";
import "./storage/Web3EntryExtendStorage.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Constants.sol";
import "./libraries/Events.sol";
import "./libraries/ProfileLogic.sol";
import "./libraries/PostLogic.sol";
import "./libraries/LinkModuleLogic.sol";
import "./libraries/LinkLogic.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract Web3Entry is IWeb3Entry, NFTBase, Web3EntryStorage, Initializable, Web3EntryExtendStorage {
    using Strings for uint256;

    uint256 internal constant REVISION = 3;

    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _linklistContract,
        address _mintNFTImpl,
        address _periphery,
        address _resolver
    ) external initializer {
        super._initialize(_name, _symbol);
        _linklist = _linklistContract;
        MINT_NFT_IMPL = _mintNFTImpl;
        periphery = _periphery;
        resolver = _resolver;

        emit Events.Web3EntryInitialized(block.timestamp);
    }

    function canCreate(string calldata handle, address account) public view returns (bool) {
        if (resolver == address(0)) {
            return true;
        }
        address ensOwner = IResolver(resolver).getENSRecord(handle);
        address rnsOwner = IResolver(resolver).getRNSRecord(handle);
        if (ensOwner == account || rnsOwner == account) {
            return true;
        }

        if (ensOwner == address(0) && rnsOwner == address(0)) {
            return true;
        }

        return false;
    }

    function createProfile(DataTypes.CreateProfileData calldata vars) external {
        require(canCreate(vars.handle, vars.to), "HandleNotEligible");

        _profileCounter = _profileCounter + 1;

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
        _validateCallerIsProfileOwnerOrOperator(profileId);
        require(canCreate(newHandle, ownerOf(profileId)), "HandleNotEligible");

        ProfileLogic.setHandle(profileId, newHandle, _profileIdByHandleHash, _profileById);
    }

    function setSocialToken(uint256 profileId, address tokenAddress) external {
        _validateCallerIsProfileOwnerOrOperator(profileId);

        ProfileLogic.setSocialToken(profileId, tokenAddress, _profileById);
    }

    function setProfileUri(uint256 profileId, string calldata newUri) external {
        _validateCallerIsProfileOwnerOrOperator(profileId);

        _profileById[profileId].uri = newUri;

        emit Events.SetProfileUri(profileId, newUri);
    }

    function setPrimaryProfileId(uint256 profileId) external {
        _validateCallerIsProfileOwnerOrOperator(profileId);

        uint256 oldProfileId = _primaryProfileByAddress[msg.sender];
        _primaryProfileByAddress[msg.sender] = profileId;

        emit Events.SetPrimaryProfileId(msg.sender, profileId, oldProfileId);
    }

    function setOperator(uint256 profileId, address operator) external {
        _validateCallerIsProfileOwner(profileId);
        _setOperator(profileId, operator);
    }

    function attachLinklist(uint256 linklistId, uint256 profileId) external {
        _validateCallerIsProfileOwnerOrOperator(profileId);

        bytes32 linkType = ILinklist(_linklist).getLinkType(linklistId);
        ILinklist(_linklist).setTakeOver(linklistId, msg.sender, profileId);
        _attachedLinklists[profileId][linkType] = linklistId;

        emit Events.AttachLinklist(linklistId, profileId, linkType);
    }

    function detachLinklist(uint256 linklistId, uint256 profileId) external {
        _validateCallerIsProfileOwnerOrOperatorOrLinklist(profileId);

        bytes32 linkType = ILinklist(_linklist).getLinkType(linklistId);
        _attachedLinklists[profileId][linkType] = 0;

        emit Events.DetachLinklist(linklistId, profileId, linkType);
    }

    function setLinklistUri(uint256 linklistId, string calldata uri) external {
        _validateCallerIsLinklistOwner(linklistId);

        ILinklist(_linklist).setUri(linklistId, uri);
    }

    function linkProfile(DataTypes.linkProfileData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);
        _validateProfileExists(vars.toProfileId);

        LinkLogic.linkProfile(
            vars.fromProfileId,
            vars.toProfileId,
            vars.linkType,
            vars.data,
            IERC721Enumerable(this).ownerOf(vars.fromProfileId),
            _linklist,
            _profileById[vars.toProfileId].linkModule,
            _attachedLinklists
        );
    }

    function unlinkProfile(DataTypes.unlinkProfileData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);

        LinkLogic.unlinkProfile(
            vars,
            _linklist,
            _attachedLinklists[vars.fromProfileId][vars.linkType]
        );
    }

    function createThenLinkProfile(DataTypes.createThenLinkProfileData calldata vars) external {
        _createThenLinkProfile(vars.fromProfileId, vars.to, vars.linkType, "0x");
    }

    function _createThenLinkProfile(
        uint256 fromProfileId,
        address to,
        bytes32 linkType,
        bytes memory data
    ) internal {
        _validateCallerIsProfileOwnerOrOperator(fromProfileId);
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
        LinkLogic.linkProfile(
            fromProfileId,
            profileId,
            linkType,
            data,
            IERC721Enumerable(this).ownerOf(fromProfileId),
            _linklist,
            address(0),
            _attachedLinklists
        );
    }

    function linkNote(DataTypes.linkNoteData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);
        _validateNoteExists(vars.toProfileId, vars.toNoteId);

        LinkLogic.linkNote(vars, _linklist, _noteByIdByProfile, _attachedLinklists);
    }

    function unlinkNote(DataTypes.unlinkNoteData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);

        LinkLogic.unlinkNote(vars, _linklist, _attachedLinklists);
    }

    function linkERC721(DataTypes.linkERC721Data calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);
        _validateERC721Exists(vars.tokenAddress, vars.tokenId);

        LinkLogic.linkERC721(vars, _linklist, _attachedLinklists);
    }

    function unlinkERC721(DataTypes.unlinkERC721Data calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);

        LinkLogic.unlinkERC721(
            vars,
            _linklist,
            _attachedLinklists[vars.fromProfileId][vars.linkType]
        );
    }

    function linkAddress(DataTypes.linkAddressData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);

        LinkLogic.linkAddress(vars, _linklist, _attachedLinklists);
    }

    function unlinkAddress(DataTypes.linkAddressData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);

        LinkLogic.unlinkAddress(
            vars,
            _linklist,
            _attachedLinklists[vars.fromProfileId][vars.linkType]
        );
    }

    function linkAnyUri(DataTypes.linkAnyUriData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);

        LinkLogic.linkAnyUri(vars, _linklist, _attachedLinklists);
    }

    function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);

        LinkLogic.unlinkAnyUri(
            vars,
            _linklist,
            _attachedLinklists[vars.fromProfileId][vars.linkType]
        );
    }

    function linkProfileLink(
        uint256 fromProfileId,
        DataTypes.ProfileLinkStruct calldata linkData,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwnerOrOperator(fromProfileId);

        LinkLogic.linkProfileLink(fromProfileId, linkData, linkType, _linklist, _attachedLinklists);
    }

    function unlinkProfileLink(
        uint256 fromProfileId,
        DataTypes.ProfileLinkStruct calldata linkData,
        bytes32 linkType
    ) external {
        _validateCallerIsProfileOwnerOrOperator(fromProfileId);

        LinkLogic.unlinkProfileLink(
            fromProfileId,
            linkData,
            linkType,
            _linklist,
            _attachedLinklists[linkData.fromProfileId][linkData.linkType]
        );
    }

    function linkLinklist(DataTypes.linkLinklistData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);

        LinkLogic.linkLinklist(vars, _linklist, _attachedLinklists);
    }

    function unlinkLinklist(DataTypes.linkLinklistData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.fromProfileId);

        LinkLogic.unlinkLinklist(
            vars,
            _linklist,
            _attachedLinklists[vars.fromProfileId][vars.linkType]
        );
    }

    // set link module for his profile
    function setLinkModule4Profile(DataTypes.setLinkModule4ProfileData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.profileId);

        ProfileLogic.setProfileLinkModule(
            vars.profileId,
            vars.linkModule,
            vars.linkModuleInitData,
            _profileById[vars.profileId]
        );
    }

    function setLinkModule4Note(DataTypes.setLinkModule4NoteData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.profileId);
        _validateNoteExists(vars.profileId, vars.noteId);

        LinkModuleLogic.setLinkModule4Note(
            vars.profileId,
            vars.noteId,
            vars.linkModule,
            vars.linkModuleInitData,
            _noteByIdByProfile
        );
    }

    function setLinkModule4Linklist(DataTypes.setLinkModule4LinklistData calldata vars) external {
        _validateCallerIsLinklistOwner(vars.linklistId);

        LinkModuleLogic.setLinkModule4Linklist(
            vars.linklistId,
            vars.linkModule,
            vars.linkModuleInitData,
            _linkModules4Linklist
        );
    }

    function setLinkModule4ERC721(DataTypes.setLinkModule4ERC721Data calldata vars) external {
        _validateCallerIsERC721Owner(vars.tokenAddress, vars.tokenId);

        LinkModuleLogic.setLinkModule4ERC721(
            vars.tokenAddress,
            vars.tokenId,
            vars.linkModule,
            vars.linkModuleInitData,
            _linkModules4ERC721
        );
    }

    function setLinkModule4Address(DataTypes.setLinkModule4AddressData calldata vars) external {
        LinkModuleLogic.setLinkModule4Address(
            vars.account,
            vars.linkModule,
            vars.linkModuleInitData,
            _linkModules4Address
        );
    }

    function mintNote(DataTypes.MintNoteData calldata vars) external returns (uint256) {
        _validateNoteExists(vars.profileId, vars.noteId);

        return
            PostLogic.mintNote(
                vars.profileId,
                vars.noteId,
                vars.to,
                vars.mintModuleData,
                MINT_NFT_IMPL,
                _profileById,
                _noteByIdByProfile
            );
    }

    function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external {
        _validateCallerIsProfileOwnerOrOperator(vars.profileId);
        _validateNoteExists(vars.profileId, vars.noteId);

        LinkModuleLogic.setMintModule4Note(
            vars.profileId,
            vars.noteId,
            vars.mintModule,
            vars.mintModuleInitData,
            _noteByIdByProfile
        );
    }

    function postNote(DataTypes.PostNoteData calldata vars) external returns (uint256) {
        _validateCallerIsProfileOwnerOrOperator(vars.profileId);

        uint256 noteId = ++_profileById[vars.profileId].noteCount;

        PostLogic.postNoteWithLink(vars, noteId, 0, 0, "", _noteByIdByProfile);
        return noteId;
    }

    function setNoteUri(
        uint256 profileId,
        uint256 noteId,
        string calldata newUri
    ) external {
        _validateCallerIsProfileOwnerOrOperator(profileId);
        _validateNoteExists(profileId, noteId);
        require(!_noteByIdByProfile[profileId][noteId].locked, "NoteLocked");

        _noteByIdByProfile[profileId][noteId].contentUri = newUri;

        emit Events.SetNoteUri(profileId, noteId, newUri);
    }

    function lockNote(uint256 profileId, uint256 noteId) external {
        _validateCallerIsProfileOwnerOrOperator(profileId);
        _validateNoteExists(profileId, noteId);

        _noteByIdByProfile[profileId][noteId].locked = true;

        emit Events.LockNote(profileId, noteId);
    }

    function deleteNote(uint256 profileId, uint256 noteId) external {
        _validateCallerIsProfileOwnerOrOperator(profileId);
        _validateNoteExists(profileId, noteId);

        _noteByIdByProfile[profileId][noteId].deleted = true;
    }

    function postNote4Profile(DataTypes.PostNoteData calldata postNoteData, uint256 toProfileId)
        external
        returns (uint256)
    {
        _validateCallerIsProfileOwnerOrOperator(postNoteData.profileId);

        bytes32 linkItemType = Constants.NoteLinkTypeProfile;
        bytes32 linkKey = bytes32(toProfileId);
        uint256 noteId = ++_profileById[postNoteData.profileId].noteCount;

        PostLogic.postNoteWithLink(
            postNoteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(toProfileId),
            _noteByIdByProfile
        );

        return noteId;
    }

    function postNote4Address(DataTypes.PostNoteData calldata noteData, address ethAddress)
        external
        returns (uint256)
    {
        _validateCallerIsProfileOwnerOrOperator(noteData.profileId);

        bytes32 linkItemType = Constants.NoteLinkTypeAddress;
        bytes32 linkKey = bytes32(uint256(uint160(ethAddress)));
        uint256 noteId = ++_profileById[noteData.profileId].noteCount;

        PostLogic.postNoteWithLink(
            noteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(ethAddress),
            _noteByIdByProfile
        );

        return noteId;
    }

    function postNote4Linklist(DataTypes.PostNoteData calldata noteData, uint256 toLinklistId)
        external
        returns (uint256)
    {
        _validateCallerIsProfileOwnerOrOperator(noteData.profileId);

        bytes32 linkItemType = Constants.NoteLinkTypeLinklist;
        bytes32 linkKey = bytes32(toLinklistId);
        uint256 noteId = ++_profileById[noteData.profileId].noteCount;

        PostLogic.postNoteWithLink(
            noteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(toLinklistId),
            _noteByIdByProfile
        );

        return noteId;
    }

    function postNote4Note(
        DataTypes.PostNoteData calldata postNoteData,
        DataTypes.NoteStruct calldata note
    ) external returns (uint256) {
        _validateCallerIsProfileOwnerOrOperator(postNoteData.profileId);

        bytes32 linkItemType = Constants.NoteLinkTypeNote;
        bytes32 linkKey = ILinklist(_linklist).addLinkingNote(0, note.profileId, note.noteId);
        uint256 noteId = ++_profileById[postNoteData.profileId].noteCount;

        PostLogic.postNoteWithLink(
            postNoteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(note.profileId, note.noteId),
            _noteByIdByProfile
        );

        return noteId;
    }

    function postNote4ERC721(
        DataTypes.PostNoteData calldata postNoteData,
        DataTypes.ERC721Struct calldata erc721
    ) external returns (uint256) {
        _validateCallerIsProfileOwnerOrOperator(postNoteData.profileId);
        _validateERC721Exists(erc721.tokenAddress, erc721.erc721TokenId);

        bytes32 linkItemType = Constants.NoteLinkTypeERC721;
        bytes32 linkKey = ILinklist(_linklist).addLinkingERC721(
            0,
            erc721.tokenAddress,
            erc721.erc721TokenId
        );
        uint256 noteId = ++_profileById[postNoteData.profileId].noteCount;

        PostLogic.postNoteWithLink(
            postNoteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(erc721.tokenAddress, erc721.erc721TokenId),
            _noteByIdByProfile
        );

        return noteId;
    }

    function postNote4AnyUri(DataTypes.PostNoteData calldata postNoteData, string calldata uri)
        external
        returns (uint256)
    {
        _validateCallerIsProfileOwnerOrOperator(postNoteData.profileId);

        bytes32 linkItemType = Constants.NoteLinkTypeAnyUri;
        bytes32 linkKey = ILinklist(_linklist).addLinkingAnyUri(0, uri);
        uint256 noteId = ++_profileById[postNoteData.profileId].noteCount;

        PostLogic.postNoteWithLink(
            postNoteData,
            noteId,
            linkItemType,
            linkKey,
            abi.encodePacked(uri),
            _noteByIdByProfile
        );

        return noteId;
    }

    function burn(uint256 tokenId) public override {
        // clear handle
        bytes32 handleHash = keccak256(bytes(_profileById[tokenId].handle));
        _profileIdByHandleHash[handleHash] = 0;

        // clear profile
        delete _profileById[tokenId];

        // burn token
        super.burn(tokenId);
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

    function getOperator(uint256 profileId) external view returns (address) {
        return _operatorByProfile[profileId];
    }

    function getNote(uint256 profileId, uint256 noteId)
        external
        view
        returns (DataTypes.Note memory)
    {
        return _noteByIdByProfile[profileId][noteId];
    }

    function getNotesByProfileId(
        uint256 profileId,
        uint256 offset,
        uint256 limit
    ) external view returns (DataTypes.Note[] memory results) {
        uint256 count = _profileById[profileId].noteCount;
        limit = Math.min(limit, count - offset);

        results = new DataTypes.Note[](limit);
        if (offset >= count) return results;

        for (uint256 i = offset; i < limit; i++) {
            results[i] = _noteByIdByProfile[profileId][i];
        }
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

    function getLinklistUri(uint256 tokenId) external view returns (string memory) {
        return ILinklist(_linklist).Uri(tokenId);
    }

    function getLinklistId(uint256 profileId, bytes32 linkType) external view returns (uint256) {
        return _attachedLinklists[profileId][linkType];
    }

    function getLinklistType(uint256 linkListId) external view returns (bytes32) {
        return ILinklist(_linklist).getLinkType(linkListId);
    }

    function getLinklistContract() external view returns (address) {
        return _linklist;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        if (_operatorByProfile[tokenId] != address(0)) {
            _setOperator(tokenId, address(0));
        }

        if (_primaryProfileByAddress[from] != 0) {
            _primaryProfileByAddress[from] = 0;
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _setOperator(uint256 profileId, address operator) internal {
        _operatorByProfile[profileId] = operator;
        emit Events.SetOperator(profileId, operator, block.timestamp);
    }

    function _validateCallerIsProfileOwnerOrOperatorOrLinklist(uint256 profileId) internal view {
        address owner = ownerOf(profileId);
        require(
            msg.sender == owner ||
                msg.sender == _operatorByProfile[profileId] ||
                (tx.origin == owner && msg.sender == _linklist),
            "NotProfileOwner"
        );
    }

    function _validateCallerIsProfileOwnerOrOperator(uint256 profileId) internal view {
        address owner = ownerOf(profileId);
        require(
            msg.sender == owner ||
                msg.sender == _operatorByProfile[profileId] ||
                (tx.origin == owner && msg.sender == periphery),
            "NotProfileOwner"
        );
    }

    function _validateCallerIsProfileOwner(uint256 profileId) internal view {
        address owner = ownerOf(profileId);
        require(
            msg.sender == owner || (tx.origin == owner && msg.sender == periphery),
            "NotProfileOwner"
        );
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
        require(!_noteByIdByProfile[profileId][noteId].deleted, "NoteIsDeleted");
        require(noteId <= _profileById[profileId].noteCount, "NoteNotExists");
    }

    function getRevision() external pure returns (uint256) {
        return REVISION;
    }
}
