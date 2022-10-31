// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../contracts/Web3Entry.sol";
import "./helpers/OldWeb3Entry.sol";
import "../contracts/libraries/DataTypes.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";
import "../../contracts/Web3Entry.sol";
import "../contracts/Linklist.sol";
import "../contracts/misc/Periphery.sol";
import "../contracts/misc/CharacterBoundToken.sol";
import "../contracts/libraries/DataTypes.sol";
import "../contracts/MintNFT.sol";
import "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "../contracts/modules/link/ApprovalLinkModule4Character.sol";
import "../contracts/mocks/NFT.sol";
import "../contracts/Resolver.sol";

contract UpgradeOperatorTest is Test, Utils {
    OldWeb3Entry oldWeb3EntryImpl;
    OldWeb3Entry oldWeb3Entry;
    Web3Entry web3EntryImpl;
    Web3Entry web3Entry;
    TransparentUpgradeableProxy proxyWeb3Entry;
    address public admin = address(0x999999999999999999999999999999);
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);
    address public dick = address(0x4444);
    address[] public arr = [carol, dick];
    address[] public arr2 = [carol];

    function setUp() public {
        oldWeb3EntryImpl = new OldWeb3Entry();
        proxyWeb3Entry = new TransparentUpgradeableProxy(address(oldWeb3EntryImpl), admin, "");
    }

    function testImpl() public {
        vm.startPrank(admin);
        address oldImpl = proxyWeb3Entry.implementation();
        assertEq(oldImpl, address(oldWeb3EntryImpl));

        // upgrade
        web3EntryImpl = new Web3Entry();
        proxyWeb3Entry.upgradeTo(address(web3EntryImpl));
        address impl = proxyWeb3Entry.implementation();
        assertEq(impl, address(web3EntryImpl));
        vm.stopPrank();
    }

    function testCheckStorage() public {
        // use old web3entry to generate some data
        OldWeb3Entry(address(proxyWeb3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice)
        );
        OldWeb3Entry(address(proxyWeb3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob)
        );

        // set operator using old web3entry
        vm.prank(alice);
        OldWeb3Entry(address(proxyWeb3Entry)).setOperator(Const.FIRST_CHARACTER_ID, bob);

        // upgrade web3Entry
        web3EntryImpl = new Web3Entry();
        vm.prank(admin);
        proxyWeb3Entry.upgradeTo(address(web3EntryImpl));

        // set operator list using new web3entry
        vm.prank(alice);
        Web3Entry(address(proxyWeb3Entry)).setOperatorList(Const.FIRST_CHARACTER_ID, arr, true);
        // now bob and [carol, dick] should be operator
        vm.prank(bob);
        Web3Entry(address(proxyWeb3Entry)).setCharacterUri(
            Const.FIRST_CHARACTER_ID,
            "https://example.com/profile"
        );
        vm.prank(carol);
        Web3Entry(address(proxyWeb3Entry)).setCharacterUri(
            Const.FIRST_CHARACTER_ID,
            "https://example.com/profile"
        );

        // delete operator using new web3Entry
        vm.prank(alice);
        // disapprove carol
        Web3Entry(address(proxyWeb3Entry)).setOperatorList(Const.FIRST_CHARACTER_ID, arr2, false);
        // carol is not operator now
        vm.prank(carol);
        vm.expectRevert(abi.encodePacked("NotCharacterOwnerNorOperator"));
        Web3Entry(address(proxyWeb3Entry)).setCharacterUri(
            Const.FIRST_CHARACTER_ID,
            "https://example.com/profile"
        );
        // dick is still operator
        vm.prank(dick);
        Web3Entry(address(proxyWeb3Entry)).setCharacterUri(
            Const.FIRST_CHARACTER_ID,
            "https://example.com/profile"
        );

        // delete operator using old Web3entry
        vm.prank(alice);
        OldWeb3Entry(address(proxyWeb3Entry)).setOperator(Const.FIRST_CHARACTER_ID, address(0x0));
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NotCharacterOwnerNorOperator"));
        Web3Entry(address(proxyWeb3Entry)).setCharacterUri(
            Const.FIRST_CHARACTER_ID,
            "https://example.com/profile"
        );
    }
}
