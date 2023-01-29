// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
// import "forge-std/console2.sol";
import "../contracts/Linklist.sol";
import "../contracts/MintNFT.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/Web3EntryBase.sol";
import "../contracts/libraries/DataTypes.sol";
import "../contracts/misc/Periphery.sol";
import "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "./helpers/Const.sol";
import "./helpers/SetUp.sol";
import "./helpers/utils.sol";

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

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        web3EntryBaseImpl = new Web3EntryBase();
        proxyWeb3Entry = new TransparentUpgradeableProxy(address(web3EntryBaseImpl), admin, "");
        Web3EntryBase(address(proxyWeb3Entry)).initialize(
            Const.WEB3_ENTRY_NFT_NAME,
            Const.WEB3_ENTRY_NFT_SYMBOL,
            linkList,
            mintNFT,
            periphery
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

        address[] memory blocklist = array(bob, admin);
        address[] memory allowlist = array(carol, bob, alice);

        // grant NOTE_SET_NOTE_URI permission to bob
        Web3Entry(address(proxyWeb3Entry)).grantOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            blocklist,
            allowlist
        );

        (address[] memory blocklist_, address[] memory allowlist_) = Web3Entry(
            address(proxyWeb3Entry)
        ).getOperators4Note(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID);

        assertEq(blocklist_, blocklist);
        assertEq(allowlist_, allowlist);

        vm.stopPrank();
    }

    // solhint-disable-next-line function-max-lines
    function testSlot() public {
        // create character
        Web3EntryBase(address(proxyWeb3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice)
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
        Web3Entry(address(proxyWeb3Entry)).grantOperators4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            array(bob, admin),
            array(carol, bob, alice)
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
        bytes32 blocklistIndexSlot = keccak256(
            abi.encodePacked(
                Const.FIRST_NOTE_ID,
                (keccak256(abi.encodePacked(Const.FIRST_CHARACTER_ID, bytes32(uint256(26)))))
            )
        );
        bytes32 valueAtblocklistIndexSlot = vm.load(address(proxyWeb3Entry), blocklistIndexSlot);
        // the _blocklistSetIndex is 1
        assertEq(valueAtblocklistIndexSlot, bytes32(uint256(1)));

        uint256 blocklistMapSlot = uint256(bytes32(blocklistIndexSlot)) + uint256(1);
        bytes32 valueAtblocklistMapSlot = vm.load(
            address(proxyWeb3Entry),
            bytes32(blocklistMapSlot)
        );
        // there should be nothing at blocklistMapSlot
        assertEq(valueAtblocklistMapSlot, bytes32(uint256(0)));

        // the blocklist at index 1
        bytes32 blocklist1Slot = keccak256(abi.encodePacked(uint256(1), blocklistMapSlot));
        bytes32 valueAtblocklist1Slot = vm.load(address(proxyWeb3Entry), blocklist1Slot);
        // the length of blocklist at index 1  is 2
        assertEq(valueAtblocklist1Slot, bytes32(uint256(2)));

        // the allowlistSetIndex slot
        uint256 allowlistSetIndexSlot = uint256(bytes32(blocklistIndexSlot)) + uint256(2);
        bytes32 valueAtallowlistSetIndexSlot = vm.load(
            address(proxyWeb3Entry),
            bytes32(allowlistSetIndexSlot)
        );
        assertEq(valueAtallowlistSetIndexSlot, bytes32(uint256(1)));

        uint256 allowlistMapSlot = uint256(bytes32(allowlistSetIndexSlot)) + uint256(1);
        bytes32 valueAtAllowlistMapSlot = vm.load(
            address(proxyWeb3Entry),
            bytes32(allowlistMapSlot)
        );
        // there should be nothing at blocklistMapSlot
        assertEq(valueAtAllowlistMapSlot, bytes32(uint256(0)));

        // the allowlist at index 1
        bytes32 allowlist1Slot = keccak256(abi.encodePacked(uint256(1), allowlistMapSlot));
        bytes32 valueAtAllowlist1Slot = vm.load(address(proxyWeb3Entry), allowlist1Slot);
        // the length of allowlist at index 1  is 3
        assertEq(valueAtAllowlist1Slot, bytes32(uint256(3)));
    }
}
