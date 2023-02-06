// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "../libraries/DataTypes.sol";

interface ILinklist {
    function initialize(
        string calldata name_,
        string calldata symbol_,
        address web3Entry_
    ) external;

    function mint(
        uint256 characterId,
        bytes32 linkType,
        uint256 tokenId
    ) external;

    function setUri(uint256 tokenId, string memory newUri) external;

    /////////////////////////////////
    // linking Character
    /////////////////////////////////
    function addLinkingCharacterId(
        uint256 tokenId,
        uint256 toCharacterId,
        bytes32 tag
    ) external;

    function removeLinkingCharacterId(
        uint256 tokenId,
        uint256 toCharacterId,
        bytes32 tag
    ) external;

    /////////////////////////////////
    // linking Note
    /////////////////////////////////
    function addLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId,
        bytes32 tag
    ) external returns (bytes32);

    function removeLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId,
        bytes32 tag
    ) external;

    /////////////////////////////////
    // linking ERC721
    /////////////////////////////////
    function addLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId,
        bytes32 tag
    ) external returns (bytes32);

    function removeLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId,
        bytes32 tag
    ) external;

    /////////////////////////////////
    // linking Address
    /////////////////////////////////
    function addLinkingAddress(
        uint256 tokenId,
        address ethAddress,
        bytes32 tag
    ) external;

    function removeLinkingAddress(
        uint256 tokenId,
        address ethAddress,
        bytes32 tag
    ) external;

    /////////////////////////////////
    // linking Any
    /////////////////////////////////
    function addLinkingAnyUri(
        uint256 tokenId,
        string memory toUri,
        bytes32 tag
    ) external returns (bytes32);

    function removeLinkingAnyUri(
        uint256 tokenId,
        string memory toUri,
        bytes32 tag
    ) external;

    /////////////////////////////////
    // linking Linklist
    /////////////////////////////////
    function addLinkingLinklistId(
        uint256 tokenId,
        uint256 linklistId,
        bytes32 tag
    ) external;

    function removeLinkingLinklistId(
        uint256 tokenId,
        uint256 linklistId,
        bytes32 tag
    ) external;

    /////////////////////////////////
    // linking CharacterLink
    /////////////////////////////////
    function addLinkingCharacterLink(
        uint256 tokenId,
        DataTypes.CharacterLinkStruct calldata linkData
    ) external;

    function removeLinkingCharacterLink(
        uint256 tokenId,
        DataTypes.CharacterLinkStruct calldata linkData
    ) external;

    function getLinkingCharacterIds(uint256 tokenId) external view returns (uint256[] memory);

    function getLinkingCharacterListLength(uint256 tokenId) external view returns (uint256);

    function getOwnerCharacterId(uint256 tokenId) external view returns (uint256);

    function getLinkingNotes(uint256 tokenId)
        external
        view
        returns (DataTypes.NoteStruct[] memory results);

    function getLinkingNote(bytes32 linkKey) external view returns (DataTypes.NoteStruct memory);

    function getLinkingNoteListLength(uint256 tokenId) external view returns (uint256);

    function getLinkingCharacterLinks(uint256 tokenId)
        external
        view
        returns (DataTypes.CharacterLinkStruct[] memory results);

    function getLinkingCharacterLink(bytes32 linkKey)
        external
        view
        returns (DataTypes.CharacterLinkStruct memory);

    function getLinkingCharacterLinkListLength(uint256 tokenId) external view returns (uint256);

    function getLinkingERC721s(uint256 tokenId)
        external
        view
        returns (DataTypes.ERC721Struct[] memory results);

    function getLinkingERC721(bytes32 linkKey)
        external
        view
        returns (DataTypes.ERC721Struct memory);

    function getLinkingERC721ListLength(uint256 tokenId) external view returns (uint256);

    function getLinkingAddresses(uint256 tokenId) external view returns (address[] memory);

    function getLinkingAddressListLength(uint256 tokenId) external view returns (uint256);

    function getLinkingAnyUris(uint256 tokenId) external view returns (string[] memory results);

    function getLinkingAnyUri(bytes32 linkKey) external view returns (string memory);

    function getLinkingAnyUriKeys(uint256 tokenId) external view returns (bytes32[] memory);

    function getLinkingAnyListLength(uint256 tokenId) external view returns (uint256);

    function getLinkingLinklistIds(uint256 tokenId) external view returns (uint256[] memory);

    function getLinkingLinklistLength(uint256 tokenId) external view returns (uint256);

    function getLinkedCharacterTags(uint256 tokenId, uint256 characterId)
        external
        view
        returns (bytes32[] memory);

    function getLinkedUriTags(uint256 tokenId, bytes32 toUri)
        external
        view
        returns (bytes32[] memory);

    function getLinkedAddressTags(uint256 tokenId, address ethAddress)
        external
        view
        returns (bytes32[] memory);

    function getLinkedLinklistTags(uint256 tokenId, uint256 linklistId)
        external
        view
        returns (bytes32[] memory);

    function getLinkedCharacterLinkTags(
        uint256 tokenId,
        uint256 fromCharacterId,
        uint256 toCharacterId,
        bytes32 linkType
    ) external view returns (bytes32[] memory);

    function getLinkedNoteTags(
        uint256 tokenId,
        uint256 characterId,
        uint256 noteId
    ) external view returns (bytes32[] memory);

    function getLinkedERC721Tags(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external view returns (bytes32[] memory);

    // NOTE: This function is deprecated.
    function getCurrentTakeOver(uint256 tokenId) external view returns (uint256);

    function getLinkType(uint256 tokenId) external view returns (bytes32);

    // solhint-disable func-name-mixedcase
    function Uri(uint256 tokenId) external view returns (string memory);

    function characterOwnerOf(uint256 tokenId) external view returns (uint256);

    function balanceOf(uint256 characterId) external view returns (uint256);
}
