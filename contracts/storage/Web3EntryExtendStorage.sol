// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

contract Web3EntryExtendStorage {
    address internal periphery;
    mapping(uint256 => address) internal _dispatcherByProfile;
}
