// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Web3EntryExtendStorage {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    address internal periphery; // slot 21
    mapping(uint256 => address) internal _operatorByCharacter;
    address public resolver;
    mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkTypesByCharacter;
}
