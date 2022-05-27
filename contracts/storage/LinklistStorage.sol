// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/DataTypes.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract LinklistStorage {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    address public Web3Entry; // slot 10

    // tokenId => linkType
    mapping(uint256 => bytes32) internal linkTypes;

    // tokenId =>  profileIds
    mapping(uint256 => EnumerableSet.UintSet) internal linkingProfileList;
    // tokenId => external addresses
    mapping(uint256 => EnumerableSet.AddressSet) internal linkingAddressList;
    // tokenId =>  LinklistId
    mapping(uint256 => EnumerableSet.UintSet) internal linkingLinklists;

    // tokenId => linkKeys
    mapping(uint256 => EnumerableSet.Bytes32Set) internal linkKeysList; // this slot is not used
    // linkKey => linking ERC721
    mapping(bytes32 => DataTypes.ERC721Struct) internal linkingERC721List;
    // linkKey => linking Note
    mapping(bytes32 => DataTypes.NoteStruct) internal linkNoteList;
    // linkKey => linking ProfileLink
    mapping(bytes32 => DataTypes.ProfileLinkStruct) internal linkingProfileLinkList;
    // linkKey => linking Any string
    mapping(bytes32 => string) internal linkingAnylist;

    // tokenId => profileId
    mapping(uint256 => uint256) internal currentTakeOver;
    mapping(uint256 => string) internal _uris; // tokenId => tokenURI

    // linkKey sets
    // tokenId => linkKeys
    mapping(uint256 => EnumerableSet.Bytes32Set) internal linkingERC721Keys;
    mapping(uint256 => EnumerableSet.Bytes32Set) internal linkNoteKeys;
    mapping(uint256 => EnumerableSet.Bytes32Set) internal linkingProfileLinkKeys;
    mapping(uint256 => EnumerableSet.Bytes32Set) internal linkingAnyKeys;
}
