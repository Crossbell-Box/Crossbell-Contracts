// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/upgradeability/Multisig.sol";
import "../../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "../../contracts/mocks/UpgradeV1.sol";
import "../../contracts/mocks/UpgradeV2.sol";

contract MultisigTest is Test {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public charlie = address(0x3333);
    address public daniel = address(0x4444);
    address[] public ownersArr = [alice, bob, charlie];

    Multisig multisig;
    TransparentUpgradeableProxy transparentUpgradeableProxy;
    UpgradeV1 upgradeV1;
    UpgradeV2 upgradeV2;

    function setUp() public {
        upgradeV1 = new UpgradeV1();
        upgradeV2 = new UpgradeV2();
        multisig = new Multisig(ownersArr, 2);
        // admin of transparentUpgradeableProxy is set to multisig
        transparentUpgradeableProxy = new TransparentUpgradeableProxy(
            address(upgradeV1),
            address(multisig),
            abi.encodeWithSelector(upgradeV1.initialize.selector, 1)
        );
    }

    function testProposeToUpgrade() public {
        vm.prank(address(multisig));
        address preImplementation = transparentUpgradeableProxy.implementation();
        assertEq(preImplementation, address(upgradeV1));
        // alice propose to upgrade
        vm.prank(alice);
        multisig.propose(transparentUpgradeableProxy, "Upgrade", address(upgradeV2));
        // alice approve the proposal
        vm.prank(alice);
        multisig.approveProposal(1);
        // shouldn't upgrade when there is not enough approval
        vm.prank(address(multisig));
        address preImplementation2 = transparentUpgradeableProxy.implementation();
        assertEq(preImplementation2, address(upgradeV1));
        // bob approve the proposal
        vm.prank(bob);
        multisig.approveProposal(1);
        // once there are enough approvals, execute automatically
        vm.prank(address(multisig));
        address postImplementation = transparentUpgradeableProxy.implementation();
        assertEq(postImplementation, address(upgradeV2));
    }

    function testProposeToUpgradeFail() public {
        vm.expectRevert(abi.encodePacked("NotOwner"));
        vm.prank(daniel);
        multisig.propose(transparentUpgradeableProxy, "Upgrade", address(upgradeV2));

        vm.expectRevert("Unexpected proposal type");
        vm.prank(alice);
        multisig.propose(transparentUpgradeableProxy, "upgrade", address(upgradeV2));
    }

    function testProposeToChangeAdmin() public {
        // 1. alice propose to change admin in to alice
        vm.prank(alice);
        multisig.propose(transparentUpgradeableProxy, "ChangeAdmin", address(alice));
        // 2. alice and bob approve
        vm.prank(alice);
        multisig.approveProposal(1);
        vm.prank(bob);
        multisig.approveProposal(1);
        // check the admin has changed
        vm.prank(alice);
        address admin = transparentUpgradeableProxy.admin();
        assertEq(admin, alice);
    }
}
