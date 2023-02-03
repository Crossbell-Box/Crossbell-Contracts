// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../../contracts/Web3Entry.sol";
import "../../contracts/Linklist.sol";
import "../../contracts/misc/Periphery.sol";
import "../../contracts/misc/CharacterBoundToken.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../../contracts/MintNFT.sol";
import "../../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "../../contracts/modules/link/ApprovalLinkModule4Character.sol";
import "../../contracts/modules/mint/ApprovalMintModule.sol";
import "../../contracts/mocks/NFT.sol";
import "./Const.sol";
import "./utils.sol";

contract SetUp {
    Web3Entry public web3Entry;
    Linklist public linklist;
    Periphery public periphery;
    MintNFT public mintNFT;
    ApprovalLinkModule4Character public linkModule4Character;
    NFT public nft;
    CharacterBoundToken public cbt;
    TransparentUpgradeableProxy public proxyWeb3Entry;
    address public admin = address(0x999999999999999999999999999999);

    /* solhint-disable comprehensive-interface */
    function _setUp() internal {
        // deploy mintNFT
        mintNFT = new MintNFT();

        // deploy web3Entry
        Web3Entry web3EntryImpl = new Web3Entry();
        proxyWeb3Entry = new TransparentUpgradeableProxy(address(web3EntryImpl), admin, "");
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

        // deploy cbt
        cbt = new CharacterBoundToken(address(web3Entry));

        // initialize web3Entry
        web3Entry.initialize(
            Const.WEB3_ENTRY_NFT_NAME,
            Const.WEB3_ENTRY_NFT_SYMBOL,
            address(linklist),
            address(mintNFT),
            address(periphery) // periphery
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
