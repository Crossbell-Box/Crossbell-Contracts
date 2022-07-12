// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@std/Test.sol";
import "@std/Script.sol";
import "../src/Web3Entry.sol";
import "../src/upgradeability/TransparentUpgradeableProxy.sol";

contract Web3EntryScript is Script {
    address admin = address(0x01); // update admin address before deployment

    function run() external {
        vm.startBroadcast();

        Web3Entry web3Entry = new Web3Entry();
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(web3Entry), admin, "");

        vm.stopBroadcast();
    }
}