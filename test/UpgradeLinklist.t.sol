// SPDX-License-Identifier: MIT
// slither-disable-start unused-return
pragma solidity 0.8.18;

import {NFTBase} from "../contracts/base/NFTBase.sol";
import {CommonTest} from "./helpers/CommonTest.sol";
import {Linklist} from "../contracts/Linklist.sol";
import {
    TransparentUpgradeableProxy
} from "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract LinklistOld is NFTBase, Initializable {
    address public web3Entry;

    // solhint-disable comprehensive-interface
    function initialize(
        string calldata name_,
        string calldata symbol_,
        address web3Entry_
    ) external initializer {
        web3Entry = web3Entry_;

        super._initialize(name_, symbol_);
    }

    function getVersion() external pure returns (uint256) {
        return 1;
    }
}

contract UpgradeLinklistTest is CommonTest {
    address internal _web3Entry = address(0x123456789);

    TransparentUpgradeableProxy internal _proxyLinklist;
    Linklist internal _linklist;
    LinklistOld internal _linklistOld;

    function setUp() public {
        _linklist = new Linklist();
        _linklistOld = new LinklistOld();

        _proxyLinklist = new TransparentUpgradeableProxy(
            address(_linklistOld),
            admin,
            abi.encodeWithSignature(
                "initialize(string,string,address)",
                "Linklist",
                "LIT",
                _web3Entry
            )
        );
    }

    function testCheckSetupState() public {
        vm.prank(admin);
        assertEq(_proxyLinklist.implementation(), address(_linklistOld));
        assertEq(LinklistOld(address(_proxyLinklist)).web3Entry(), _web3Entry);
        assertEq(LinklistOld(address(_proxyLinklist)).getVersion(), 1);
    }

    function testUpgradeLinklist() public {
        // upgrade and initialize
        vm.prank(admin);
        _proxyLinklist.upgradeToAndCall(
            address(_linklist),
            abi.encodeWithSignature(
                "initialize(string,string,address)",
                "Linklist",
                "LIT",
                _web3Entry
            )
        );
        assertEq(Linklist(address(_proxyLinklist)).Web3Entry(), _web3Entry);
        vm.prank(admin);
        assertEq(_proxyLinklist.implementation(), address(_linklist));
    }

    function testInitializeFail() public {
        // upgrade and initialize
        vm.prank(admin);
        _proxyLinklist.upgradeToAndCall(
            address(_linklist),
            abi.encodeWithSignature(
                "initialize(string,string,address)",
                "Linklist",
                "LIT",
                _web3Entry
            )
        );

        // initialize again
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        Linklist(address(_proxyLinklist)).initialize("Linklist", "LIT", _web3Entry);
    }
}
