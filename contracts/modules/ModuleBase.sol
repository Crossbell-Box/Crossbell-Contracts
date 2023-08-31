// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ErrCallerNotWeb3Entry, ErrInvalidWeb3Entry} from "../libraries/Error.sol";

abstract contract ModuleBase {
    // solhint-disable-next-line immutable-vars-naming
    address public immutable web3Entry;

    modifier onlyWeb3Entry() {
        if (msg.sender != web3Entry) revert ErrCallerNotWeb3Entry();
        _;
    }

    constructor(address web3Entry_) {
        if (web3Entry_ == address(0)) revert ErrInvalidWeb3Entry();
        web3Entry = web3Entry_;
    }
}
