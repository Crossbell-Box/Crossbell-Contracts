// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/DataTypes.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Web3EntryStorage {
    address public linkList; // TODO: maybe there is a more elegant way ?

    mapping(uint256 => DataTypes.Profile) internal _profileById;

    mapping(bytes32 => uint256) internal _profileIdByHandleHash;

    mapping(address => uint256) internal _primaryProfileByAddress; // address => profile id

    uint256 internal _profileCounter;
}
