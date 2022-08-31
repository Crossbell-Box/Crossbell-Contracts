// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/misc/Multisig.sol";
import "../../contracts/misc/ImplementationExample.sol";
import "../../contracts/misc/ImplementationExample2.sol";
import "../../contracts/misc/TransparentUpgradeableProxy.sol";

contract MultisigTest is Test {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public charlie = address(0x3333);
    address public daniel = address(0x4444);
    address[] public ownersArr = [alice, bob, charlie];

    Multisig multisig;
    ImplementationExample implementationExample;
    ImplementationExample2 implementationExample2;
    TransparentUpgradeableProxy transparentUpgradeableProxy;

    function setUp() public {
        multisig = new Multisig(ownersArr, 2);
        implementationExample = new ImplementationExample();
        implementationExample2 = new ImplementationExample2();
        // admin of transparentUpgradeableProxy is set to multisig
        transparentUpgradeableProxy = new TransparentUpgradeableProxy(
            address(implementationExample),
            address(multisig),
            abi.encodeWithSelector(implementationExample.initialize.selector, 1)
        );
    }

    function testProposeToUpgrade() public {
        // ! before upgrading the initial value should be 1
        uint256 initialValue = ImplementationExample(address(transparentUpgradeableProxy))
            .retrieve();
        assertEq(initialValue, 1);

        // 1. alice propose to upgrade
        vm.prank(alice);
        multisig.propose(transparentUpgradeableProxy, false, address(implementationExample2));
        // 2. alice and bob approve the proposal
        vm.prank(alice);
        multisig.approveProposal(1, true);
        // 3. shouldn't upgrade when there is not enough approval
        // ! the value should be 1 before executing
        uint256 value = ImplementationExample(address(transparentUpgradeableProxy)).retrieve();
        assertEq(value, 1);

        vm.prank(bob);
        // once there are enough approvals, execute automatically
        multisig.approveProposal(1, true);

        // ! after the upgrading the data should be 2
        ImplementationExample2(address(transparentUpgradeableProxy)).increment();
        uint256 upgradeValue = ImplementationExample2(address(transparentUpgradeableProxy))
            .retrieve();
        assertEq(upgradeValue, 2);
    }

    function testProposeToUpgradeFail() public {
        vm.expectRevert(abi.encodePacked("NotOwner"));
        vm.prank(daniel);
        multisig.propose(transparentUpgradeableProxy, false, address(implementationExample2));
    }

    function testProposeToChangeAdmin() public {
        // 1. alice propose to change admin in to alice
        vm.prank(alice);
        multisig.propose(transparentUpgradeableProxy, true, address(alice));
        // 2. alice and bob approve
        vm.prank(alice);
        multisig.approveProposal(1, true);
        vm.prank(bob);
        multisig.approveProposal(1, true);
        // check the admin has changed
        vm.prank(alice);
        address admin = transparentUpgradeableProxy.admin();
        assertEq(admin, alice);
    }
}
