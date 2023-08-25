// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {DataTypes} from "../libraries/DataTypes.sol";

interface IWeb3Entry {
    /**
     * @notice Initializes the Web3Entry.
     * @param name_ The name to set for the web3Entry character NFT.
     * @param symbol_ The symbol to set for the web3Entry character NFT.
     * @param linklist_ The address of linklist contract to set.
     * @param mintNFTImpl_ The address of mintNFTImpl contract to set.
     * @param periphery_ The address of periphery contract to set.
     * @param newbieVilla_ The address of newbieVilla contract to set.
     */
    function initialize(
        string calldata name_,
        string calldata symbol_,
        address linklist_,
        address mintNFTImpl_,
        address periphery_,
        address newbieVilla_
    ) external;

    /**
     * This method creates a character with the given parameters to the given address.
     *
     * @param vars The CreateCharacterData struct containing the following parameters:
     * `to`: The address receiving the character.<br>
     * `handle`: The handle to set for the character.<br>
     * `uri`: The URI to set for the character metadata.<br>
     * `linkModule`: The link module to use, can be the zero address.<br>
     * `linkModuleInitData`: The link module initialization data, if any.<br>
     */
    function createCharacter(
        DataTypes.CreateCharacterData calldata vars
    ) external returns (uint256 characterId);

    /**
     * @notice  Sets new handle for a given character.
     * @dev Owner permission only.
     * @param   characterId  The character id to set new handle for.
     * @param   newHandle  New handle to set.
     */
    function setHandle(uint256 characterId, string calldata newHandle) external;

    /**
     * @notice  Sets a social token for a given character.
     * @dev Owner permission only.
     * @param   characterId  The characterId to set social token for.
     * @param   tokenAddress  Token address to be set.
     */
    function setSocialToken(uint256 characterId, address tokenAddress) external;

    /**
     * @notice  Sets a new URI for a given character.
     * @param   characterId  The characterId to to be set.
     * @param   newUri  New URI to be set.
     */
    function setCharacterUri(uint256 characterId, string calldata newUri) external;

    /**
     * @notice  Sets a given character as primary.
     * @dev Only character owner can call this function.
     * @param   characterId  The character id to to be set.
     */
    function setPrimaryCharacterId(uint256 characterId) external;

    /**
     * @notice Grant an address as an operator and authorize it with custom permissions.
     * @param characterId ID of your character that you want to authorize.
     * @param operator Address to grant operator permissions to.
     * @param permissionBitMap Bitmap used for finer grained operator permissions controls.
     * @dev Every bit in permissionBitMap stands for a corresponding method in Web3Entry. more details in OP.sol.
     */
    function grantOperatorPermissions(
        uint256 characterId,
        address operator,
        uint256 permissionBitMap
    ) external;

    /**
     * @notice Grant an address as an operator and authorize it with custom permissions via signature.
     * @dev Only character owner can call.
     * @param characterId ID of your character that you want to authorize.
     * @param operator Address to grant operator permissions to.
     * @param permissionBitMap Bitmap used for finer grained operator permissions controls.
     * @param signature The EIP712Signature struct containing the character owner's signature.
     * @dev Every bit in permissionBitMap stands for a corresponding method in Web3Entry. more details in OP.sol.
     */
    function grantOperatorPermissionsWithSig(
        uint256 characterId,
        address operator,
        uint256 permissionBitMap,
        DataTypes.EIP712Signature calldata signature
    ) external;

