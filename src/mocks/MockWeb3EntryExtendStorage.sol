// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

contract MockWeb3EntryExtendStorage {
    address internal periphery; // slot 21
    mapping(uint256 => address) internal _operatorByCharacter;
    address public resolver;
    uint256 internal _additionalValue;
}
