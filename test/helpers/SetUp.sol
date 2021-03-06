// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "../../src/Web3Entry.sol";
import "../../src/Linklist.sol";
import "../../src/misc/Periphery.sol";
import "../../src/misc/CharacterBoundToken.sol";
import "../../src/libraries/DataTypes.sol";
import "../../src/MintNFT.sol";
import "../../src/upgradeability/TransparentUpgradeableProxy.sol";
import "../../src/modules/link/ApprovalLinkModule4Character.sol";
import "../../src/mocks/NFT.sol";
import "../../src/Resolver.sol";
import "./Const.sol";
import "./utils.sol";

contract SetUp {
    Web3Entry web3Entry;
    Linklist linklist;
    Periphery periphery;
    MintNFT mintNFT;
    ApprovalLinkModule4Character linkModule4Character;
    NFT nft;
    Resolver resolver;
    CharacterBoundToken cbt;

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

        // deploy resolver
        resolver = new Resolver();

        // deploy cbt
        cbt = new CharacterBoundToken(address(web3Entry));

        // initialize web3Entry
        web3Entry.initialize(
            Const.WEB3_ENTRY_NFT_NAME,
            Const.WEB3_ENTRY_NFT_SYMBOL,
            address(linklist),
            address(mintNFT),
            address(periphery), // periphery
            address(resolver) // resolver
        );
        // initialize linklist
        linklist.initialize(
            Const.LINK_LIST_NFT_NAME,
            Const.LINK_LIST_NFT_SYMBOL,
            address(web3Entry)
        );
        // initialize periphery
        periphery.initialize(address(web3Entry), address(linklist));

        // deploy NFT for test
        nft = new NFT();
        nft.initialize("NFT", "NFT");
    }
}
