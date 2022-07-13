// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "../Web3Entry.sol";
import "../Linklist.sol";
import "../misc/Periphery.sol";
import "../libraries/DataTypes.sol";
import "../Web3Entry.sol";
import "../upgradeability/TransparentUpgradeableProxy.sol";
import "../modules/link/ApprovalLinkModule4Character.sol";
import "./EmitExpecter.sol";
import "./Const.sol";
import "./helpers/utils.sol";
import "./Const.sol";
import "../MintNFT.sol";

contract SetUp {
    Web3Entry web3Entry;
    Linklist linklist;
    Periphery periphery;
    MintNFT mintNFT;
    ApprovalLinkModule4Character linkModule4Character;

    address public admin = address(0x999999999999999999999999999999);

    function _setUp() internal {
        // deploy mintNFT
        mintNFT = new MintNFT();

        // deploy web3Entry
        Web3Entry web3EntryImpl = new Web3Entry();
        TransparentUpgradeableProxy proxyWeb3Entry = new TransparentUpgradeableProxy(
            address(web3EntryImpl),
            admin,
            ""
        );
        web3Entry = Web3Entry(address(proxyWeb3Entry));

        // deploy Linklist
        Linklist linklistImpl = new Linklist();
        TransparentUpgradeableProxy proxyLinklist = new TransparentUpgradeableProxy(
            address(linklistImpl),
            admin,
            ""
        );
        linklist = Linklist(address(proxyLinklist));

        // deploy periphery
        periphery = new Periphery();

        // deploy linkModule4Character
        linkModule4Character = new ApprovalLinkModule4Character(address(web3Entry));

        // initialize web3Entry
        web3Entry.initialize(
            Const.WEB3_ENTRY_NFT_NAME,
            Const.WEB3_ENTRY_NFT_SYMBOL,
            address(linklist),
            address(mintNFT),
            address(periphery), // periphery
            address(0x2) // resolver
        );
        // initialize linklist
        linklist.initialize(
            Const.LINK_LIST_NFT_NAME,
            Const.LINK_LIST_NFT_SYMBOL,
            address(web3Entry)
        );
        // initialize periphery
        periphery.initialize(address(web3Entry), address(linklist));
    }
}
