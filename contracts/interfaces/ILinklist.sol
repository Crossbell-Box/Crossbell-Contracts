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
    function initialize(string calldata name_, string calldata symbol_, address web3Entry_) external;

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
     * @dev Only web3Entry can burn the Linklist NFT.
     * @param tokenId The token ID to burn.
     */
    function burn(uint256 tokenId) external;

    /**
     * @notice Sets URI for a linklist.
     * @dev You can set any URI for your linklist, and the functionality of this URI
     * is undetermined and expandable. One scenario that comes to mind is setting a cover for your liked notes
     * or following list in your bookmarks.
     * @param tokenId The token ID to set URI.
     * @param uri The new URI to set.
     */
    function setUri(uint256 tokenId, string memory uri) external;

    /**
     * @notice Sets the link type of the linklist NFT.
     * @param tokenId The token ID of linklist to set.
     * @param linkType The link type to set.
     */
    function setLinkType(uint256 tokenId, bytes32 linkType) external;

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
    function addLinkingNote(uint256 tokenId, uint256 toCharacterId, uint256 toNoteId) external returns (bytes32);

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
    /**
     * @notice Adds a linked ERC721 to a linklist.
     * @param tokenId The token ID of linklist.
     * @param tokenAddress The address of ERC721 contract.
     * @param erc721TokenId The token ID of ERC721.
     * @return linkKey The link key of ERC721.
     */
    function addLinkingERC721(uint256 tokenId, address tokenAddress, uint256 erc721TokenId)
        external
        returns (bytes32);

    /**
     * @notice Removes a linked ERC721 from a linklist.
     * @param tokenId The token ID of linklist.
     * @param tokenAddress The address of ERC721 contract.
     * @param erc721TokenId The token ID of ERC721.
     */
    function removeLinkingERC721(uint256 tokenId, address tokenAddress, uint256 erc721TokenId) external;

    /////////////////////////////////
    // linking Address
    /////////////////////////////////
    /**
     * @notice Adds a linked address to a linklist.
     * @param tokenId The token ID of linklist.
     * @param ethAddress The address to link.
     */
    function addLinkingAddress(uint256 tokenId, address ethAddress) external;

    /**
     * @notice Removes a linked address from a linklist.
     * @param tokenId The token ID of linklist.
     * @param ethAddress The address to remove.
     */
    function removeLinkingAddress(uint256 tokenId, address ethAddress) external;

    /////////////////////////////////
    // linking Any
    /////////////////////////////////
    /**
     * @notice Adds a linked anyURI to a linklist.
     * @param tokenId The token ID of linklist.
     * @param toUri The anyURI to link.
     * @return linkKey The link key of anyURI.
     */
    function addLinkingAnyUri(uint256 tokenId, string memory toUri) external returns (bytes32);

    /**
     * @notice Removes a linked anyURI from a linklist.
     * @param tokenId The token ID of linklist.
     * @param toUri The anyURI to remove.
     */
    function removeLinkingAnyUri(uint256 tokenId, string memory toUri) external;

    /////////////////////////////////
    // linking Linklist
    /////////////////////////////////
    /**
     * @notice Adds a linked linklist to a linklist.
     * @param tokenId The token ID of linklist.
     * @param linklistId The linklist ID to link.
     */
    function addLinkingLinklistId(uint256 tokenId, uint256 linklistId) external;

    /**
     * @notice Removes a linked linklist from a linklist.
     * @param tokenId The token ID of linklist.
     * @param linklistId The linklist ID to remove.
     */
    function removeLinkingLinklistId(uint256 tokenId, uint256 linklistId) external;

    /**
     * @notice Returns the linked character IDs of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The linked character IDs.
     */
    function getLinkingCharacterIds(uint256 tokenId) external view returns (uint256[] memory);

    /**
     * @notice Returns the length of linked character IDs of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The length of linked character IDs .
     */
    function getLinkingCharacterListLength(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Returns the character ID who owns the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The character ID who owns the linklist NFT.
     */
    function getOwnerCharacterId(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Returns the linked notes of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return results The linked notes.
     */
    function getLinkingNotes(uint256 tokenId) external view returns (DataTypes.NoteStruct[] memory results);

    /**
     * @notice Return the linked note of the linklist NFT by linkKey.
     * @param linkKey The link key of the note.
     * @return The linked note.
     */
    function getLinkingNote(bytes32 linkKey) external view returns (DataTypes.NoteStruct memory);

    /**
     * @notice Returns the length of linked notes of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The length of linked notes.
     */
    function getLinkingNoteListLength(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Returns the linked ERC721s of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return results The linked ERC721s.
     */
    function getLinkingERC721s(uint256 tokenId) external view returns (DataTypes.ERC721Struct[] memory results);

    /**
     * @notice Return the linked ERC721 of the linklist NFT by linkKey.
     * @param linkKey The link key of the ERC721.
     * @return The linked ERC721.
     */
    function getLinkingERC721(bytes32 linkKey) external view returns (DataTypes.ERC721Struct memory);

    /**
     * @notice Returns the length of linked ERC721s of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The length of linked ERC721s.
     */
    function getLinkingERC721ListLength(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Returns the linked addresses of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The linked addresses.
     */
    function getLinkingAddresses(uint256 tokenId) external view returns (address[] memory);

    /**
     * @notice Returns the linked address of the linklist NFT by linkKey.
     * @param tokenId The token ID of linklist to check.
     * @return  The length of linked address.
     */
    function getLinkingAddressListLength(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Returns the linked anyURIs of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return results The linked anyURIs.
     */
    function getLinkingAnyUris(uint256 tokenId) external view returns (string[] memory results);

    /**
     * @notice Return the linked anyURI of the linklist NFT by linkKey.
     * @param linkKey The link key of the anyURI.
     * @return The linked anyURI.
     */
    function getLinkingAnyUri(bytes32 linkKey) external view returns (string memory);

    /**
     * @notice Returns the length of linked anyURIs of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The length of linked anyURIs.
     */
    function getLinkingAnyUriKeys(uint256 tokenId) external view returns (bytes32[] memory);

    /**
     * @notice Returns the length of linked Uris of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The length of linked Uris.
     */
    function getLinkingAnyListLength(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Returns the linked linklists of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The linked linklists.
     */
    function getLinkingLinklistIds(uint256 tokenId) external view returns (uint256[] memory);

    /**
     * @notice Return the length of linked linklist of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The length of linked linklist.
     */
    function getLinkingLinklistLength(uint256 tokenId) external view returns (uint256);

    /**
     * @dev This function is deprecated..
     */
    function getCurrentTakeOver(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Returns the link type of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The link type.
     */
    function getLinkType(uint256 tokenId) external view returns (bytes32);

    /**
     * @notice Returns the URI of the linklist NFT.
     * @param tokenId The token ID of linklist to check.
     * @return The URI of the linklist NFT.
     */
    function Uri(uint256 tokenId) external view returns (string memory); // solhint-disable func-name-mixedcase

    /**
     * @notice Returns the character ID who owns the Linklist NFT.
     * @param tokenId The token ID to check.
     * @return The character ID.
     */
    function characterOwnerOf(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Returns the total supply of the Linklist NFTs.
     * @return The total supply of the Linklist NFTs.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Returns the balance of the character.
     * @param characterId The character ID to check.
     * @return uint256 The balance of the character.
     */
    function balanceOf(uint256 characterId) external view returns (uint256);

    /**
     * @notice Returns the balance of the address.
     * @param account The address to check.
     * @return balance The balance of the address.
     */
    function balanceOf(address account) external view returns (uint256 balance);

    /**
     * @notice Returns the owner of the `tokenId` token.
     * @param tokenId The token ID to check.
     * @return The owner of the `tokenId` token.
     */
    function ownerOf(uint256 tokenId) external view returns (address);
}
