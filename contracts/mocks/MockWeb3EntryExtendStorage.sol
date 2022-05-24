// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

contract MockWeb3EntryExtendStorage {
    address internal periphery;
    mapping(uint256 => address) internal _dispatcherByProfile;
    address public resolver;
    uint256 internal _additionalValue;
}
