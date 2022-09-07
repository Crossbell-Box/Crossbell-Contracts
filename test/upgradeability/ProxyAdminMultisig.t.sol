// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/upgradeability/ProxyAdminMultisig.sol";
import "../../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "../../contracts/mocks/UpgradeV1.sol";
import "../../contracts/mocks/UpgradeV2.sol";
import "../../contracts/libraries/Events.sol";
import "../helpers/utils.sol";
import "../helpers/Const.sol";

contract MultisigTest is Test, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public charlie = address(0x3333);
    address public daniel = address(0x4444);
    address[] public ownersArr = [alice, bob, charlie];

    ProxyAdminMultisig proxyAdminMultisig;
    TransparentUpgradeableProxy transparentUpgradeableProxy;
    UpgradeV1 upgradeV1;
    UpgradeV2 upgradeV2;

    function setUp() public {
        upgradeV1 = new UpgradeV1();
        upgradeV2 = new UpgradeV2();
        proxyAdminMultisig = new ProxyAdminMultisig(ownersArr, 2);
        transparentUpgradeableProxy = new TransparentUpgradeableProxy(
            address(upgradeV1),
            address(proxyAdminMultisig),
            abi.encodeWithSelector(upgradeV1.initialize.selector, 1)
        );
    }

    function testProposeToUpgrade() public {
        // check initial implementation address
        vm.prank(address(proxyAdminMultisig));
        address preImplementation = transparentUpgradeableProxy.implementation();
        assertEq(preImplementation, address(upgradeV1));
        // alice propose to upgrade
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        vm.startPrank(alice);
        emit Events.Propose(1, transparentUpgradeableProxy, "Upgrade", address(upgradeV2));
        proxyAdminMultisig.propose(transparentUpgradeableProxy, "Upgrade", address(upgradeV2));
        // alice approve the proposal
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.Approval(alice, 1);
        proxyAdminMultisig.approveProposal(1);
        // shouldn't upgrade when there is not enough approval
        vm.stopPrank();
        vm.prank(address(proxyAdminMultisig));
        address preImplementation2 = transparentUpgradeableProxy.implementation();
        assertEq(preImplementation2, address(upgradeV1));
        // bob approve the proposal
        vm.startPrank(bob);
        // expect approve event
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.Approval(bob, 1);
        // expect upgrade event
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.Upgrade(transparentUpgradeableProxy, address(upgradeV2));
        proxyAdminMultisig.approveProposal(1);
        vm.stopPrank();
        // once there are enough approvals, execute automatically
        vm.prank(address(proxyAdminMultisig));
        address postImplementation = transparentUpgradeableProxy.implementation();
        assertEq(postImplementation, address(upgradeV2));
    }

    function testProposeToUpgradeFail() public {
        // not owner can't propose
        vm.expectRevert(abi.encodePacked("NotOwner"));
        vm.prank(daniel);
        proxyAdminMultisig.propose(transparentUpgradeableProxy, "Upgrade", address(upgradeV2));

        // can'e offer invalid proposal
        vm.expectRevert("Unexpected proposal type");
        vm.prank(alice);
        proxyAdminMultisig.propose(transparentUpgradeableProxy, "upgrade", address(upgradeV2));

        // not owner can't approve
        vm.prank(alice);
        proxyAdminMultisig.propose(transparentUpgradeableProxy, "Upgrade", address(upgradeV2));
        vm.expectRevert(abi.encodePacked("NotOwner"));
        vm.prank(daniel);
        proxyAdminMultisig.approveProposal(1);

        // can't approve twice
        vm.startPrank(alice);
        proxyAdminMultisig.approveProposal(1);
        vm.expectRevert(abi.encodePacked("AlreadyApproved"));
        proxyAdminMultisig.approveProposal(1);
        vm.stopPrank();

        // can't approve proposals that don't exist
        vm.startPrank(alice);
        vm.expectRevert(abi.encodePacked("NotPendingProposal"));
        proxyAdminMultisig.approveProposal(0);
        vm.expectRevert(abi.encodePacked("NotPendingProposal"));
        proxyAdminMultisig.approveProposal(2);
        vm.stopPrank();

        // can't approve proposals that's deleted
        vm.prank(bob);
        proxyAdminMultisig.approveProposal(1);
        vm.expectRevert(abi.encodePacked("NotPendingProposal"));
        vm.startPrank(charlie);
        proxyAdminMultisig.approveProposal(1);
    }

    function testProposeToChangeAdmin() public {
        // 1. alice propose to change admin in to alice
        vm.prank(alice);
        proxyAdminMultisig.propose(transparentUpgradeableProxy, "ChangeAdmin", address(alice));
        // 2. alice and bob approve
        vm.prank(alice);
        proxyAdminMultisig.approveProposal(1);
        vm.prank(bob);
        proxyAdminMultisig.approveProposal(1);
        // check the admin has changed
        vm.prank(alice);
        address admin = transparentUpgradeableProxy.admin();
        assertEq(admin, alice);
    }
}
