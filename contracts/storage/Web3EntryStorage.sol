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

    // profileId =>  (linkType => linklistId)
    mapping(uint256 => mapping(bytes32 => uint256)) internal _attachedLinklists;

    // profileId => noteId => Note
    mapping(uint256 => mapping(uint256 => DataTypes.Note)) internal _noteByIdByProfile;

    /////////////////////////////////
    // link modules
    /////////////////////////////////

    // tokenId => linkModule4Linklist
    mapping(uint256 => address) internal _linkModules4Linklist;

    // tokenAddress => tokenId => linkModule4ERC721
    mapping(address => mapping(uint256 => address)) internal _linkModules4ERC721;

    // address => linkModule4Address
    mapping(address => address) internal _linkModules4Address;

    uint256 internal _profileCounter;
    // LinkList NFT token contract
    address internal _linklist;
    address internal MINT_NFT_IMPL;
}
