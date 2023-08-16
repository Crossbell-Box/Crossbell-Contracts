// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {DataTypes} from "../libraries/DataTypes.sol";

interface ILinklist {
    /**
     * @notice Initializes the contract.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param web3Entry_ The address of the Web3Entry contract.
     */
    function initialize(
        string calldata name_,
        string calldata symbol_,
        address web3Entry_
    ) external;

    /**
     * @notice Mints a Linklist NFT to the specified character with linkType.
     * This can only be called by web3Entry.
     * @param characterId The character ID to mint to.
     * @param linkType  The type of link.
     * @return tokenId The minted token ID.
     */
    function mint(uint256 characterId, bytes32 linkType) external returns (uint256 tokenId);

    /**
     * @notice Burns a Linklist NFT.
     * @param tokenId The token ID to burn.
     */
    function burn(uint256 tokenId) external;

    /**
     * @notice  Set URI for a linklist. You can set any URI for your linklist, and the functionality of this URI
     * is undetermined and expandable. One scenario that comes to mind is setting a cover for your liked notes
     * or following list in your bookmarks.
     * @param   tokenId  Linklist ID.
     * @param   newUri  Any URI.
     */
    function setUri(uint256 tokenId, string memory newUri) external;

    /////////////////////////////////
    // linking Character
    /////////////////////////////////
    /**
     * @notice Adds a linked character to a linklist.
     * @param tokenId The token ID of linklist.
     * @param toCharacterId The character ID to link.
     */
    function addLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external;

    /**
     * @notice Removes a linked character from a linklist.
     * @param tokenId The token ID of linklist.
     * @param toCharacterId The character ID to remove.
     */
    function removeLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external;

    /////////////////////////////////
    // linking Note
    /////////////////////////////////
    /**
     * @notice Adds a linked note to a linklist.
     * @param tokenId The token ID of linklist.
     * @param toCharacterId The character ID to link.
     * @param toNoteId The note ID to link.
     * @return linkKey The link key.
     */
    function addLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId
    ) external returns (bytes32);

    /**
     * @notice Removes a linked note from a linklist.
     * @param tokenId The token ID of linklist.
     * @param toCharacterId The character ID to remove.
     * @param toNoteId The note ID to remove.
     */
    function removeLinkingNote(uint256 tokenId, uint256 toCharacterId, uint256 toNoteId) external;

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

    /////////////////////////////////
    // linking Address
    /////////////////////////////////
    function addLinkingAddress(uint256 tokenId, address ethAddress) external;

    function removeLinkingAddress(uint256 tokenId, address ethAddress) external;

    /////////////////////////////////
    // linking Any
    /////////////////////////////////
    function addLinkingAnyUri(uint256 tokenId, string memory toUri) external returns (bytes32);

    function removeLinkingAnyUri(uint256 tokenId, string memory toUri) external;

    /////////////////////////////////
    // linking Linklist
    /////////////////////////////////
    function addLinkingLinklistId(uint256 tokenId, uint256 linklistId) external;

    function removeLinkingLinklistId(uint256 tokenId, uint256 linklistId) external;

    function getLinkingCharacterIds(uint256 tokenId) external view returns (uint256[] memory);

    function getLinkingCharacterListLength(uint256 tokenId) external view returns (uint256);

    function getOwnerCharacterId(uint256 tokenId) external view returns (uint256);

    function getLinkingNotes(
        uint256 tokenId
    ) external view returns (DataTypes.NoteStruct[] memory results);

    function getLinkingNote(bytes32 linkKey) external view returns (DataTypes.NoteStruct memory);

    function getLinkingNoteListLength(uint256 tokenId) external view returns (uint256);

    function getLinkingERC721s(
        uint256 tokenId
    ) external view returns (DataTypes.ERC721Struct[] memory results);

    function getLinkingERC721(
        bytes32 linkKey
    ) external view returns (DataTypes.ERC721Struct memory);

    function getLinkingERC721ListLength(uint256 tokenId) external view returns (uint256);

    function getLinkingAddresses(uint256 tokenId) external view returns (address[] memory);

    function getLinkingAddressListLength(uint256 tokenId) external view returns (uint256);

    function getLinkingAnyUris(uint256 tokenId) external view returns (string[] memory results);

    function getLinkingAnyUri(bytes32 linkKey) external view returns (string memory);

    function getLinkingAnyUriKeys(uint256 tokenId) external view returns (bytes32[] memory);

    function getLinkingAnyListLength(uint256 tokenId) external view returns (uint256);

    function getLinkingLinklistIds(uint256 tokenId) external view returns (uint256[] memory);

    function getLinkingLinklistLength(uint256 tokenId) external view returns (uint256);

    /**
     * @dev This function is deprecated..
     */
    function getCurrentTakeOver(uint256 tokenId) external view returns (uint256);

    function getLinkType(uint256 tokenId) external view returns (bytes32);

    // slither-disable-next-line naming-convention
    function Uri(uint256 tokenId) external view returns (string memory); // solhint-disable func-name-mixedcase

    /**
     * @notice Returns the character ID who owns the Linklist NFT.
     * @param tokenId The token ID to check.
     * @return The character ID.
     */
    function characterOwnerOf(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Returns the balance of the character.
     * @param characterId The character ID to check.
     * @return The balance of the character.
     */
    function balanceOf(uint256 characterId) external view returns (uint256);

    /**
     * @notice Returns the total supply of the Linklist NFTs.
     * @return The total supply of the Linklist NFTs.
     */
    function totalSupply() external view returns (uint256);
}
