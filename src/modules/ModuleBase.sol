// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

abstract contract ModuleBase {
    address public immutable Web3Entry;

    modifier onlyWeb3Entry() {
        require(msg.sender == Web3Entry, "NotWeb3Entry");
        _;
    }

    constructor(address web3Entry) {
        require(web3Entry != address(0), "InvalidWeb3Entry");
        Web3Entry = web3Entry;
    }
}
