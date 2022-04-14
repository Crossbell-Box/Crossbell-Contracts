// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/DataTypes.sol";

interface IWeb3Entry {
    // TODO: add sig for all write functions

    // createProfile creates a profile, and mint a profile NFT
    function createProfile(
        address to,
        string calldata handle,
        string calldata metadataUri
    ) external;

    function setHandle(uint256 profileId, string calldata newHandle) external;

    function setSocialToken(uint256 profileId, address tokenAddress) external;

    function setProfileMetadataUri(
        uint256 profileId,
        string calldata newMetadataUri
    ) external;

    function setPrimaryProfileId(uint256 profileId) external;

    function setPrimaryLinkList(uint256 linkListId, uint256 profileId) external;

    function setLinklistUri(uint256 linkListId, string calldata linklistUri)
        external;

    //
    // function setSocialTokenAddress(uint256 profileId, address tokenAddress) external; // next launch

    // TODO: add a arbitrary data param passed to link/mint. Is there any cons?

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

    //    function linkNote(
    //        uint256 fromProfileId,
    //        uint256 toProfileId,
    //        uint256 toNoteId,
    //        bytes32 linkType
    //    ) external;

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

    function setProfileLinkModule(uint256 profileId, address moduleAddress)
        external; // set link module for his profile

    function setNoteLinkModule(
        uint256 profileId,
        uint256 noteId,
        address moduleAddress
    ) external;

    function setLinkListLinkModule(uint256 tokenId, address moduleAddress)
        external;

    function setERC721LinkModule(
        address tokenAddress,
        uint256 tokenId,
        address moduleAddress
    ) external;

    function setAddressLinkModule(address account, address moduleAddress)
        external;

    // set link module for single link item
    function setLinkLinkModule(
        DataTypes.LinkData calldata linkData,
        address moduleAddress
    ) external;

    function mintNote(
        uint256 profileId,
        uint256 noteId,
        address to
    ) external;

    function mintLink(DataTypes.LinkData calldata linkData, address receiver)
        external;

    function setMintModuleForNote(
        uint256 profileId,
        uint256 toNoteId,
        address moduleAddress
    ) external;

    // set mint module for his single link item
    function setMintModuleForLink(
        DataTypes.LinkData calldata linkData,
        address moduleAddress
    ) external;

    function postNote(DataTypes.PostNoteData calldata vars)
        external
        returns (uint256);

    function postNoteWithLink(
        DataTypes.PostNoteData calldata vars,
        DataTypes.LinkData calldata linkData
    ) external;

    function setLinkListUri(
        uint256 profileId,
        bytes32 linkType,
        string memory Uri
    ) external;

    function getPrimaryProfile(address account) external view returns (uint256);

    function getProfile(uint256 profileId)
        external
        view
        returns (DataTypes.Profile memory);

    function getProfileId(string calldata handle)
        external
        view
        returns (uint256);

    function getHandle(uint256 profileId) external view returns (string memory);

    function getProfileMetadataUri(uint256 profileId)
        external
        view
        returns (string memory);

    function getProfileLinkModule(uint256 profileId) external returns (address);

    function getLinkListUri(uint256 profileId)
        external
        view
        returns (string memory);

    function getLinkedProfileIds(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory);

    function getNoteURI(uint256 profileId, uint256 noteId)
        external
        view
        returns (string memory);
}
