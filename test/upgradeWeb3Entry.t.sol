// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/Web3EntryBase.sol";
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
    string[] public prevSlot;
    bytes32[] public prevSlotArr;
    bytes32[] public newSlotArr;

    function setUp() public {
        web3EntryBaseImpl = new Web3EntryBase();
        proxyWeb3Entry = new TransparentUpgradeableProxy(address(web3EntryBaseImpl), admin, "");
        Web3EntryBase(address(proxyWeb3Entry)).initialize(
            Const.WEB3_ENTRY_NFT_NAME,
            Const.WEB3_ENTRY_NFT_SYMBOL,
            address(0x111), // linklistContract
            address(0x222), // mintNFTImpl
            address(0x333), // periphery
            address(0x444) // resolver
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

        // set operator using new web3entry
        vm.prank(alice);
        Web3Entry(address(proxyWeb3Entry)).addOperator(Const.FIRST_CHARACTER_ID, carol);
        // now bob and bob and carol should be operator
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
        Web3Entry(address(proxyWeb3Entry)).removeOperator(Const.FIRST_CHARACTER_ID, carol);
        // carol is not operator now
        vm.prank(carol);
        vm.expectRevert(abi.encodePacked("NotCharacterOwnerNorOperator"));
        Web3Entry(address(proxyWeb3Entry)).setCharacterUri(
            Const.FIRST_CHARACTER_ID,
            "https://example.com/profile"
        );

        // delete operator set up by web3EntryBase
        vm.prank(alice);
        Web3Entry(address(proxyWeb3Entry)).removeOperator(Const.FIRST_CHARACTER_ID, bob);
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NotCharacterOwnerNorOperator"));
        Web3Entry(address(proxyWeb3Entry)).setCharacterUri(
            Const.FIRST_CHARACTER_ID,
            "https://example.com/profile"
        );
    }

    function testSlot() public {
        for (uint256 index = 0; index < 24; index++) {
            bytes32 value = vm.load(address(proxyWeb3Entry), bytes32(uint256(index)));
            prevSlotArr.push(value);
        }

        vm.startPrank(admin);
        web3EntryImpl = new Web3Entry();
        proxyWeb3Entry.upgradeTo(address(web3EntryImpl));
        address impl = proxyWeb3Entry.implementation();
        assertEq(impl, address(web3EntryImpl));

        for (uint256 index = 0; index < 24; index++) {
            bytes32 value = vm.load(address(proxyWeb3Entry), bytes32(uint256(index)));
            newSlotArr.push(value);
        }

        for (uint256 index = 0; index < 24; index++) {
            bytes32 prevSlot = prevSlotArr[index];
            bytes32 newSlot = prevSlotArr[index];
            assertEq(prevSlot,newSlot);
        }
    }
}
