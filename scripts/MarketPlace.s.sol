// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@std/Test.sol";
import "@std/Script.sol";
import "../src/MarketPlace.sol";
import "../src/upgradeability/TransparentUpgradeableProxy.sol";

contract MarketPlaceScript is Script {
    address admin = address(0x01); // update admin address before deployment

    function run() external {
        vm.startBroadcast();

        MarketPlace marketPlace = new MarketPlace();
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(marketPlace), admin, "");

        vm.stopBroadcast();
    }
}