// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/transparent/ProxyAdmin.sol)

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

pragma solidity 0.8.10;

contract UpgradeV1 is Initializable {
    uint256 public initialValue;
    uint256 private value;

    function initialize(uint256 _initialValue) public initializer {
        initialValue = _initialValue;
        store(initialValue);
    }

    // function initialize() public {

    // }

    // Emitted when the stored value changes
    event ValueChanged(uint256 newValue);

    // Stores a new value in the contract
    function store(uint256 newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }

    // Reads the last stored value
    function retrieve() public view returns (uint256) {
        return value;
    }
}
