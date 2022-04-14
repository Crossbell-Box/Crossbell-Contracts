// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/DataTypes.sol";

contract Web3EntryStorage {
    // profileId => Profile
    mapping(uint256 => DataTypes.Profile) internal _profileById;
    // handleHash => profileId
    mapping(bytes32 => uint256) internal _profileIdByHandleHash;
    // address => profileId
    mapping(address => uint256) internal _primaryProfileByAddress;
    uint256 internal _profileCounter;

    // LinkList NFT token contract
    address public linkList;
    // profileId => LinkListId
    mapping(uint256 => uint256) internal _primaryLinkListByProfileId;

    // profileId => noteId => Note
    mapping(uint256 => mapping(uint256 => DataTypes.Note))
        internal _noteByIdByProfile;
}
