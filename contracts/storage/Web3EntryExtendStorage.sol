// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Web3EntryExtendStorage {
    address internal periphery; // slot 21
    mapping(uint256 => address) internal _operatorByCharacter; // obsoleted slot 22
    address public resolver; // obsoleted slot 23
    mapping(uint256 => EnumerableSet.AddressSet) internal _operatorsByCharacter; //slot 24
}
