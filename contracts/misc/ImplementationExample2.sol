// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/transparent/ProxyAdmin.sol)

pragma solidity 0.8.10;

import "./ImplementationExample.sol";

contract ImplementationExample2 is ImplementationExample {
    // Increments the stored value by 1
    function increment() public {
        store(retrieve() + 1);
    }
}
