// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {CommonTest} from "./helpers/CommonTest.sol";
import {Linklist} from "../contracts/Linklist.sol";
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
        vm.createSelectFork(vm.envString("CROSSBELL_RPC_URL"), 41621719);
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
                "Linklist",
                "LIT",
                _web3Entry
            )
        );
        // check newImpl
        vm.prank(_proxyAdmin);
        assertEq(TransparentUpgradeableProxy(_linklist).implementation(), address(newImpl));
        // check initialize
        assertEq(Linklist(_linklist).Web3Entry(), _web3Entry);
        assertEq(Linklist(_linklist).name(), "Linklist");
        assertEq(Linklist(_linklist).symbol(), "LIT");
    }

    function testInitializeFail() public {
        Linklist newImpl = new Linklist();
        // upgrade and initialize
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_linklist).upgradeToAndCall(
            address(newImpl),
            abi.encodeWithSignature(
                "initialize(string,string,address)",
                "Linklist",
                "LIT",
                _web3Entry
            )
        );

        // initialize again
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        Linklist(address(_linklist)).initialize("Linklist", "LIT", _web3Entry);
    }

    function testUpgradeLinklistWithBurn() public {
        Linklist newImpl = new Linklist();
        // upgrade and initialize
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_linklist).upgradeToAndCall(
            address(newImpl),
            abi.encodeWithSignature(
                "initialize(string,string,address)",
                "Linklist",
                "LIT",
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
}
