// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@std/Test.sol";
import "@std/Script.sol";
import "src/Web3Entry.sol";
import "src/misc/Periphery.sol";
import "src/upgradeability/TransparentUpgradeableProxy.sol";

contract UpgradePeriphery is Script {
    address payable public peripheryProxy = payable(0x96e96b7AF62D628cE7eb2016D2c1D2786614eA73);

    /* solhint-disable comprehensive-interface */
    function run() external {
        vm.startBroadcast();

        Periphery periphery = new Periphery();
        TransparentUpgradeableProxy proxy = TransparentUpgradeableProxy(peripheryProxy);
        proxy.upgradeTo(address(periphery));

        vm.stopBroadcast();
    }
}
