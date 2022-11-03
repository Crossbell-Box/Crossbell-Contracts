// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/DataTypes.sol";

interface ILinklist {
    function mint(
        uint256 characterId,
        bytes32 linkType,
        uint256 tokenId
    ) external;

    function setUri(uint256 tokenId, string memory _uri) external;

    /////////////////////////////////
    // linking Character
    /////////////////////////////////
    function addLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external;

    function removeLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external;

    function getLinkingCharacterIds(uint256 tokenId) external view returns (uint256[] memory);

    function getLinkingCharacterListLength(uint256 tokenId) external view returns (uint256);

    function getOwnerCharacterId(uint256 tokenId) external view returns (uint256);

    /////////////////////////////////
    // linking Note
    /////////////////////////////////
    function addLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId
    ) external returns (bytes32);

    function removeLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId
    ) external;

    function getLinkingNotes(uint256 tokenId)
        external
        view
        returns (DataTypes.NoteStruct[] memory results);

    function getLinkingNote(bytes32 linkKey) external view returns (DataTypes.NoteStruct memory);

    function getLinkingNoteListLength(uint256 tokenId) external view returns (uint256);

    function addLinkingCharacterLink(
        uint256 tokenId,
        DataTypes.CharacterLinkStruct calldata linkData
    ) external;

    function removeLinkingCharacterLink(
        uint256 tokenId,
        DataTypes.CharacterLinkStruct calldata linkData
    ) external;

    function getLinkingCharacterLinks(uint256 tokenId)
        external
        view
        returns (DataTypes.CharacterLinkStruct[] memory results);

    function getLinkingCharacterLink(bytes32 linkKey)
        external
        view
        returns (DataTypes.CharacterLinkStruct memory);

    function getLinkingCharacterLinkListLength(uint256 tokenId) external view returns (uint256);

    /////////////////////////////////
    // linking ERC721
    /////////////////////////////////
    function addLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external returns (bytes32);

    function removeLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external;

    function getLinkingERC721s(uint256 tokenId)
        external
        view
        returns (DataTypes.ERC721Struct[] memory results);

    function getLinkingERC721(bytes32 linkKey)
        external
        view
        returns (DataTypes.ERC721Struct memory);

    function getLinkingERC721ListLength(uint256 tokenId) external view returns (uint256);

    /////////////////////////////////
    // linking Address
    /////////////////////////////////
    function addLinkingAddress(uint256 tokenId, address ethAddress) external;

    function removeLinkingAddress(uint256 tokenId, address ethAddress) external;

    function getLinkingAddresses(uint256 tokenId) external view returns (address[] memory);

    function getLinkingAddressListLength(uint256 tokenId) external view returns (uint256);

    /////////////////////////////////
    // linking Any
    /////////////////////////////////
    function addLinkingAnyUri(uint256 tokenId, string memory toUri) external returns (bytes32);

    function removeLinkingAnyUri(uint256 tokenId, string memory toUri) external;

    function getLinkingAnyUris(uint256 tokenId) external view returns (string[] memory results);

    function getLinkingAnyUri(bytes32 linkKey) external view returns (string memory);

    function getLinkingAnyUriKeys(uint256 tokenId) external view returns (bytes32[] memory);

    function getLinkingAnyListLength(uint256 tokenId) external view returns (uint256);

    /////////////////////////////////
    // linking Linklist
    /////////////////////////////////
    function addLinkingLinklistId(uint256 tokenId, uint256 linklistId) external;

    function removeLinkingLinklistId(uint256 tokenId, uint256 linklistId) external;

    function getLinkingLinklistIds(uint256 tokenId) external view returns (uint256[] memory);

    function getLinkingLinklistLength(uint256 tokenId) external view returns (uint256);

    function getCurrentTakeOver(uint256 tokenId) external view returns (uint256);

    function getLinkType(uint256 tokenId) external view returns (bytes32);

    function Uri(uint256 tokenId) external view returns (string memory);

}
