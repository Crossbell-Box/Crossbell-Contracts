// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Currency is ERC20("TTT", "TTT") {
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
