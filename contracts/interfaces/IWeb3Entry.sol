// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/DataTypes.sol";

interface IWeb3Entry {
    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _linkListContract,
        address _mintNFTImpl
    ) external;

    // createProfile creates a profile, and mint a profile NFT
    function createProfile(DataTypes.CreateProfileData calldata vars) external;

    function setHandle(uint256 profileId, string calldata newHandle) external;

    function setSocialToken(uint256 profileId, address tokenAddress) external;

    function setProfileUri(uint256 profileId, string calldata newUri) external;

    function setPrimaryProfileId(uint256 profileId) external;

    function attachLinklist(uint256 linkListId, uint256 profileId) external;

    function detachLinklist(uint256 linkListId, uint256 profileId) external;

    function setLinklistUri(uint256 linkListId, string calldata uri) external;

    // emit a link from a profile
    function linkAddress(DataTypes.linkAddressData calldata vars) external;

    function unlinkAddress(DataTypes.linkAddressData calldata vars) external;

    function linkProfile(DataTypes.linkProfileData calldata vars) external;

    function unlinkProfile(DataTypes.unlinkProfileData calldata vars) external;

    function createThenLinkProfile(DataTypes.createThenLinkProfileData calldata vars) external;

    function linkNote(DataTypes.linkNoteData calldata vars) external;

    function unlinkNote(DataTypes.unlinkNoteData calldata vars) external;

    function linkERC721(DataTypes.linkERC721Data calldata vars) external;

    function unlinkERC721(DataTypes.unlinkERC721Data calldata vars) external;

    function linkAny(DataTypes.linkAnyData calldata vars) external;

    function unlinkAny(DataTypes.unlinkAnyData calldata vars) external;

    function linkProfileLink(
        uint256 fromProfileId,
        DataTypes.ProfileLinkStruct calldata linkData,
        bytes32 linkType
    ) external;

    function unlinkProfileLink(
        uint256 fromProfileId,
        DataTypes.ProfileLinkStruct calldata linkData,
        bytes32 linkType
    ) external;

    function linkLinklist(DataTypes.linkLinklistData calldata vars) external;

    function unlinkLinklist(DataTypes.linkLinklistData calldata vars) external;

    function setLinkModule4Profile(DataTypes.setLinkModule4ProfileData calldata vars) external;

    function setLinkModule4Note(DataTypes.setLinkModule4NoteData calldata vars) external;

    function setLinkModule4Linklist(DataTypes.setLinkModule4LinklistData calldata vars) external;

    function setLinkModule4ERC721(DataTypes.setLinkModule4ERC721Data calldata vars) external;

    function setLinkModule4Address(DataTypes.setLinkModule4AddressData calldata vars) external;

    function mintNote(DataTypes.MintNoteData calldata vars) external returns (uint256);

    function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external;

    function postNote(DataTypes.PostNoteData calldata vars) external returns (uint256);

    function deleteNote(uint256 profileId, uint256 noteId) external;

    function postNote4ProfileLink(
        DataTypes.PostNoteData calldata noteData,
        DataTypes.linkProfileData calldata linkData
    ) external returns (uint256);

    function postNote4AddressLink(
        DataTypes.PostNoteData calldata noteData,
        DataTypes.linkAddressData calldata linkData
    ) external returns (uint256);

    function postNote4LinklistLink(
        DataTypes.PostNoteData calldata noteData,
        DataTypes.linkLinklistData calldata linkData
    ) external returns (uint256);

    function postNote4NoteLink(
        DataTypes.PostNoteData calldata noteData,
        DataTypes.linkNoteData calldata linkData
    ) external returns (uint256);

    function postNote4ERC721Link(
        DataTypes.PostNoteData calldata noteData,
        DataTypes.linkERC721Data calldata linkData
    ) external returns (uint256);

    function postNote4AnyLink(
        DataTypes.PostNoteData calldata noteData,
        DataTypes.linkAnyData calldata linkData
    ) external returns (uint256);

    function getPrimaryProfileId(address account) external view returns (uint256);

    function isPrimaryProfile(uint256 profileId) external view returns (bool);

    function getProfile(uint256 profileId) external view returns (DataTypes.Profile memory);

    function getProfileByHandle(string calldata handle)
        external
        view
        returns (DataTypes.Profile memory);

    function getHandle(uint256 profileId) external view returns (string memory);

    function getProfileUri(uint256 profileId) external view returns (string memory);

    function getNote(uint256 profileId, uint256 noteId)
        external
        view
        returns (DataTypes.Note memory);

    function getLinkModule4Address(address account) external view returns (address);

    function getLinkModule4Linklist(uint256 tokenId) external view returns (address);

    function getLinkModule4ERC721(address tokenAddress, uint256 tokenId)
        external
        view
        returns (address);

    function getLinklistUri(uint256 tokenId) external view returns (string memory);

    function getLinklistId(uint256 profileId, bytes32 linkType) external view returns (uint256);

    function getLinklistType(uint256 linkListId) external view returns (bytes32);

    function getLinkingProfileIds(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory);

    function getLinkingNotes(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (DataTypes.Note[] memory);

    function getLinkingNote(bytes32 linkKey) external view returns (DataTypes.NoteStruct memory);

    function getLinkingERC721s(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (DataTypes.ERC721Struct[] memory results);

    function getLinkingERC721(bytes32 linkKey)
        external
        view
        returns (DataTypes.ERC721Struct memory);

    function getLinkingAnys(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (string[] memory results);

    function getLinkingAny(bytes32 linkKey) external view returns (string memory);

    function getLinklistContract() external view returns (address);

    function getRevision() external pure returns (uint256);
}
