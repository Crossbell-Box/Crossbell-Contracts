// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../Web3Entry.sol";
import "../libraries/DataTypes.sol";
import "../Web3Entry.sol";
import "../upgradeability/TransparentUpgradeableProxy.sol";
import "../modules/link/ApprovalLinkModule4Character.sol";
import "./EmitExpecter.sol";
import "./Const.sol";
import "./helpers/utils.sol";
import "./Const.sol";
import "../Linklist.sol";
import "../MintNFT.sol";

contract LinkModuleTest is Test, EmitExpecter, Utils {
    Web3Entry web3Entry;
    Linklist linklist;
    MintNFT mintNFT;
    ApprovalLinkModule4Character linkModule4Character;

    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public userThree = address(0x3333);
    address public admin = address(0x999);

    function setUp() public {
        // deploy mintNFTimpl
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

        // deploy linkModule4Character
        linkModule4Character = new ApprovalLinkModule4Character(address(web3Entry));

        // initialize web3Entry
        web3Entry.initialize(
            Const.WEB3_ENTRY_NFT_NAME,
            Const.WEB3_ENTRY_NFT_SYMBOL,
            address(linklist),
            address(mintNFT),
            address(0x1), // periphery
            address(0x2) // resolver
        );
        // initialize linklist
        linklist.initialize(
            Const.LINK_LIST_NFT_NAME,
            Const.LINK_LIST_NFT_SYMBOL,
            address(web3Entry)
        );
    }

    function testLinkCharacterWithLinkModule() public {
        // User not in approval list should not fail to link a character
        address[] memory whitelist = new address[](2);
        whitelist[0] = userThree;
        whitelist[1] = bob;

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(
            DataTypes.CreateCharacterData(
                bob,
                Const.MOCK_CHARACTER_HANDLE2,
                Const.MOCK_CHARACTER_URI,
                address(linkModule4Character),
                abi.encode(whitelist)
            )
        );

        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType,
                new bytes(1)
            )
        );
    }
}
