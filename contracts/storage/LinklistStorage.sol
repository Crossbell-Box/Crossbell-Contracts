// SPDX-License-Identifier: MIT
// solhint-disable max-states-count
pragma solidity 0.8.16;

import "../libraries/DataTypes.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract LinklistStorage {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    // solhint-disable var-name-mixedcase
    address public Web3Entry; // slot 10

    // linklistId => linkType
    mapping(uint256 => bytes32) internal _linkTypes;

    // linklistId =>  characterIds
    mapping(uint256 => EnumerableSet.UintSet) internal _linkingCharacters;
    // linklistId => external addresses
    mapping(uint256 => EnumerableSet.AddressSet) internal _linkingAddresses;
    // linklistId =>  LinklistId
    mapping(uint256 => EnumerableSet.UintSet) internal _linkingLinklists;

    // linklistId => linkKeys
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkKeys; // this slot is not used
    // linkKey => linking ERC721
    mapping(bytes32 => DataTypes.ERC721Struct) internal _linkingERC721s;
    // linkKey => linking Note
    mapping(bytes32 => DataTypes.NoteStruct) internal _linkNotes;
    // linkKey => linking CharacterLink
    mapping(bytes32 => DataTypes.CharacterLinkStruct) internal _linkingCharacterLinks;
    // linkKey => linking Any string
    mapping(bytes32 => string) internal _linkingAnys;

    // linklistId => characterId
    mapping(uint256 => uint256) internal _currentTakeOver; // this slot is not used
    mapping(uint256 => string) internal _uris; // linklistId => tokenURI

    // linkKey sets
    // linklistId => linkKeys
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkingERC721Keys;
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkNoteKeys;
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkingCharacterLinkKeys;
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkingAnyKeys;

    // linklist tags
    // linklistId => characterId => tags
    mapping(uint256 => mapping(uint256 => EnumerableSet.Bytes32Set)) internal _linkedCharacterTags;
    // linklistId => linkKey => tags
    mapping(uint256 => mapping(bytes32 => EnumerableSet.Bytes32Set)) internal _linkedNoteTags;
    // linklistId => linkKey => tags
    mapping(uint256 => mapping(bytes32 => EnumerableSet.Bytes32Set))
        internal _linkedCharacterLinkTags;
    // linklistId => linkKey => tags
    mapping(uint256 => mapping(bytes32 => EnumerableSet.Bytes32Set)) internal _linkedERC721Tags;
    // linklistId => address => tags
    mapping(uint256 => mapping(address => EnumerableSet.Bytes32Set)) internal _linkedAdressTags;
    // linklistId => address => tags
    mapping(uint256 => mapping(bytes32 => EnumerableSet.Bytes32Set)) internal _linkedUriTags;
    // linklistId => linklistId => tags
    mapping(uint256 => mapping(uint256 => EnumerableSet.Bytes32Set)) internal _linkedLinklistTags;
}
