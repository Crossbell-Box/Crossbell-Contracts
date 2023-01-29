// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Script.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/Linklist.sol";
import "../contracts/MintNFT.sol";
import "../contracts/misc/Periphery.sol";
import "../contracts/upgradeability/TransparentUpgradeableProxy.sol";

contract Deploy is Script {
    // update admin address before deployment
    address public admin = address(0x713Ba8985dF91249b9e4CD86DD9eF62f8c8ddBC6);
    string public constant WEB3_ENTRY_NFT_NAME = "Web3 Entry Character";
    string public constant WEB3_ENTRY_NFT_SYMBOL = "WEC";
    string public constant LINK_LIST_NFT_NAME = "Link List Token";
    string public constant LINK_LIST_NFT_SYMBOL = "LLT";

    /* solhint-disable comprehensive-interface */
    function run() external {
        vm.startBroadcast();

        // deploy mintNFT
        MintNFT mintNFT = new MintNFT();

        // deploy web3Entry
        Web3Entry web3EntryImpl = new Web3Entry();
        TransparentUpgradeableProxy proxyWeb3Entry = new TransparentUpgradeableProxy(
            address(web3EntryImpl),
            admin,
            ""
        );
        Web3Entry web3Entry = Web3Entry(address(proxyWeb3Entry));

        // deploy Linklist
        Linklist linklistImpl = new Linklist();
        TransparentUpgradeableProxy proxyLinklist = new TransparentUpgradeableProxy(
            address(linklistImpl),
            admin,
            ""
        );
        Linklist linklist = Linklist(address(proxyLinklist));

        // deploy periphery
        Periphery peripheryImpl = new Periphery();
        TransparentUpgradeableProxy proxyPeriphery = new TransparentUpgradeableProxy(
            address(peripheryImpl),
            admin,
            ""
        );
        Periphery periphery = Periphery(address(proxyPeriphery));

        // initialize web3Entry
        web3Entry.initialize(
            WEB3_ENTRY_NFT_NAME,
            WEB3_ENTRY_NFT_SYMBOL,
            address(linklist),
            address(mintNFT),
            address(periphery), // periphery
            address(0x2) // resolver
        );
        // initialize linklist
        linklist.initialize(LINK_LIST_NFT_NAME, LINK_LIST_NFT_SYMBOL, address(web3Entry));
        // initialize periphery
        periphery.initialize(address(web3Entry), address(linklist));

        vm.stopBroadcast();
    }
}
