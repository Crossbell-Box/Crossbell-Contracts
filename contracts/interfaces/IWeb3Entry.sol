// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/DataTypes.sol";

interface IWeb3Entry {
    // TODO: add sig for all write functions

    // createProfile creates a profile, and mint a profile NFT
    function createProfile(DataTypes.CreateProfileData calldata vars) external;

    function setHandle(uint256 profileId, string calldata newHandle) external;

    function setSocialToken(uint256 profileId, address tokenAddress) external;

    function setProfileMetadataUri(
        uint256 profileId,
        string calldata newMetadataUri
    ) external;

    function setPrimaryProfileId(uint256 profileId) external;

    function setPrimaryLinklist(uint256 linkListId, uint256 profileId) external;

    function setLinklistUri(uint256 linkListId, string calldata uri) external;

    // emit a link from a profile
    function linkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) external;

    function unlinkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType
    ) external;

    function linkNote(
        uint256 fromProfileId,
        uint256 toProfileId,
        uint256 toNoteId,
        bytes32 linkType
    ) external;

    // next launch
    // When implement, should check if ERC721 is linklist contract
    function linkERC721(
        uint256 fromProfileId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType
    ) external;

    //TODO linkERC1155
    function linkAddress(
        uint256 fromProfileId,
        address ethAddress,
        bytes32 linkType
    ) external;

    function linkAny(
        uint256 fromProfileId,
        string calldata toUri,
        bytes32 linkType
    ) external;

    function linkLink(
        uint256 fromProfileId,
        DataTypes.LinkData calldata linkData
    ) external;

    function linkLinklist(
        uint256 fromProfileId,
        uint256 linkListId,
        bytes32 linkType
    ) external;

    function setLinkModule4Profile(
        uint256 profileId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external;

    function setLinkModule4Note(
        uint256 profileId,
        uint256 noteId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external;

    function setLinkModule4Linklist(
        uint256 tokenId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external;

    function setLinkModule4ERC721(
        address tokenAddress,
        uint256 tokenId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external;

    function setLinkModule4Address(
        address account,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external;

    function setLinkModule4Link(
        DataTypes.LinkData calldata linkData,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external;

    function mintNote(
        uint256 profileId,
        uint256 noteId,
        address to
    ) external;

    function mintLink(DataTypes.LinkData calldata linkData, address to)
        external;

    function setMintModuleForNote(
        uint256 profileId,
        uint256 toNoteId,
        address mintModule,
        bytes calldata mintModuleInitData
    ) external;

    // set mint module for his single link item
    function setMintModuleForLink(
        DataTypes.LinkData calldata linkData,
        address mintModule,
        bytes calldata mintModuleInitData
    ) external;

    function postNote(DataTypes.PostNoteData calldata noteData)
        external
        returns (uint256);

    function postNoteWithLink(
        DataTypes.PostNoteData calldata noteData,
        DataTypes.LinkData calldata linkData
    ) external;

    function getPrimaryProfileId(address account)
        external
        view
        returns (uint256);

    function isPrimaryProfile(uint256 profileId) external view returns (bool);

    function getProfile(uint256 profileId)
        external
        view
        returns (DataTypes.Profile memory);

    function getProfileByHandle(string calldata handle)
        external
        view
        returns (DataTypes.Profile memory);

    function getHandle(uint256 profileId) external view returns (string memory);

    function getProfileMetadataUri(uint256 profileId)
        external
        view
        returns (string memory);

    function getLinkModule4Profile(uint256 profileId)
        external
        view
        returns (address);

    function getLinkModule4Address(address account)
        external
        view
        returns (address);

    function getLinkModule4Linklist(uint256 tokenId)
        external
        view
        returns (address);

    function getLinkModule4ERC721(address tokenAddress, uint256 tokenId)
        external
        view
        returns (address);

    function getLinkModule4Link(DataTypes.LinkData calldata linkData)
        external
        view
        returns (address);

    function getMintModuleForNote(uint256 profileId, uint256 toNoteId)
        external
        view
        returns (address);

    function getMintModuleForLink(DataTypes.LinkData calldata linkData)
        external
        view
        returns (address);

    function getLinkListUri(uint256 profileId, bytes32 linkType)
        external
        view
        returns (string memory);

    function getLinkingProfileIds(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory);

    function getNoteUri(uint256 profileId, uint256 noteId)
        external
        view
        returns (string memory);

    function getLinklistContract() external view returns (address);
}
