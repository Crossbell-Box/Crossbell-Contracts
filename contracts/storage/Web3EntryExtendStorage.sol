// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "../libraries/DataTypes.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Web3EntryExtendStorage {
    address internal _periphery; // slot 21
    mapping(uint256 => address) internal _operatorByCharacter; // obsoleted slot 22
    address public resolver; // obsoleted slot 23
    mapping(uint256 => EnumerableSet.AddressSet) internal _operatorsByCharacter; //slot 24
    // characterId => operator => permissionsBitMap
    mapping(uint256 => mapping(address => uint256)) internal _operatorsPermissionBitMap; // slot 25
    // characterId => noteId => Operators4Note
    // only for set note uri
    mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) internal _operators4Note; // slot 26

    address internal _newbieVilla;
}
