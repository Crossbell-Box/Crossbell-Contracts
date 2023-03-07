// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "../libraries/DataTypes.sol";

interface IWeb3Entry {
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
     * @dev Owner permission only.
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
     * @notice  Sets a new metadataURI for a given link list..
     * @param   linkListId  The linklist id to set for.
     * @param   uri  The metadata uri to set.
     */
    function setLinklistUri(uint256 linkListId, string calldata uri) external;

    function linkAddress(DataTypes.linkAddressData calldata vars) external;

    function unlinkAddress(DataTypes.unlinkAddressData calldata vars) external;

    function linkCharacter(DataTypes.linkCharacterData calldata vars) external;

    function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars) external;

    function createThenLinkCharacter(
        DataTypes.createThenLinkCharacterData calldata vars
    ) external returns (uint256 characterId);

    function linkNote(DataTypes.linkNoteData calldata vars) external;

    function unlinkNote(DataTypes.unlinkNoteData calldata vars) external;

    function linkERC721(DataTypes.linkERC721Data calldata vars) external;

    function unlinkERC721(DataTypes.unlinkERC721Data calldata vars) external;

    function linkAnyUri(DataTypes.linkAnyUriData calldata vars) external;

    function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars) external;

    /*
    function linkCharacterLink(
        uint256 fromCharacterId,
        DataTypes.CharacterLinkStruct calldata linkData,
        bytes32 linkType
    ) external;

    function unlinkCharacterLink(
        uint256 fromCharacterId,
        DataTypes.CharacterLinkStruct calldata linkData,
        bytes32 linkType
    ) external;
    */

    function linkLinklist(DataTypes.linkLinklistData calldata vars) external;

    function unlinkLinklist(DataTypes.unlinkLinklistData calldata vars) external;

    /*
     * These functions are temporarily commented out, in order to limit the contract code size within 24K.
     * These functions will be restored when necessary in the future.
     */
    //    function setLinkModule4Character(DataTypes.setLinkModule4CharacterData calldata vars) external;
    //    function setLinkModule4Note(DataTypes.setLinkModule4NoteData calldata vars) external;
    //    function setLinkModule4ERC721(DataTypes.setLinkModule4ERC721Data calldata vars) external;

    function setLinkModule4Linklist(DataTypes.setLinkModule4LinklistData calldata vars) external;

    /**
     * @notice Set linkModule for an address.
     * @dev Operators can't setLinkModule4Address, because this linkModule is for 
     addresses and is irrelevant to characters.
     */
    function setLinkModule4Address(DataTypes.setLinkModule4AddressData calldata vars) external;

    function mintNote(DataTypes.MintNoteData calldata vars) external returns (uint256 tokenId);

    function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external;

    function postNote(
        DataTypes.PostNoteData calldata postNoteData
    ) external returns (uint256 noteId);

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
      immutability of blockchain itself, but the deleted notes will be tagged as `deleted` after calling `deleteNote`.
     * @param   characterId  The character ID of the note owner.
     * @param   noteId  The ID of the note to delete.
     */
    function deleteNote(uint256 characterId, uint256 noteId) external;

    function postNote4Character(
        DataTypes.PostNoteData calldata vars,
        uint256 toCharacterId
    ) external returns (uint256);

    function postNote4Address(
        DataTypes.PostNoteData calldata vars,
        address ethAddress
    ) external returns (uint256);

    function postNote4Linklist(
        DataTypes.PostNoteData calldata vars,
        uint256 toLinklistId
    ) external returns (uint256);

    function postNote4Note(
        DataTypes.PostNoteData calldata vars,
        DataTypes.NoteStruct calldata note
    ) external returns (uint256);

    function postNote4ERC721(
        DataTypes.PostNoteData calldata vars,
        DataTypes.ERC721Struct calldata erc721
    ) external returns (uint256);

    function postNote4AnyUri(
        DataTypes.PostNoteData calldata vars,
        string calldata uri
    ) external returns (uint256);

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

    function getPrimaryCharacterId(address account) external view returns (uint256);

    function isPrimaryCharacter(uint256 characterId) external view returns (bool);

    function getCharacter(uint256 characterId) external view returns (DataTypes.Character memory);

    function getCharacterByHandle(
        string calldata handle
    ) external view returns (DataTypes.Character memory);

    function getHandle(uint256 characterId) external view returns (string memory);

    function getCharacterUri(uint256 characterId) external view returns (string memory);

    function getNote(
        uint256 characterId,
        uint256 noteId
    ) external view returns (DataTypes.Note memory);

    function getLinkModule4Address(address account) external view returns (address);

    function getLinkModule4Linklist(uint256 tokenId) external view returns (address);

    function getLinkModule4ERC721(
        address tokenAddress,
        uint256 tokenId
    ) external view returns (address);

    function getLinklistUri(uint256 tokenId) external view returns (string memory);

    function getLinklistId(uint256 characterId, bytes32 linkType) external view returns (uint256);

    function getLinklistType(uint256 linkListId) external view returns (bytes32);

    function getLinklistContract() external view returns (address);

    function getRevision() external pure returns (uint256);
}
