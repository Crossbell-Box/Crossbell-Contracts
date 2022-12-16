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

    address[] public blacklist = [bob, admin];
    address[] public whitelist = [carol, bob, alice];

    address public linkList = address(0x111);
    address public periphery = address(0x222);
    address public mintNFT = address(0x333);
    address public resolver = address(0x444);

    using EnumerableSet for EnumerableSet.AddressSet;

    struct Operators4Note {
        EnumerableSet.AddressSet blacklist;
        EnumerableSet.AddressSet whitelist;
    }

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

        // upgrade web3Entry
        web3EntryImpl = new Web3Entry();
        vm.prank(admin);
        proxyWeb3Entry.upgradeTo(address(web3EntryImpl));

        vm.startPrank(alice);
        Web3Entry(address(proxyWeb3Entry)).postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        // grant operator sign permission to bob
        Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            Web3Entry(address(proxyWeb3Entry)).getOperatorPermissions(
                Const.FIRST_CHARACTER_ID,
                bob
            ),
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // grant operator sync permission to carol
        Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            carol,
            OP.POST_NOTE_PERMISSION_BITMAP
        );
        assertEq(
            Web3Entry(address(proxyWeb3Entry)).getOperatorPermissions(
                Const.FIRST_CHARACTER_ID,
                carol
            ),
            OP.POST_NOTE_PERMISSION_BITMAP
        );

        // grant NOTE_SET_NOTE_URI permission to bob
        Web3Entry(address(proxyWeb3Entry)).addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        address[] memory _blacklist;
        address[] memory _whitelist;

        (_blacklist, _whitelist) = Web3Entry(address(proxyWeb3Entry)).getOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );

        assertEq(_blacklist, blacklist);
        assertEq(_whitelist, whitelist);

        Web3Entry(address(proxyWeb3Entry)).removeOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );

        (_blacklist, _whitelist) = Web3Entry(address(proxyWeb3Entry)).getOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );

        assertEq(_blacklist.length, 0);
        assertEq(_whitelist.length, 0);

        vm.stopPrank();
    }

    function testSlot() public {
        // create character
        Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice)
        );

        bytes32 bytes32Periphery = bytes32((uint256(uint160(periphery))));
        bytes32 bytes32Resolver = bytes32((uint256(uint160(resolver))));
        bytes32 bytes32bob = bytes32((uint256(uint160(bob))));
        bytes32 bytes32carol = bytes32((uint256(uint160(carol))));

        // get storage slot before the upgrade
        bytes32[] memory prevSlotArr = new bytes32[](27);
        for (uint256 i = 0; i < 27; i++) {
            bytes32 value = vm.load(address(proxyWeb3Entry), bytes32(uint256(i)));
            prevSlotArr[i] = value;
        }
        assertEq(prevSlotArr[21], bytes32Periphery);
        assertEq(prevSlotArr[23], bytes32Resolver);

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
        Web3Entry(address(proxyWeb3Entry)).postNote(makePostNoteData(Const.FIRST_CHARACTER_ID));
        Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        Web3Entry(address(proxyWeb3Entry)).grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            carol,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        Web3Entry(address(proxyWeb3Entry)).addOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blacklist,
            whitelist
        );
        vm.stopPrank();

        // check operatorsPermissionBitMap
        // check bob
        bytes32 operatorBitmapSlot = keccak256(
            abi.encodePacked(
                bytes32bob,
                (keccak256(abi.encodePacked(Const.FIRST_CHARACTER_ID, bytes32(uint256(25)))))
            )
        );
        bytes32 valueAtOperatorBitmapSlot = vm.load(address(proxyWeb3Entry), operatorBitmapSlot);
        assertEq32(valueAtOperatorBitmapSlot, bytes32(OP.DEFAULT_PERMISSION_BITMAP));

        // check carol
        operatorBitmapSlot = keccak256(
            abi.encodePacked(
                bytes32carol,
                (keccak256(abi.encodePacked(Const.FIRST_CHARACTER_ID, bytes32(uint256(25)))))
            )
        );
        valueAtOperatorBitmapSlot = vm.load(address(proxyWeb3Entry), operatorBitmapSlot);
        assertEq32(valueAtOperatorBitmapSlot, bytes32(OP.DEFAULT_PERMISSION_BITMAP));

        // check note 1 operators
        bytes32 blacklistLengthSlot = keccak256(
            abi.encodePacked(
                Const.FIRST_NOTE_ID,
                (keccak256(abi.encodePacked(Const.FIRST_CHARACTER_ID, bytes32(uint256(26)))))
            )
        );
        bytes32 valueAtBlacklistLengthSlot = vm.load(address(proxyWeb3Entry), blacklistLengthSlot);
        // the length of blacklist is 2
        assertEq(valueAtBlacklistLengthSlot, bytes32(uint256(2)));

        uint256 blacklistMapSlot = uint256(bytes32(blacklistLengthSlot)) + uint256(1);

        // admin is the second address in blacklist
        bytes32 blacklistAdminIndexSlot = keccak256(
            abi.encodePacked(bytes32((uint256(uint160(admin)))), blacklistMapSlot)
        );
        bytes32 adminIndex = vm.load(address(proxyWeb3Entry), blacklistAdminIndexSlot);
        assertEq(adminIndex, bytes32(uint256(2)));

        // the length of whitelist is 3
        uint256 whitelistLengthSlot = uint256(bytes32(blacklistLengthSlot)) + uint256(2);
        bytes32 valueAtWhitelistLengthSlot = vm.load(
            address(proxyWeb3Entry),
            bytes32(whitelistLengthSlot)
        );
        assertEq(valueAtWhitelistLengthSlot, bytes32(uint256(3)));

        uint256 whitelistMapSlot = uint256(bytes32(blacklistLengthSlot)) + uint256(3);
        // carol is the first address in whitelist
        bytes32 whitelistCarolIndexSlot = keccak256(
            abi.encodePacked(bytes32carol, whitelistMapSlot)
        );
        bytes32 carolIndex = vm.load(address(proxyWeb3Entry), whitelistCarolIndexSlot);
        assertEq(carolIndex, bytes32(uint256(1)));
    }
}
