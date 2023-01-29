// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@std/Test.sol";
import "@std/Script.sol";
import "../Web3Entry.sol";
import "../upgradeability/TransparentUpgradeableProxy.sol";

contract UpgradeWeb3Entry is Script {
    address payable public web3EntryProxy = payable(0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8);

    /* solhint-disable comprehensive-interface */
    function run() external {
        vm.startBroadcast();

        Web3Entry web3Entry = new Web3Entry();
        TransparentUpgradeableProxy proxy = TransparentUpgradeableProxy(web3EntryProxy);
        proxy.upgradeTo(address(web3Entry));

        vm.stopBroadcast();
    }
}
