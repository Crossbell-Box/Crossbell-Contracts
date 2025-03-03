// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {CommonTest} from "./helpers/CommonTest.sol";
import {Linklist} from "../contracts/Linklist.sol";
import {IWeb3Entry} from "../contracts/interfaces/IWeb3Entry.sol";
import {
    TransparentUpgradeableProxy
} from "../contracts/upgradeability/TransparentUpgradeableProxy.sol";

contract UpgradeLinklistTest is CommonTest {
    // test upgradeability of Linklist from crossbell fork
    address internal _web3Entry = address(0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8);
    address payable internal _linklist =
        payable(address(0xFc8C75bD5c26F50798758f387B698f207a016b6A));
    address internal _proxyAdmin = address(0x5f603895B48F0C451af39bc7e0c587aE15718e4d);

    function setUp() public {
        // create and select a fork from crossbell at block 41621719
        vm.createSelectFork("https://rpc.crossbell.io", 41621719);
    }

    function testCheckSetupState() public {
        assertEq(Linklist(_linklist).Web3Entry(), _web3Entry);
    }

    function testUpgradeLinklist() public {
        Linklist newImpl = new Linklist();
        // upgrade and initialize
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_linklist).upgradeToAndCall(
            address(newImpl),
            abi.encodeWithSignature(
                "initialize(string,string,address)",
                "Link List Token",
                "LLT",
                _web3Entry
            )
        );
        // check newImpl
        vm.prank(_proxyAdmin);
        assertEq(TransparentUpgradeableProxy(_linklist).implementation(), address(newImpl));
        // check initialize
        assertEq(Linklist(_linklist).Web3Entry(), _web3Entry);
        assertEq(Linklist(_linklist).name(), "Link List Token");
        assertEq(Linklist(_linklist).symbol(), "LLT");
    }

    function testInitializeFail() public {
        Linklist newImpl = new Linklist();
        // upgrade and initialize
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_linklist).upgradeToAndCall(
            address(newImpl),
            abi.encodeWithSignature(
                "initialize(string,string,address)",
                "Link List Token",
                "LLT",
                _web3Entry
            )
        );

        // initialize again
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        Linklist(_linklist).initialize("Link List Token", "LLT", _web3Entry);
    }

    function testUpgradeLinklistWithBurn() public {
        Linklist newImpl = new Linklist();
        // upgrade and initialize
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_linklist).upgradeToAndCall(
            address(newImpl),
            abi.encodeWithSignature(
                "initialize(string,string,address)",
                "Link List Token",
                "LLT",
                _web3Entry
            )
        );

        uint256 totalSupply = Linklist(_linklist).totalSupply();
        // mint a linklist
        vm.prank(_web3Entry);
        uint256 tokenId = Linklist(_linklist).mint(FIRST_CHARACTER_ID, FollowLinkType);
        assertEq(totalSupply + 1, Linklist(_linklist).totalSupply());
        // burn a linklist
        vm.prank(_web3Entry);
        Linklist(_linklist).burn(tokenId);
        // check totalSupply
        assertEq(totalSupply, Linklist(_linklist).totalSupply());
    }

    function testUpgradeLinklistWithStorageCheck() public {
        // create and select a fork from crossbell at block 42914883
        vm.createSelectFork(vm.envString("CROSSBELL_RPC_URL"), 42914883);

        Linklist newImpl = new Linklist();
        // upgrade
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_linklist).upgradeTo(address(newImpl));

        // check storage
        Linklist linklist = Linklist(_linklist);
        assertEq(linklist.Web3Entry(), _web3Entry);
        assertEq(linklist.name(), "Link List Token");
        assertEq(linklist.symbol(), "LLT");

        uint256 followLinklistId = IWeb3Entry(_web3Entry).getLinklistId(4418, FollowLinkType);
        bytes32 linkType = IWeb3Entry(_web3Entry).getLinklistType(followLinklistId);
        assertEq(linklist.getLinkType(followLinklistId), linkType);
        assertEq(linklist.getLinkingCharacterListLength(followLinklistId), 177);
        assertEq(linklist.characterOwnerOf(followLinklistId), 4418);
        assertEq(linklist.ownerOf(followLinklistId), 0x3B6D02A24Df681FFdf621D35D70ABa7adaAc07c1);
        assertEq(linklist.Uri(followLinklistId), "");
        assertEq(linklist.balanceOf(4418), 2);
        assertEq(linklist.totalSupply(), 7954);
        // check linking notes
        uint256 likeLinklistId = IWeb3Entry(_web3Entry).getLinklistId(4418, LikeLinkType);
        assertEq(linklist.getLinkingNoteListLength(likeLinklistId), 92);
        assertEq(linklist.ownerOf(likeLinklistId), 0x3B6D02A24Df681FFdf621D35D70ABa7adaAc07c1);
    }
}
