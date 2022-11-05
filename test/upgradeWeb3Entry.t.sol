// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
// import "forge-std/console2.sol";
import "../contracts/Linklist.sol";
import "../contracts/MintNFT.sol";
import "../contracts/Resolver.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/Web3EntryBase.sol";
import "../contracts/libraries/DataTypes.sol";
import "../contracts/misc/Periphery.sol";
import "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "./helpers/Const.sol";
import "./helpers/SetUp.sol";
import "./helpers/utils.sol";

contract UpgradeWeb3Entry is Test, Utils {
    Web3EntryBase web3EntryBaseImpl;
    Web3EntryBase web3EntryBase;
    Web3Entry web3EntryImpl;
    Web3Entry web3Entry;
    TransparentUpgradeableProxy proxyWeb3Entry;
    address public admin = address(0x999999999999999999999999999999);
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    address public linkList = address(0x111);
    address public periphery = address(0x222);
    address public mintNFT = address(0x333);
    address public resolver = address(0x444);

    function setUp() public {
        web3EntryBaseImpl = new Web3EntryBase();
        proxyWeb3Entry = new TransparentUpgradeableProxy(address(web3EntryBaseImpl), admin, "");
        Web3EntryBase(address(proxyWeb3Entry)).initialize(
            Const.WEB3_ENTRY_NFT_NAME,
            Const.WEB3_ENTRY_NFT_SYMBOL,
            linkList,
            mintNFT,
            periphery,
            resolver
        );
    }

    function testImpl() public {
        vm.startPrank(admin);
        address implBase = proxyWeb3Entry.implementation();
        assertEq(implBase, address(web3EntryBaseImpl));

        // upgrade
        web3EntryImpl = new Web3Entry();
        proxyWeb3Entry.upgradeTo(address(web3EntryImpl));
        address impl = proxyWeb3Entry.implementation();
        assertEq(impl, address(web3EntryImpl));
        vm.stopPrank();
    }

    function testCheckStorage() public {
        // use web3entryBase to generate some data
        Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice)
        );
        Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob)
        );

        // set operator using Web3entryBase
        vm.prank(alice);
        Web3EntryBase(address(proxyWeb3Entry)).setOperator(Const.FIRST_CHARACTER_ID, bob);

        // upgrade web3Entry
        web3EntryImpl = new Web3Entry();
        vm.prank(admin);
        proxyWeb3Entry.upgradeTo(address(web3EntryImpl));

        // add operator using new web3entry
        vm.prank(alice);
        Web3Entry(address(proxyWeb3Entry)).addOperator(Const.FIRST_CHARACTER_ID, carol);
        // now bob and bob and carol should be operator
        assert(Web3Entry(address(proxyWeb3Entry)).isOperator(Const.FIRST_CHARACTER_ID, bob));
        assert(Web3Entry(address(proxyWeb3Entry)).isOperator(Const.FIRST_CHARACTER_ID, carol));

        // remove operator using new web3Entry
        vm.prank(alice);
        // remove carol
        Web3Entry(address(proxyWeb3Entry)).removeOperator(Const.FIRST_CHARACTER_ID, carol);
        // carol is not operator now
        assert(!Web3Entry(address(proxyWeb3Entry)).isOperator(Const.FIRST_CHARACTER_ID, carol));
    }

    function testSlot() public {
        // create character
        Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice)
        );
        // set bob as operator of alice
        vm.prank(alice);
        Web3EntryBase(address(proxyWeb3Entry)).setOperator(Const.FIRST_CHARACTER_ID, bob);

        // slot 21 is periphery address
        bytes32 peripheryBytes32 = bytes32(0x0000000000000000000000000000000000000000000000000000000000000222);
        bytes32 valueAt21 = vm.load(address(proxyWeb3Entry), bytes32(uint256(21)));
        assertEq(peripheryBytes32, valueAt21);

        // slot 22 is _operatorByCharacter mapping, so it's 0
        bytes32 operatorByCharacterBytes32 = bytes32(0x0000000000000000000000000000000000000000000000000000000000000000);
        bytes32 valueAt22 = vm.load(address(proxyWeb3Entry), bytes32(uint256(22)));
        assertEq(operatorByCharacterBytes32, valueAt22);

        // check _operatorByCharacter slot
        bytes32 bobBytes32 = bytes32(0x0000000000000000000000000000000000000000000000000000000000002222);
        uint256 slot = 22;
        bytes32 operatorSlot = keccak256(abi.encodePacked(Const.FIRST_CHARACTER_ID, slot));
        bytes32 valueAtOperatorSlot = vm.load(address(proxyWeb3Entry), operatorSlot);
        assertEq(valueAtOperatorSlot, bobBytes32);

        // slot 23 is resolver address
        bytes32 resolverBytes32 = bytes32(0x0000000000000000000000000000000000000000000000000000000000000444);
        bytes32 valueAt23 = vm.load(address(proxyWeb3Entry), bytes32(uint256(23)));
        assertEq(resolverBytes32, valueAt23);

        // get storage slot before the upgrade
        uint256[] memory prevSlotArr = new uint256[](25);
        for (uint256 index = 0; index < 25; index++) {
            bytes32 value = vm.load(address(proxyWeb3Entry), bytes32(uint256(index)));
            prevSlotArr[index] = uint256(value);
        }


        // upgrade to new web3Entry
        vm.startPrank(admin);
        web3EntryImpl = new Web3Entry();
        proxyWeb3Entry.upgradeTo(address(web3EntryImpl));
        address impl = proxyWeb3Entry.implementation();
        assertEq(impl, address(web3EntryImpl));
        vm.stopPrank();

        // add operator
        vm.prank(alice);
        Web3Entry(address(proxyWeb3Entry)).addOperator(Const.FIRST_CHARACTER_ID, carol);

        uint256[] memory newSlotArr = new uint256[](25);
        for (uint256 index = 0; index < 25; index++) {
            bytes32 value = vm.load(address(proxyWeb3Entry), bytes32(uint256(index)));
            newSlotArr[index] = uint256(value);
        }

        // check slots
        for (uint256 index = 0; index < 25; index++) {
            assertEq(prevSlotArr[index], newSlotArr[index]);
        }
    }
}
