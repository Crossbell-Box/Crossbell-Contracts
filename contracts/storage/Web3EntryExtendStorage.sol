// SPDX-License-Identifier: MIT
// slither-disable-start naming-convention
pragma solidity 0.8.16;

import {DataTypes} from "../libraries/DataTypes.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Web3EntryExtendStorage {
    address internal _periphery; // slot 21
    // slither-disable-next-line unused-state
    mapping(uint256 => address) internal _operatorByCharacter; // unused slot 22
    // slither-disable-next-line constable-states
    address public resolver; // unused slot 23
    mapping(uint256 => EnumerableSet.AddressSet) internal _operatorsByCharacter; //slot 24
    // characterId => operator => permissionsBitMap
    mapping(uint256 => mapping(address => uint256)) internal _operatorsPermissionBitMap; // slot 25
    // characterId => noteId => Operators4Note
    // only for set note uri
    mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) internal _operators4Note; // slot 26

    address internal _newbieVilla; // address of newbieVilla contract

    mapping(address => uint256) internal _sigNonces; // for replay protection // slot 28
}
// slither-disable-end naming-convention
