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

    ////////////////////////////////////////////////////////
    ///     EXTERNAL  FUNCTIONS
    ////////////////////////////////////////////////////////

    function createCharacter(
        DataTypes.CreateCharacterData calldata vars
    ) external returns (uint256 characterId);

    function setHandle(uint256 characterId, string calldata newHandle) external;

    function setSocialToken(uint256 characterId, address tokenAddress) external;

    function setCharacterUri(uint256 characterId, string calldata newUri) external;

    function setPrimaryCharacterId(uint256 characterId) external;

    function grantOperatorPermissions(
        uint256 characterId,
        address operator,
        uint256 permissionBitMap
    ) external;

    function grantOperators4Note(
        uint256 characterId,
        uint256 noteId,
        address[] calldata blocklist,
        address[] calldata allowlist
    ) external;

    function setLinklistUri(uint256 linkListId, string calldata uri) external;

    function linkAddress(DataTypes.linkAddressData calldata vars) external;

    function unlinkAddress(DataTypes.unlinkAddressData calldata vars) external;

    function linkCharacter(DataTypes.linkCharacterData calldata vars) external;

    function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars) external;

    function createThenLinkCharacter(DataTypes.createThenLinkCharacterData calldata vars) external;

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

    function setLinkModule4Address(DataTypes.setLinkModule4AddressData calldata vars) external;

    function mintNote(DataTypes.MintNoteData calldata vars) external returns (uint256 tokenId);

    function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external;

    function postNote(
        DataTypes.PostNoteData calldata postNoteData
    ) external returns (uint256 noteId);

    function setNoteUri(uint256 characterId, uint256 noteId, string calldata newUri) external;

    function lockNote(uint256 characterId, uint256 noteId) external;

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

    ////////////////////////////////////////////////////////
    ///      VIEW FUNCTIONS
    ////////////////////////////////////////////////////////
    function getOperators(uint256 characterId) external view returns (address[] memory);

    function getOperatorPermissions(
        uint256 characterId,
        address operator
    ) external view returns (uint256);

    function getOperators4Note(
        uint256 characterId,
        uint256 noteId
    ) external view returns (address[] memory blocklist, address[] memory allowlist);

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