    /**
     * @notice Grant operators allowlist and blocklist roles of a note.
     * @param characterId ID of character that you want to set.
     * @param noteId ID of note that you want to set.
     * @param blocklist blocklist addresses that you want to grant.
     * @param allowlist allowlist addresses that you want to grant.
     */
    function grantOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blocklist,
        address[] calldata allowlist
    ) external;

    /**
     * @notice  Sets a new metadataURI for a given link list.
     * @param   linkListId  The linklist id to set for.
     * @param   uri  The metadata uri to set.
     */
    function setLinklistUri(uint256 linkListId, string calldata uri) external;

    /**
     * @notice Sets a link type for a given linklist.
     * @dev Linklist is the group of all linking objects with the same link type, like "like".
     * Each character can only have one linklist for each link type.
     * It will fail if you try to set a link type which is already set for some linklist owned by the same character.
     * @param linkListId The linklist ID to set for.
     * @param linkType The link type to set.
     */
    function setLinklistType(uint256 linkListId, bytes32 linkType) external;

    /**
     * @notice Links an address with the given parameters.
     * @param vars The linkAddressData struct containing the linking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a link action.<br>
     * `ethAddress`: The address to be linked.<br>
     * `linkType`: The link type, like "like", which is a bytes32 format.<br>
     * `data`: The data passed to the link module to use, if any.<br>
     */
    function linkAddress(DataTypes.linkAddressData calldata vars) external;

    /**
     * @notice Unlinks an address with the given parameters.
     * @param vars The unlinkAddressData struct containing the unlinking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a unlink action.<br>
     * `ethAddress`: The address to be unlinked.<br>
     * `linkType`: The link type, like "like", which is a bytes32 format.<br>
     */
    function unlinkAddress(DataTypes.unlinkAddressData calldata vars) external;

    /**
     * @notice Links a character with the given parameters.
     * @param vars The linkCharacterData struct containing the linking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a link action.<br>
     * `toCharacterId`: The character ID to be linked.<br>
     * `linkType`: The link type, like "follow", which is a bytes32 format.<br>
     * `data`: The data passed to the link module to use, if any.<br>
     */
    function linkCharacter(DataTypes.linkCharacterData calldata vars) external;

    /**
     * @notice Unlinks a character with the given parameters.
     * @param vars The unlinkCharacterData struct containing the unlinking parameters:
     * `fromCharacterId`: The character ID to sponsor a unlink action.<br>
     * `toCharacterId`: The character ID to be unlinked.<br>
     * `linkType`: The link type, like "follow", which is a bytes32 format.<br>
     */
    function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars) external;

    /**
     * @notice Create a character and then link it.
     * @param vars The createThenLinkCharacterData struct containing the parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a link action.<br>
     * `to`: The address to receive the new character nft.<br>
     * `linkType`: The link type, like "follow", which is a bytes32 format.<br>
     */
    function createThenLinkCharacter(
        DataTypes.createThenLinkCharacterData calldata vars
    ) external returns (uint256 characterId);

    /**
     * @notice Links a note with the given parameters.
     * @param vars The linkNoteData struct containing the linking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a link action.<br>
     * `toCharacterId`: The character ID of note to be linked.<br>
     * `toNoteId`: The note ID of note to be linked.<br>
     * `linkType`: The link type, like "like", which is a bytes32 format.<br>
     * `data`: The data passed to the link module to use, if any.<br>
     */
    function linkNote(DataTypes.linkNoteData calldata vars) external;

    /**
     * @notice UnLinks a note with the given parameters.
     * @param vars The unlinkNoteData struct containing the unlinking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a unlink action.<br>
     * `toCharacterId`: The character ID of note to be unlinked.<br>
     * `toNoteId`: The note ID of note to be unlinked.<br>
     * `linkType`: The link type, like "like", which is a bytes32 format.<br>
     */
    function unlinkNote(DataTypes.unlinkNoteData calldata vars) external;

    /**
     * @notice Links an ERC721 with the given parameters.
     * @param vars The linkERC721Data struct containing the linking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a link action.<br>
     * `tokenAddress`: The token address of ERC721 to be linked.<br>
     * `tokenId`: The token ID of ERC721 to be linked.<br>
     * `linkType`: The link type, like "like", which is a bytes32 format.<br>
     * `data`: The data passed to the link module to use, if any.<br>
     */
    function linkERC721(DataTypes.linkERC721Data calldata vars) external;

    /**
     * @notice Unlinks an ERC721 with the given parameters.
     * @param vars The unlinkERC721Data struct containing the unlinking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a unlink action.<br>
     * `tokenAddress`: The token address of ERC721 to be unlinked.<br>
     * `tokenId`: The token ID of ERC721 to be unlinked.<br>
     * `linkType`: The link type, like "like", which is a bytes32 format.<br>
     */
    function unlinkERC721(DataTypes.unlinkERC721Data calldata vars) external;

    /**
     * @notice Links any uri with the given parameters.
     * @param vars The linkAnyUriData struct containing the linking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a link action.<br>
     * `toUri`: The uri to be linked.<br>
     * `linkType`: The link type, like "like", which is a bytes32 format.<br>
     * `data`: The data passed to the link module to use, if any.<br>
     */
    function linkAnyUri(DataTypes.linkAnyUriData calldata vars) external;

    /**
     * @notice Unlinks any uri with the given parameters.
     * @param vars The unlinkAnyUriData struct containing the unlinking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a unlink action.<br>
     * `toUri`: The uri to be unlinked.<br>
     * `linkType`: The link type, like "like", which is a bytes32 format.<br>
     */
    function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars) external;

    /**
     * @notice Links a linklist with the given parameters.
     * @param vars The linkLinklistData struct containing the linking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a link action.<br>
     * `toLinkListId`: The linklist ID to be linked.<br>
     * `linkType`: The link type, like "like", which is a bytes32 format.<br>
     * `data`: The data passed to the link module to use, if any.<br>
     */
    function linkLinklist(DataTypes.linkLinklistData calldata vars) external;

    /**
     * @notice Unlinks a linklist with the given parameters.
     * @param vars The unlinkLinklistData struct containing the unlinking parameters:<br>
     * `fromCharacterId`: The character ID to sponsor a unlink action.<br>
     * `toLinkListId`: The linklist ID to be unlinked.<br>
     * `linkType`: The link type, like "like", which is a bytes32 format.<br>
     */
    function unlinkLinklist(DataTypes.unlinkLinklistData calldata vars) external;

    /**
     * @notice Sets a link module for a given character.
     * @param vars The setLinkModule4CharacterData struct containing the parameters:<br>
     * `characterId`: The character ID to set for.<br>
     * `linkModule`: The address of link module contract to set.<br>
     * `linkModuleInitData`: The data passed to the link module to use, if any.<br>
     */
    function setLinkModule4Character(DataTypes.setLinkModule4CharacterData calldata vars) external;

    /**
     * @notice Sets a link module for a given note.
     * @param vars The setLinkModule4NoteData struct containing the parameters:<br>
     * `characterId`: The character ID to set for.<br>
     * `noteId`: The note ID to set for.<br>
     * `linkModule`: The address of link module contract to set.<br>
     * `linkModuleInitData`: The data passed to the link module to use, if any.<br>
     */
    function setLinkModule4Note(DataTypes.setLinkModule4NoteData calldata vars) external;

    /**
     * @notice Mints an nft with the given note.
     * @param vars The MintNoteData struct containing the minting parameters:<br>
     * `characterId`: The character ID of the note.<br>
     * `noteId`: The note ID of the note.<br>
     * `to`: The address to receive the minted nft.<br>
     * `data`: The data passed to the mint module to use, if any.<br>
     */
    function mintNote(DataTypes.MintNoteData calldata vars) external returns (uint256 tokenId);

    /**
     * @notice Sets a mint module for the given note.
     * @param vars The setMintModule4NoteData struct containing the setting parameters:<br>
     * `characterId`: The character ID of the note.<br>
     * `noteId`: The note ID of the note.<br>
     * `mintModule`: The address of mint module to set.<br>
     * `mintModuleInitData`: The data passed to the mint module to init, if any.<br>
     */
    function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external;

    /**
     * @notice Posts a note with the given parameters.
     * @param vars The postNoteData struct containing the posting parameters:<br>
     * `characterId`: The character ID to post to.<br>
     * `contentUri`: The uri to set for the new post.<br>
     * `linkModule`: The address of link module to set for the new post.<br>
     * `linkModuleInitData`: The data passed to the link module to init, if any.<br>
     * `mintModule`: The address of mint module to set for the new post.<br>
     * `mintModuleInitData`: The data passed to the mint module to init, if any.<br>
     */
    function postNote(DataTypes.PostNoteData calldata vars) external returns (uint256 noteId);

    /**
     * @notice  Set URI for a note.
     * @param   characterId  The character ID of the note owner.
     * @param   noteId  The ID of the note to set.
     * @param   newUri  The new URI.
     */
    function setNoteUri(uint256 characterId, uint256 noteId, string calldata newUri) external;

    /**
     * @notice  Lock a note and put it into a immutable state where no modifications are 
     allowed. Locked notes are usually assumed as final versions.
     * @param   characterId  The character ID of the note owner.
     * @param   noteId  The ID of the note to lock.
     */
    function lockNote(uint256 characterId, uint256 noteId) external;

    /**
     * @notice  Delete a note.
     * @dev     Deleting a note doesn't essentially mean that the txs or contents are being removed due to the
     * immutability of blockchain itself, but the deleted notes will be tagged as `deleted` after calling `deleteNote`.
     * @param   characterId  The character ID of the note owner.
     * @param   noteId  The ID of the note to delete.
     */
    function deleteNote(uint256 characterId, uint256 noteId) external;

    /**
     * @notice Posts a note for a given character.
     * @param vars The postNoteData struct containing the posting parameters:<br>
     * `characterId`: The character ID to post to.<br>
     * `contentUri`: The uri to set for the new post.<br>
     * `linkModule`: The address of link module to set for the new post.<br>
     * `linkModuleInitData`: The data passed to the link module to init, if any.<br>
     * `mintModule`: The address of mint module to set for the new post.<br>
     * `mintModuleInitData`: The data passed to the mint module to init, if any.<br>
     * @param toCharacterId The target character ID.
     * @return noteId The note ID of the new post.
     */
    function postNote4Character(
        DataTypes.PostNoteData calldata vars,
        uint256 toCharacterId
    ) external returns (uint256 noteId);

    /**
     * @notice Posts a note for a given address.
     * @param vars The postNoteData struct containing the posting parameters:<br>
     * `characterId`: The character ID to post to.<br>
     * `contentUri`: The uri to set for the new post.<br>
     * `linkModule`: The address of link module to set for the new post.<br>
     * `linkModuleInitData`: The data passed to the link module to init, if any.<br>
     * `mintModule`: The address of mint module to set for the new post.<br>
     * `mintModuleInitData`: The data passed to the mint module to init, if any.<br>
     * @param ethAddress The target address.
     * @return noteId The note ID of the new post.
     */
    function postNote4Address(
        DataTypes.PostNoteData calldata vars,
        address ethAddress
    ) external returns (uint256 noteId);

    /**
     * @notice Posts a note for a given linklist.
     * @param vars The postNoteData struct containing the posting parameters:<br>
     * `characterId`: The character ID to post to.<br>
     * `contentUri`: The uri to set for the new post.<br>
     * `linkModule`: The address of link module to set for the new post.<br>
     * `linkModuleInitData`: The data passed to the link module to init, if any.<br>
     * `mintModule`: The address of mint module to set for the new post.<br>
     * `mintModuleInitData`: The data passed to the mint module to init, if any.<br>
     * @param toLinklistId The target linklist.
     * @return noteId The note ID of the new post.
     */
    function postNote4Linklist(
        DataTypes.PostNoteData calldata vars,
        uint256 toLinklistId
    ) external returns (uint256 noteId);

    /**
     * @notice Posts a note for a given note.
     * @param vars The postNoteData struct containing the posting parameters:<br>
     * `characterId`: The character ID to post to.<br>
     * `contentUri`: The uri to set for the new post.<br>
     * `linkModule`: The address of link module to set for the new post.<br>
     * `linkModuleInitData`: The data passed to the link module to init, if any.<br>
     * `mintModule`: The address of mint module to set for the new post.<br>
     * `mintModuleInitData`: The data passed to the mint module to init, if any.<br>
     * @param note The target note struct containing the parameters:<br>
     * `characterId`: The character ID of target note.<br>
     * `noteId`: The note ID of target note.
     * @return noteId The note ID of the new post.
     */
    function postNote4Note(
        DataTypes.PostNoteData calldata vars,
        DataTypes.NoteStruct calldata note
    ) external returns (uint256 noteId);

    /**
     * @notice Posts a note for a given ERC721.
     * @param vars The postNoteData struct containing the posting parameters:<br>
     * `characterId`: The character ID to post to.<br>
     * `contentUri`: The uri to set for the new post.<br>
     * `linkModule`: The address of link module to set for the new post.<br>
     * `linkModuleInitData`: The data passed to the link module to init, if any.<br>
     * `mintModule`: The address of mint module to set for the new post.<br>
     * `mintModuleInitData`: The data passed to the mint module to init, if any.<br>
     * @param erc721 The target ERC721 struct containing the parameters:<br>
     * `tokenAddress`: The token address of target ERC721.<br>
     * `erc721TokenId`: The token ID of target ERC721.
     * @return noteId The note ID of the new post.
     */
    function postNote4ERC721(
        DataTypes.PostNoteData calldata vars,
        DataTypes.ERC721Struct calldata erc721
    ) external returns (uint256 noteId);

    /**
     * @notice Posts a note for a given uri.
     * @param vars The postNoteData struct containing the posting parameters:<br>
     * `characterId`: The character ID to post to.<br>
     * `contentUri`: The uri to set for the new post.<br>
     * `linkModule`: The address of link module to set for the new post.<br>
     * `linkModuleInitData`: The data passed to the link module to init, if any.<br>
     * `mintModule`: The address of mint module to set for the new post.<br>
     * `mintModuleInitData`: The data passed to the mint module to init, if any.<br>
     * @param uri The target uri(could be an url link).
     * @return noteId The note ID of the new post.
     */
    function postNote4AnyUri(
        DataTypes.PostNoteData calldata vars,
        string calldata uri
    ) external returns (uint256 noteId);

    /**
     * @notice Burns a linklist NFT.
     * @dev It will burn the linklist NFT and remove the links from a character.
     * @param linklistId The linklist ID to burn.
     */
    function burnLinklist(uint256 linklistId) external;

    /**
     * @notice Get operator list of a character. This operator list has only a sole purpose, which is
     * keeping records of keys of `operatorsPermissionBitMap`. Thus, addresses queried by this function
     * not always have operator permissions. Keep in mind don't use this function to check
     * authorizations!!!
     * @param characterId ID of your character that you want to check.
     * @return All keys of operatorsPermission4NoteBitMap.
     */
    function getOperators(uint256 characterId) external view returns (address[] memory);

    /**
     * @notice Get permission bitmap of an operator.
     * @param characterId ID of character that you want to check.
     * @param operator Address to grant operator permissions to.
     * @return Permission bitmap of this operator.
     */
    function getOperatorPermissions(
        uint256 characterId,
        address operator
    ) external view returns (uint256);

    /**
     * @notice Get operators blocklist and allowlist for a note.
     * @param characterId ID of character to query.
     * @param noteId ID of note to query.
     */
    function getOperators4Note(
        uint256 characterId,
        uint256 noteId
    ) external view returns (address[] memory blocklist, address[] memory allowlist);

    /**
     * @notice Query if a operator has permission for a note.
     * @param characterId ID of character that you want to query.
     * @param noteId ID of note that you want to query.
     * @param operator Address to query.
     * @return true if Operator has permission for a note, otherwise false.
     */
    function isOperatorAllowedForNote(
        uint256 characterId,
        uint256 noteId,
        address operator
    ) external view returns (bool);

    /**
     * @notice Returns primary character for a given account.
     * @param account The address to query.
     * @return uint256 The primary character ID, which will be 0 if not mapped.
     */
    function getPrimaryCharacterId(address account) external view returns (uint256);

    /**
     * @notice Returns whether or not a character is primary character.
     * @param characterId The character ID to query.
     * @return bool True if the character is primary, false otherwise.
     */
    function isPrimaryCharacter(uint256 characterId) external view returns (bool);

    /**
     * @notice Returns the full character struct associated with a given character token ID.
     * @param characterId The token ID of the character to query.
     * @return The full character struct of given character.
     */
    function getCharacter(uint256 characterId) external view returns (DataTypes.Character memory);

    /**
     * @notice Returns the full character struct associated with a given character handle.
     * @param handle The handle of the character to query.
     * @return The full character struct of given character.
     */
    function getCharacterByHandle(
        string calldata handle
    ) external view returns (DataTypes.Character memory);

    /**
     * @notice Returns the handle of character with a given character.
     * @param characterId The token ID of the character to query.
     * @return The handle of given character.
     */
    function getHandle(uint256 characterId) external view returns (string memory);

    /**
     * @notice Returns the uri of character with a given character.
     * @param characterId The token ID of the character to query.
     * @return The uri of given character.
     */
    function getCharacterUri(uint256 characterId) external view returns (string memory);

    /**
     * @notice Returns the full note struct associated with a given note.
     * @param characterId The token ID of the character to query.
     * @param noteId The token ID of the note to query.
     * @return The full note struct of given note.
     */
    function getNote(
        uint256 characterId,
        uint256 noteId
    ) external view returns (DataTypes.Note memory);

    /**
     * @notice Returns the uri of linklist with a given linklist.
     * @param tokenId The token ID of the linklist to query.
     * @return string The uri of given linklist.
     */
    function getLinklistUri(uint256 tokenId) external view returns (string memory);

    /**
     * @notice Returns the token ID of linklist with a given character and linkType.
     * @param characterId The token ID of the character to query.
     * @param linkType The linkType.
     * @return The token ID of linklist.
     */
    function getLinklistId(uint256 characterId, bytes32 linkType) external view returns (uint256);

    /**
     * @notice Returns the linkType of linklist with a given linklist.
     * @param linkListId The token ID of the linklist to query.
     * @return bytes32 The linkType of given linklist.
     */
    function getLinklistType(uint256 linkListId) external view returns (bytes32);

    /**
     * @notice Returns the address of linklist contract.
     * @return The address of linklist contract.
     */
    function getLinklistContract() external view returns (address);

    /**
     * @notice Returns the domain separator for this NFT contract.
     * @return bytes32 The domain separator.
     */
    function getDomainSeparator() external view returns (bytes32);

    /**
     * @notice Returns the current nonce for `owner`. This value must be included
     * whenever a signature is generated by `grantOperatorPermissionsWithSig`.
     * Every successful call to `grantOperatorPermissionsWithSig` increases `owner`'s nonce by one. This
     * prevents a signature from being used multiple times.
     * @param owner The owner address to query.
     * @return uint256 The current nonce for `owner`.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @notice Returns the revision number of web3Entry contract.
     * @return The the revision number of web3Entry contract.
     */
    function getRevision() external pure returns (uint256);
}
