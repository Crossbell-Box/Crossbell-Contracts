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

    uint256 DEFAULT_PERMISSION_BITMAP = ~uint256(0) << 20;
    uint256 OPERATORSIGN_PERMISSION_BITMAP = ~uint256(0) << 176;
    uint256 OPERATORSYNC_PERMISSION_BITMAP = ~uint256(0) << 236;
    uint256 DEFAULT_NOTE_PERMISSION_BITMAP = ~uint256(0) >> 250;

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

    // function testCheckStorage() public {
    // // use web3entryBase to generate some data
    // Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
    //     makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice)
    // );
    // Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
    //     makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob)
    // );

    // // set operator using Web3entryBase
    // vm.prank(alice);
    // Web3EntryBase(address(proxyWeb3Entry)).setOperator(Const.FIRST_CHARACTER_ID, bob);
    // assertEq(Web3Entry(address(proxyWeb3Entry)).getOperator(Const.FIRST_CHARACTER_ID), bob);

    // // add operator using new web3entry
    // vm.prank(alice);
    // Web3Entry(address(proxyWeb3Entry)).addOperator(Const.FIRST_CHARACTER_ID, carol);
    // // now bob and bob and carol should be operator
    // assert(Web3Entry(address(proxyWeb3Entry)).isOperator(Const.FIRST_CHARACTER_ID, bob));
    // assert(Web3Entry(address(proxyWeb3Entry)).isOperator(Const.FIRST_CHARACTER_ID, carol));

    // // remove operator using new web3Entry
    // vm.prank(alice);
    // // remove carol
    // Web3Entry(address(proxyWeb3Entry)).removeOperator(Const.FIRST_CHARACTER_ID, carol);
    // // carol is not operator now
    // assert(!Web3Entry(address(proxyWeb3Entry)).isOperator(Const.FIRST_CHARACTER_ID, carol));

    // // upgrade web3Entry
    // web3EntryImpl = new Web3Entry();
    // vm.prank(admin);
    // proxyWeb3Entry.upgradeTo(address(web3EntryImpl));

    // vm.startPrank(alice);
    // Web3Entry(address(proxyWeb3Entry)).postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
    // Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
    //     Const.FIRST_CHARACTER_ID,
    //     bob,
    //     OP.DEFAULT_PERMISSION_BITMAP
    // );
    // Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
    //     Const.FIRST_CHARACTER_ID,
    //     carol,
    //     OP.OPERATORSIGN_PERMISSION_BITMAP
    // );
    // Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions4Note(
    //     Const.FIRST_CHARACTER_ID,
    //     Const.FIRST_NOTE_ID,
    //     bob,
    //     OP.DEFAULT_NOTE_PERMISSION_BITMAP
    // );
    // vm.stopPrank();
    // }

    // function testSlot() public {
    //     // create character
    //     Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
    //         makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice)
    //     );
    //     // set operator & add operator
    //     vm.startPrank(alice);
    //     Web3EntryBase(address(proxyWeb3Entry)).setOperator(Const.FIRST_CHARACTER_ID, bob);
    //     Web3Entry(address(proxyWeb3Entry)).addOperator(Const.FIRST_CHARACTER_ID, bob);
    //     Web3Entry(address(proxyWeb3Entry)).addOperator(Const.FIRST_CHARACTER_ID, carol);
    //     vm.stopPrank();

    //     bytes32 bytes32Periphery = bytes32((uint256(uint160(periphery))));
    //     bytes32 bytes32Resolver = bytes32((uint256(uint160(resolver))));
    //     bytes32 bytes32bob = bytes32((uint256(uint160(bob))));
    //     bytes32 bytes32carol = bytes32((uint256(uint160(carol))));

    //     // get storage slot before the upgrade
    //     bytes32[] memory prevSlotArr = new bytes32[](27);
    //     for (uint256 i = 0; i < 27; i++) {
    //         bytes32 value = vm.load(address(proxyWeb3Entry), bytes32(uint256(i)));
    //         prevSlotArr[i] = value;
    //     }
    //     assertEq(prevSlotArr[21], bytes32Periphery);
    //     assertEq(prevSlotArr[23], bytes32Resolver);

    //     // check _operatorByCharacter slot
    //     assertEq(prevSlotArr[22], bytes32((uint256(0))));
    //     bytes32 prevOperatorSlot = keccak256(
    //         abi.encodePacked(Const.FIRST_CHARACTER_ID, bytes32(uint256(22)))
    //     );
    //     bytes32 prevValueAtOperatorSlot = vm.load(address(proxyWeb3Entry), prevOperatorSlot);
    //     assertEq(prevValueAtOperatorSlot, bytes32bob);

    //     // check operatorSlot
    //     bytes32 operatorSlot = keccak256(
    //         abi.encodePacked(Const.FIRST_CHARACTER_ID, bytes32(uint256(22)))
    //     );
    //     bytes32 valueAtOperatorSlot = vm.load(address(proxyWeb3Entry), operatorSlot);
    //     assertEq(valueAtOperatorSlot, bytes32bob);

    //     // check operatorsSlot
    //     // the slot storages the length of EnumerableSet.AddressSet, and it's 2(there is 2 operators in this list)
    //     bytes32 operatorsSlot = keccak256(
    //         abi.encodePacked(Const.FIRST_CHARACTER_ID, bytes32(uint256(24)))
    //     );
    //     // check operators length
    //     bytes32 valueAtOperatorsSlot = vm.load(address(proxyWeb3Entry), operatorsSlot);
    //     assertEq(valueAtOperatorsSlot, bytes32(uint256(2)));
    //     // check operators
    //     bytes32 operators1Slot = bytes32(uint256(keccak256(abi.encodePacked(operatorsSlot))) + 0);
    //     assertEq(vm.load(address(proxyWeb3Entry), operators1Slot), bytes32bob);
    //     bytes32 operators2Slot = bytes32(uint256(keccak256(abi.encodePacked(operatorsSlot))) + 1);
    //     assertEq(vm.load(address(proxyWeb3Entry), operators2Slot), bytes32carol);

    //     // upgrade to new web3Entry
    //     vm.startPrank(admin);
    //     web3EntryImpl = new Web3Entry();
    //     proxyWeb3Entry.upgradeTo(address(web3EntryImpl));
    //     address impl = proxyWeb3Entry.implementation();
    //     assertEq(impl, address(web3EntryImpl));
    //     vm.stopPrank();

    //     bytes32[] memory newSlotArr = new bytes32[](27);
    //     for (uint256 i = 0; i < 27; i++) {
    //         bytes32 value = vm.load(address(proxyWeb3Entry), bytes32(uint256(i)));
    //         newSlotArr[i] = value;
    //     }
    //     // check slots
    //     for (uint256 i = 0; i < 27; i++) {
    //         assertEq(prevSlotArr[i], newSlotArr[i]);
    //     }

    //     vm.startPrank(alice);
    //     Web3Entry(address(proxyWeb3Entry)).postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
    //     Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
    //         Const.FIRST_CHARACTER_ID,
    //         bob,
    //         OP.DEFAULT_PERMISSION_BITMAP
    //     );
    //     Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
    //         Const.FIRST_CHARACTER_ID,
    //         carol,
    //         OP.OPERATORSIGN_PERMISSION_BITMAP
    //     );
    //     Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions4Note(
    //         Const.FIRST_CHARACTER_ID,
    //         Const.FIRST_NOTE_ID,
    //         bob,
    //         OP.DEFAULT_NOTE_PERMISSION_BITMAP
    //     );
    //     vm.stopPrank();

    //     // check operatorsPermissionBitMap
    //     // check bob
    //     bytes32 operatorBitmapSlot = keccak256(
    //         abi.encodePacked(
    //             bytes32bob,
    //             (keccak256(abi.encodePacked(Const.FIRST_CHARACTER_ID, bytes32(uint256(25)))))
    //         )
    //     );
    //     bytes32 valueAtOperatorBitmapSlot = vm.load(address(proxyWeb3Entry), operatorBitmapSlot);
    //     assertEq32(valueAtOperatorBitmapSlot, bytes32(OP.DEFAULT_PERMISSION_BITMAP));

    //     // check carol
    //     operatorBitmapSlot = keccak256(
    //         abi.encodePacked(
    //             bytes32carol,
    //             (keccak256(abi.encodePacked(Const.FIRST_CHARACTER_ID, bytes32(uint256(25)))))
    //         )
    //     );
    //     valueAtOperatorBitmapSlot = vm.load(address(proxyWeb3Entry), operatorBitmapSlot);
    //     assertEq32(valueAtOperatorBitmapSlot, bytes32(OP.OPERATORSIGN_PERMISSION_BITMAP));

    //     // check bob note permission
    //     operatorBitmapSlot = keccak256(
    //         abi.encodePacked(
    //             uint256(1),
    //             (keccak256(abi.encodePacked(Const.FIRST_CHARACTER_ID, bytes32(uint256(26)))))
    //         )
    //     );
    //     bytes32 noteBitmapSlot = keccak256(abi.encodePacked(bytes32bob, operatorBitmapSlot));
    //     bytes32 valueAtNoteBitmapSlot = vm.load(address(proxyWeb3Entry), noteBitmapSlot);
    //     assertEq32(valueAtNoteBitmapSlot, bytes32(OP.DEFAULT_NOTE_PERMISSION_BITMAP));
    // }
}
