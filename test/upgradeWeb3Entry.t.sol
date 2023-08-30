// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {CommonTest} from "./helpers/CommonTest.sol";
import {Web3Entry} from "../contracts/Web3Entry.sol";
import {IWeb3Entry} from "../contracts/interfaces/IWeb3Entry.sol";
import {
    TransparentUpgradeableProxy
} from "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import {OP} from "../contracts/libraries/OP.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {
    TransparentUpgradeableProxy
} from "../contracts/upgradeability/TransparentUpgradeableProxy.sol";

contract UpgradeWeb3Entry is CommonTest {
    using EnumerableSet for EnumerableSet.AddressSet;

    // test upgradeability of web3Entry from crossbell fork
    address payable internal _web3Entry =
        payable(address(0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8));
    address internal _linklist = address(0xFc8C75bD5c26F50798758f387B698f207a016b6A);
    address internal _proxyAdmin = address(0x5f603895B48F0C451af39bc7e0c587aE15718e4d);

    function setUp() public {
        // create and select a fork from crossbell at block 41621719
        vm.createSelectFork(vm.envString("CROSSBELL_RPC_URL"), 41621719);
    }

    function testCheckSetupState() public {
        assertEq(IWeb3Entry(_web3Entry).getLinklistContract(), _linklist);

        bytes32 v = vm.load(_web3Entry, bytes32(uint256(20)));
        assertEq(uint256(v >> 160), uint256(3)); // initialize version
    }

    function testInitializeFail() public {
        Web3Entry newImpl = new Web3Entry();
        // upgrade
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_web3Entry).upgradeTo(address(newImpl));

        // initialize
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        IWeb3Entry(_web3Entry).initialize(
            "Web3 Entry Character",
            "WEC",
            _linklist,
            address(mintNFTImpl),
            address(periphery),
            address(newbieVilla)
        );
    }

    // solhint-disable-next-line function-max-lines
    function testCheckStorage() public {
        Web3Entry newImpl = new Web3Entry();
        // upgrade
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_web3Entry).upgradeTo(address(newImpl));

        // check state
        assertEq(IWeb3Entry(_web3Entry).getLinklistContract(), _linklist);
        assertEq(IWeb3Entry(_web3Entry).getHandle(4418), "albert");
        assertEq(
            IWeb3Entry(_web3Entry).getCharacterUri(4418),
            "ipfs://bafkreig2gii2uuvrhfftfzqibjpztwt5kfyouuj2p2xpnvlakau4fzmtme"
        );
        assertEq(IWeb3Entry(_web3Entry).getLinklistId(4418, FollowLinkType), 151);
        assertEq(IWeb3Entry(_web3Entry).getLinklistType(151), FollowLinkType);
        assertEq(IWeb3Entry(_web3Entry).getCharacter(4418).noteCount, 51);

        // use web3entryBase to generate some data
        uint256 aliceCharacterId = Web3Entry(_web3Entry).createCharacter(
            makeCharacterData(CHARACTER_HANDLE, alice)
        );

        vm.startPrank(alice);
        Web3Entry(_web3Entry).postNote(makePostNoteData(aliceCharacterId));
        // grant operator sign permission to bob
        Web3Entry(_web3Entry).grantOperatorPermissions(
            aliceCharacterId,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            Web3Entry(_web3Entry).getOperatorPermissions(aliceCharacterId, bob),
            OP.DEFAULT_PERMISSION_BITMAP
        );

        // grant operator sync permission to carol
        Web3Entry(_web3Entry).grantOperatorPermissions(
            aliceCharacterId,
            carol,
            OP.POST_NOTE_PERMISSION_BITMAP
        );
        assertEq(
            Web3Entry(_web3Entry).getOperatorPermissions(aliceCharacterId, carol),
            OP.POST_NOTE_PERMISSION_BITMAP
        );

        address[] memory blocklist = array(bob, admin);
        address[] memory allowlist = array(carol, bob, alice);

        // grant NOTE_SET_NOTE_URI permission to bob
        Web3Entry(_web3Entry).grantOperators4Note(
            aliceCharacterId,
            FIRST_NOTE_ID,
            blocklist,
            allowlist
        );

        (address[] memory blocklist_, address[] memory allowlist_) = Web3Entry(_web3Entry)
            .getOperators4Note(aliceCharacterId, FIRST_NOTE_ID);

        assertEq(blocklist_, blocklist);
        assertEq(allowlist_, allowlist);

        vm.stopPrank();
    }
}
