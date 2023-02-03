// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

abstract contract ModuleBase {
    address public immutable web3Entry;

    modifier onlyWeb3Entry() {
        require(msg.sender == web3Entry, "NotWeb3Entry");
        _;
    }

    constructor(address web3Entry_) {
        require(web3Entry_ != address(0), "InvalidWeb3Entry");
        web3Entry = web3Entry_;
    }
}
