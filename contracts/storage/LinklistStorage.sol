// SPDX-License-Identifier: MIT
// solhint-disable max-states-count
pragma solidity 0.8.18;

import {DataTypes} from "../libraries/DataTypes.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract LinklistStorage {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    // solhint-disable var-name-mixedcase
    address public Web3Entry; // slot 10

    // tokenId => linkType
    mapping(uint256 => bytes32) internal _linkTypes;

    // tokenId =>  characterIds
    mapping(uint256 => EnumerableSet.UintSet) internal _linkingCharacters;
    // tokenId => external addresses
    mapping(uint256 => EnumerableSet.AddressSet) internal _linkingAddresses;
    // tokenId =>  LinklistId
    mapping(uint256 => EnumerableSet.UintSet) internal _linkingLinklists;

    // tokenId => linkKeys
    // slither-disable-next-line unused-state
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkKeys; // unused slot
    // linkKey => linking ERC721
    mapping(bytes32 => DataTypes.ERC721Struct) internal _linkingERC721s;
    // linkKey => linking Note
    mapping(bytes32 => DataTypes.NoteStruct) internal _linkNotes;
    // linkKey => linking CharacterLink
    mapping(bytes32 => DataTypes.CharacterLinkStruct) internal _linkingCharacterLinks;
    // linkKey => linking Any string
    mapping(bytes32 => string) internal _linkingAnys;

    // tokenId => characterId
    mapping(uint256 => uint256) internal _currentTakeOver; //unused slot
    mapping(uint256 => string) internal _uris; // tokenId => tokenURI

    // linkKey sets
    // tokenId => linkKeys
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkingERC721Keys;
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkNoteKeys;
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkingCharacterLinkKeys;
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkingAnyKeys;
}
