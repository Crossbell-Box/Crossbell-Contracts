// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Currency is ERC20("TTT", "TTT") {
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
