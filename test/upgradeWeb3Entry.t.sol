// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {Linklist} from "../contracts/Linklist.sol";
import {MintNFT} from "../contracts/MintNFT.sol";
import {Web3Entry} from "../contracts/Web3Entry.sol";
import {Web3EntryBase} from "../contracts/Web3EntryBase.sol";
import {
    TransparentUpgradeableProxy
} from "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import {OP} from "../contracts/libraries/OP.sol";
import {Utils} from "./helpers/Utils.sol";
import {CommonTest} from "./helpers/CommonTest.sol";
import {ReinitializeWeb3Entry} from "./helpers/ReinitializeWeb3Entry.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract UpgradeWeb3Entry is Test, Utils {
    using EnumerableSet for EnumerableSet.AddressSet;

    Web3EntryBase public web3EntryBaseImpl;
    Web3EntryBase public web3EntryBase;
    Web3Entry public web3EntryImpl;
    Web3Entry public web3Entry;
    TransparentUpgradeableProxy public proxyWeb3Entry;

    address public admin = address(0x999999999999999999999999999999);
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    address public linkList = address(0x111);
    address public periphery = address(0x222);
    address public mintNFT = address(0x333);
    address public newbieVilla = address(0x444);

    function setUp() public {
        web3EntryBaseImpl = new Web3EntryBase();
        proxyWeb3Entry = new TransparentUpgradeableProxy(address(web3EntryBaseImpl), admin, "");
        Web3EntryBase(address(proxyWeb3Entry)).initialize(
            WEB3_ENTRY_NFT_NAME,
            WEB3_ENTRY_NFT_SYMBOL,
            linkList,
            mintNFT,
            periphery,
            newbieVilla
        );
    }

    function testInitialize() public {
        ReinitializeWeb3Entry reinitializeWeb3Entry;
        web3EntryBaseImpl = new Web3EntryBase();
        proxyWeb3Entry = new TransparentUpgradeableProxy(address(web3EntryBaseImpl), admin, "");
        Web3EntryBase(address(proxyWeb3Entry)).initialize(
            WEB3_ENTRY_NFT_NAME,
            WEB3_ENTRY_NFT_SYMBOL,
            linkList,
            mintNFT,
            periphery,
            newbieVilla
        );

        // check status
        assertEq(Web3EntryBase(address(proxyWeb3Entry)).name(), WEB3_ENTRY_NFT_NAME);
        assertEq(Web3EntryBase(address(proxyWeb3Entry)).symbol(), WEB3_ENTRY_NFT_SYMBOL);

        // reinitialize with higher version
        reinitializeWeb3Entry = new ReinitializeWeb3Entry();
        vm.prank(admin);
        proxyWeb3Entry.upgradeTo(address(reinitializeWeb3Entry));
        ReinitializeWeb3Entry(address(proxyWeb3Entry)).initialize(
            "NEW_WEB3_ENTRY_NFT_NAME",
            "NEW_WEB3_ENTRY_NFT_SYMBOL"
        );
        assertEq(Web3EntryBase(address(proxyWeb3Entry)).name(), "NEW_WEB3_ENTRY_NFT_NAME");
        assertEq(Web3EntryBase(address(proxyWeb3Entry)).symbol(), "NEW_WEB3_ENTRY_NFT_SYMBOL");
    }

    function testInitializeFail() public {
        ReinitializeWeb3Entry reinitializeWeb3Entry;
        // can't initialize twice
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        Web3EntryBase(address(proxyWeb3Entry)).initialize(
            WEB3_ENTRY_NFT_NAME,
            WEB3_ENTRY_NFT_SYMBOL,
            linkList,
            mintNFT,
            periphery,
            newbieVilla
        );

        // can't reinitialize once reach limit
        reinitializeWeb3Entry = new ReinitializeWeb3Entry();
        vm.prank(admin);
        // initialize version = 2
        proxyWeb3Entry.upgradeTo(address(reinitializeWeb3Entry));
        ReinitializeWeb3Entry(address(proxyWeb3Entry)).initialize(
            WEB3_ENTRY_NFT_NAME,
            WEB3_ENTRY_NFT_SYMBOL
        );
        // initialize version = 3, reinitialize
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        ReinitializeWeb3Entry(address(proxyWeb3Entry)).initialize(
            WEB3_ENTRY_NFT_NAME,
            WEB3_ENTRY_NFT_SYMBOL
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

    // solhint-disable-next-line function-max-lines
    function testCheckStorage() public {
        // use web3entryBase to generate some data
        Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
            makeCharacterData(CHARACTER_HANDLE, alice)
        );
        Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
            makeCharacterData(CHARACTER_HANDLE2, bob)
        );

        // upgrade web3Entry
        web3EntryImpl = new Web3Entry();
        vm.prank(admin);
        proxyWeb3Entry.upgradeTo(address(web3EntryImpl));

        vm.startPrank(alice);
        Web3Entry(address(proxyWeb3Entry)).postNote(makePostNoteData(FIRST_CHARACTER_ID));
        // grant operator sign permission to bob
        Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
            FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            Web3Entry(address(proxyWeb3Entry)).getOperatorPermissions(FIRST_CHARACTER_ID, bob),
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // grant operator sync permission to carol
        Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
            FIRST_CHARACTER_ID,
            carol,
            OP.POST_NOTE_PERMISSION_BITMAP
        );
        assertEq(
            Web3Entry(address(proxyWeb3Entry)).getOperatorPermissions(FIRST_CHARACTER_ID, carol),
            OP.POST_NOTE_PERMISSION_BITMAP
        );

        address[] memory blocklist = array(bob, admin);
        address[] memory allowlist = array(carol, bob, alice);

        // grant NOTE_SET_NOTE_URI permission to bob
        Web3Entry(address(proxyWeb3Entry)).grantOperators4Note(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            blocklist,
            allowlist
        );

        (address[] memory blocklist_, address[] memory allowlist_) = Web3Entry(
            address(proxyWeb3Entry)
        ).getOperators4Note(FIRST_CHARACTER_ID, FIRST_NOTE_ID);

        assertEq(blocklist_, blocklist);
        assertEq(allowlist_, allowlist);

        vm.stopPrank();
    }

    // solhint-disable-next-line function-max-lines
    function testSlot() public {
        // create character
        Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
            makeCharacterData(CHARACTER_HANDLE, alice)
        );

        bytes32 bytes32Periphery = bytes32((uint256(uint160(periphery))));
        bytes32 bytes32bob = bytes32((uint256(uint160(bob))));
        bytes32 bytes32carol = bytes32((uint256(uint160(carol))));

        // get storage slot before the upgrade
        bytes32[] memory prevSlotArr = new bytes32[](27);
        for (uint256 i = 0; i < 27; i++) {
            bytes32 value = vm.load(address(proxyWeb3Entry), bytes32(uint256(i)));
            prevSlotArr[i] = value;
        }
        assertEq(prevSlotArr[21], bytes32Periphery);

        // upgrade to new web3Entry
        vm.startPrank(admin);
        web3EntryImpl = new Web3Entry();
        proxyWeb3Entry.upgradeTo(address(web3EntryImpl));
        address impl = proxyWeb3Entry.implementation();
        assertEq(impl, address(web3EntryImpl));
        vm.stopPrank();

        bytes32[] memory newSlotArr = new bytes32[](27);
        for (uint256 i = 0; i < 27; i++) {
            bytes32 value = vm.load(address(proxyWeb3Entry), bytes32(uint256(i)));
            newSlotArr[i] = value;
        }
        // check slots
        for (uint256 i = 0; i < 27; i++) {
            assertEq(prevSlotArr[i], newSlotArr[i]);
        }

        vm.startPrank(alice);
        Web3Entry(address(proxyWeb3Entry)).postNote(makePostNoteData(FIRST_CHARACTER_ID));
        Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
            FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
            FIRST_CHARACTER_ID,
            carol,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        Web3Entry(address(proxyWeb3Entry)).grantOperators4Note(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            array(bob, admin),
            array(carol, bob, alice)
        );
        vm.stopPrank();

        // check operatorsPermissionBitMap
        // check bob
        bytes32 operatorBitmapSlot = keccak256(
            abi.encodePacked(
                bytes32bob,
                (keccak256(abi.encodePacked(FIRST_CHARACTER_ID, bytes32(uint256(25)))))
            )
        );
        bytes32 valueAtOperatorBitmapSlot = vm.load(address(proxyWeb3Entry), operatorBitmapSlot);
        assertEq32(valueAtOperatorBitmapSlot, bytes32(OP.DEFAULT_PERMISSION_BITMAP));

        // check carol
        operatorBitmapSlot = keccak256(
            abi.encodePacked(
                bytes32carol,
                (keccak256(abi.encodePacked(FIRST_CHARACTER_ID, bytes32(uint256(25)))))
            )
        );
        valueAtOperatorBitmapSlot = vm.load(address(proxyWeb3Entry), operatorBitmapSlot);
        assertEq32(valueAtOperatorBitmapSlot, bytes32(OP.DEFAULT_PERMISSION_BITMAP));

        // check alice's blocklist for note 1
        bytes32 blocklistSlot = keccak256(
            abi.encodePacked(
                FIRST_NOTE_ID,
                (keccak256(abi.encodePacked(FIRST_CHARACTER_ID, bytes32(uint256(26)))))
            )
        );
        bytes32 valueAtBlocklistSlot = vm.load(address(proxyWeb3Entry), blocklistSlot);
        // the length of the blocklist should be 2 (bob and admin are in the blocklist)
        assertEq(valueAtBlocklistSlot, bytes32(uint256(2)));
        bytes32 value1AtBlocklistSlot = keccak256(
            abi.encodePacked(bytes32bob, bytes32(uint256(blocklistSlot) + 1))
        );
        bytes32 value1AtBlocklist = vm.load(address(proxyWeb3Entry), value1AtBlocklistSlot);
        // the index of bob should be 1
        assertEq(value1AtBlocklist, bytes32(uint256(1)));
        /**
        * commented out to avoid `Stack too deep`
        bytes32 value2AtBlocklistSlot = keccak256(
            abi.encodePacked(
                bytes32admin,
                bytes32(uint256(blocklistSlot) + 1
            )
        ));
        bytes32 value2AtBlocklist = vm.load(address(proxyWeb3Entry), value2AtBlocklistSlot);
        // the index of bob should be 1
        assertEq(value2AtBlocklist,bytes32(uint256(2)));
        */

        // check alice's allowlist for note 1
        bytes32 valueAtAllowlist = vm.load(
            address(proxyWeb3Entry),
            bytes32(uint256(blocklistSlot) + 2)
        );
        // the length of the allowlist should be 3 (carol, bob, alice are in allowlist)
        assertEq(valueAtAllowlist, bytes32(uint256(3)));
        bytes32 value1AtAllowlistSlot = keccak256(
            abi.encodePacked(bytes32carol, bytes32(uint256(blocklistSlot) + 3))
        );
        bytes32 value1AtAllowlist = vm.load(address(proxyWeb3Entry), value1AtAllowlistSlot);
        // the index of bob should be 1
        assertEq(value1AtAllowlist, bytes32(uint256(1)));
        bytes32 value2AtAllowlistSlot = keccak256(
            abi.encodePacked(bytes32bob, bytes32(uint256(blocklistSlot) + 3))
        );
        bytes32 value2AtAllowlist = vm.load(address(proxyWeb3Entry), value2AtAllowlistSlot);
        // the index of bob should be 1
        assertEq(value2AtAllowlist, bytes32(uint256(2)));
    }
}
