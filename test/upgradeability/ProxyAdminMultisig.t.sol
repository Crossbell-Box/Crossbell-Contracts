// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/upgradeability/ProxyAdminMultisig.sol";
import "../../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import "../../contracts/mocks/UpgradeV1.sol";
import "../../contracts/mocks/UpgradeV2.sol";
import "../helpers/utils.sol";
import "../helpers/Const.sol";

interface DumbEmitterEvents {
    // events
    event Setup(
        address indexed initiator,
        address[] owners,
        uint256 indexed ownerCount,
        uint256 indexed threshold
    );

    event Propose(
        uint256 indexed proposalId,
        address target,
        string proposalType, // "ChangeAdmin" or "Upgrade"
        address data
    );
    event Approval(address indexed owner, uint256 indexed proposalId);
    event Delete(address indexed owner, uint256 indexed proposalId);
    event Execution(
        uint256 indexed proposalId,
        address target,
        string proposalType, // "ChangeAdmin" or "Upgrade"
        address data
    );
    event Upgrade(address target, address implementation);
    event ChangeAdmin(address target, address newAdmin);
}

contract MultisigTest is DumbEmitterEvents, Test, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public charlie = address(0x3333);
    address public daniel = address(0x4444);
    address[] public ownersArr2 = [alice, bob];
    address[] public ownersArr3 = [alice, bob, charlie];
    address[] public replicatedOwners = [alice, alice];
    address[] public zeroOwners = [alice, address(0x0)];
    address[] public sentinelOwners = [alice, address(0x1)];
    address[] public existsOwners = [alice, bob, alice];

    ProxyAdminMultisig proxyAdminMultisig;
    TransparentUpgradeableProxy transparentUpgradeableProxy;
    UpgradeV1 upgradeV1;
    UpgradeV2 upgradeV2;

    address target;

    function setUp() public {
        upgradeV1 = new UpgradeV1();
        upgradeV2 = new UpgradeV2();
        proxyAdminMultisig = new ProxyAdminMultisig(ownersArr3, 2);
        transparentUpgradeableProxy = new TransparentUpgradeableProxy(
            address(upgradeV1),
            address(proxyAdminMultisig),
            abi.encodeWithSelector(upgradeV1.initialize.selector, 1)
        );

        target = address(transparentUpgradeableProxy);
    }

    function testConstruct() public {
        proxyAdminMultisig = new ProxyAdminMultisig(ownersArr3, 2);
        proxyAdminMultisig = new ProxyAdminMultisig(ownersArr3, 3);
        proxyAdminMultisig = new ProxyAdminMultisig(ownersArr2, 1);
        proxyAdminMultisig = new ProxyAdminMultisig(ownersArr2, 2);
    }

    function testConstructFail() public {
        // Threshold can't be 0
        vm.expectRevert(abi.encodePacked("ThresholdIsZero"));
        proxyAdminMultisig = new ProxyAdminMultisig(ownersArr3, 0);
        // Threshold can't Exceed OwnersCount
        vm.expectRevert(abi.encodePacked("ThresholdExceedsOwnersCount"));
        proxyAdminMultisig = new ProxyAdminMultisig(ownersArr3, 4);
        // replicated owners
        vm.expectRevert(abi.encodePacked("InvalidOwner"));
        proxyAdminMultisig = new ProxyAdminMultisig(replicatedOwners, 1);
        // owner can't be 0x0 or 0x1
        vm.expectRevert(abi.encodePacked("InvalidOwner"));
        proxyAdminMultisig = new ProxyAdminMultisig(zeroOwners, 1);
        vm.expectRevert(abi.encodePacked("InvalidOwner"));
        proxyAdminMultisig = new ProxyAdminMultisig(sentinelOwners, 1);
        vm.expectRevert(abi.encodePacked("OwnerExists"));
        proxyAdminMultisig = new ProxyAdminMultisig(existsOwners, 1);
    }

    function testProposeToUpgrade() public {
        // check initial implementation address
        vm.prank(address(proxyAdminMultisig));
        address preImplementation = transparentUpgradeableProxy.implementation();
        assertEq(preImplementation, address(upgradeV1));
        // alice propose to upgrade
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        vm.startPrank(alice);
        emit Propose(1, target, "Upgrade", address(upgradeV2));
        proxyAdminMultisig.propose(target, "Upgrade", address(upgradeV2));

        // check proposal status
        ProxyAdminMultisig.Proposal[] memory proposals1 = proxyAdminMultisig.getPendingProposals();
        assertEq(proposals1[0].target, target);
        assertEq(proposals1[0].proposalType, "Upgrade");
        assertEq(proposals1[0].data, address(upgradeV2));
        assertEq(proposals1[0].approvalCount, 0);
        assertEq(proposals1[0].status, "Pending");

        // alice approve the proposal
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Approval(alice, 1);
        proxyAdminMultisig.approveProposal(1);

        ProxyAdminMultisig.Proposal[] memory proposals2 = proxyAdminMultisig.getPendingProposals();
        assertEq(proposals2[0].target, target);
        assertEq(proposals2[0].proposalType, "Upgrade");
        assertEq(proposals2[0].data, address(upgradeV2));
        assertEq(proposals2[0].approvalCount, 1);
        assertEq(proposals2[0].status, "Pending");

        // shouldn't upgrade when there is not enough approval
        vm.stopPrank();
        vm.prank(address(proxyAdminMultisig));
        address preImplementation2 = transparentUpgradeableProxy.implementation();
        assertEq(preImplementation2, address(upgradeV1));
        // bob approve the proposal
        vm.startPrank(bob);
        // expect approve event
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Approval(bob, 1);
        // expect upgrade event
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Upgrade(target, address(upgradeV2));
        proxyAdminMultisig.approveProposal(1);
        // check all proposal
        ProxyAdminMultisig.Proposal[] memory proposals3 = proxyAdminMultisig.getAllProposals(0, 1);
        assertEq(proposals3[0].target, target);
        assertEq(proposals3[0].proposalType, "Upgrade");
        assertEq(proposals3[0].data, address(upgradeV2));
        assertEq(proposals3[0].approvalCount, 2);
        assertEq(proposals3[0].status, "Executed");

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
        proxyAdminMultisig.propose(target, "Upgrade", address(upgradeV2));

        // can'e offer invalid proposal
        vm.expectRevert("Unexpected proposal type");
        vm.prank(alice);
        proxyAdminMultisig.propose(target, "upgrade", address(upgradeV2));
    }

    function testProposeChangeAdmin() public {
        // 1. alice propose to change admin in to alice
        vm.prank(alice);
        proxyAdminMultisig.propose(target, "ChangeAdmin", address(alice));

        // check proposal status
        ProxyAdminMultisig.Proposal[] memory proposalsC1 = proxyAdminMultisig.getPendingProposals();
        assertEq(proposalsC1[0].target, target);
        assertEq(proposalsC1[0].proposalType, "ChangeAdmin");
        assertEq(proposalsC1[0].data, address(alice));
        assertEq(proposalsC1[0].approvalCount, 0);
        assertEq(proposalsC1[0].status, "Pending");

        uint256 countC1 = proxyAdminMultisig.getProposalCount();
        assertEq(countC1, 1);

        // 2. alice and bob approve
        vm.prank(alice);
        proxyAdminMultisig.approveProposal(1);
        // check proposal status
        ProxyAdminMultisig.Proposal[] memory proposalsC2 = proxyAdminMultisig.getPendingProposals();
        assertEq(proposalsC2[0].target, target);
        assertEq(proposalsC2[0].proposalType, "ChangeAdmin");
        assertEq(proposalsC2[0].data, address(alice));
        assertEq(proposalsC2[0].approvalCount, 1);
        assertEq(proposalsC2[0].status, "Pending");
        uint256 countC2 = proxyAdminMultisig.getProposalCount();
        assertEq(countC2, 1);
        vm.prank(bob);
        proxyAdminMultisig.approveProposal(1);
        // check count
        uint256 countC3 = proxyAdminMultisig.getProposalCount();
        assertEq(countC3, 1);
        // check the admin has changed
        vm.prank(alice);
        address admin = transparentUpgradeableProxy.admin();
        assertEq(admin, alice);
    }

    function testApproveProposal() public {
        vm.startPrank(alice);
        proxyAdminMultisig.propose(target, "Upgrade", address(upgradeV2));
        proxyAdminMultisig.approveProposal(1);

        proxyAdminMultisig.propose(target, "ChangeAdmin", address(alice));
        proxyAdminMultisig.approveProposal(2);
    }

    function testApproveProposalFail() public {
        // not owner can't approve
        vm.prank(alice);
        proxyAdminMultisig.propose(target, "Upgrade", address(upgradeV2));
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

    function testDeleteProposal() public {
        vm.prank(alice);
        proxyAdminMultisig.propose(target, "ChangeAdmin", address(alice));

        uint256 count = proxyAdminMultisig.getProposalCount();
        assertEq(count, 1);
        vm.prank(alice);
        proxyAdminMultisig.deleteProposal(1);
        // delete only remove the proposal id from pending list
        uint256 count2 = proxyAdminMultisig.getProposalCount();
        assertEq(count2, 1);
    }

    function testDeleteProposalFail() public {
        vm.prank(alice);
        proxyAdminMultisig.propose(target, "ChangeAdmin", address(alice));

        uint256 count = proxyAdminMultisig.getProposalCount();
        assertEq(count, 1);
        vm.prank(daniel);
        vm.expectRevert(abi.encodePacked("NotOwner"));
        proxyAdminMultisig.deleteProposal(1);

        vm.expectRevert(abi.encodePacked("NotPendingProposal"));
        vm.prank(alice);
        proxyAdminMultisig.deleteProposal(2);
    }
}
