// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "./libraries/Constants.sol";


interface ITransparentUpgradeableProxy {
    function changeAdmin(address newAdmin) external;

    function upgradeTo(address newImplementation) external;
}

contract ProxyAdminMultisig {
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

    modifier onlyMember() {
        require(owners[msg.sender] != address(0), "NotOwner");
        _;
    }


    mapping(address => address) internal owners;
    uint256 internal ownersCount;
    uint256 internal threshold;

    struct Proposal {
        address target;
        string proposalType; // "ChangeAdmin" or "Upgrade"
        address data;
        uint256 approvalCount;
        address[] approvals;
        string status;
    }
    uint256 internal proposalCount;
    mapping(uint256 => Proposal) internal proposals;
    uint256[] internal pendingProposalIds;

    constructor(address[] memory _owners, uint256 _threshold) {
        require(_threshold > 0, "ThresholdIsZero");
        require(_threshold <= _owners.length, "ThresholdExceedsOwnersCount");

        // initialize owners
        address currentOwner = Constants.SENTINEL_OWNER;
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(
                owner != address(0) && owner != Constants.SENTINEL_OWNER && currentOwner != owner,
                "InvalidOwner"
            );
            require(owners[owner] == address(0), "OwnerExists");
            owners[currentOwner] = owner;
            currentOwner = owner;
        }
        owners[currentOwner] = Constants.SENTINEL_OWNER;
        ownersCount = _owners.length;
        threshold = _threshold;

        emit Setup(msg.sender, _owners, ownersCount, threshold);
    }

    function propose(
        address target,
        string calldata proposalType,
        address data
    ) external onlyMember {
        require(
            keccak256(bytes(proposalType)) == keccak256(bytes(Constants.PROPOSAL_TYPE_CHANGE_ADMIN)) ||
                keccak256(bytes(proposalType)) == keccak256(bytes("Upgrade")),
            "Unexpected proposal type"
        );
        proposalCount++;
        uint256 proposalId = proposalCount;
        // create proposal
        proposals[proposalId].target = target;
        proposals[proposalId].proposalType = proposalType;
        proposals[proposalId].data = data;
        proposals[proposalId].approvalCount = 0;
        proposals[proposalId].status = Constants.PROPOSAL_STATUS_PENDING;
        pendingProposalIds.push(proposalId);

        emit Propose(proposalId, target, proposalType, data);
    }

    function approveProposal(uint256 _proposalId) external onlyMember {
        require(_isPendingProposal(_proposalId), "NotPendingProposal");
        require(!_hasApproved(msg.sender, _proposalId), "AlreadyApproved");

        // approve proposal
        proposals[_proposalId].approvalCount++;
        proposals[_proposalId].approvals.push(msg.sender);

        emit Approval(msg.sender, _proposalId);

        if (proposals[_proposalId].approvalCount >= threshold) {
            _executeProposal(_proposalId);
        }
    }

    // reject and delete a pending proposal
    function deleteProposal(uint256 _proposalId) external onlyMember {
        require(_isPendingProposal(_proposalId), "NotPendingProposal");

        _deletePendingProposalId(_proposalId);
        proposals[_proposalId].status = Constants.PROPOSAL_STATUS_DELETED;

        emit Delete(msg.sender, _proposalId);
    }

    function getPendingProposals() external view returns (Proposal[] memory results) {
        uint256 len = pendingProposalIds.length;

        results = new Proposal[](len);
        for (uint256 i = 0; i < len; i++) {
            uint256 pid = pendingProposalIds[i];
            results[i] = proposals[pid];
        }
    }

    function getAllProposals(uint256 offset, uint256 limit)
        external
        view
        returns (Proposal[] memory results)
    {
        if (offset >= proposalCount) return results;

        uint256 len = Math.min(limit, proposalCount - offset);

        results = new Proposal[](len);
        for (uint256 i = offset; i < offset + len; i++) {
            // plus 1 because proposalId starts from 1
            results[i - offset] = proposals[i + 1];
        }
    }

    function getWalletDetail()
        external
        view
        returns (
            uint256 _threshold,
            uint256 _ownersCount,
            address[] memory _owners
        )
    {
        _threshold = threshold;
        _ownersCount = ownersCount;
        _owners = _getOwners();
    }

    function getProposalCount() external view returns (uint256) {
        return proposalCount;
    }

    function isOwner(address owner) external view returns (bool) {
        return owner != Constants.SENTINEL_OWNER && owners[owner] != address(0);
    }

    function _getOwners() internal view returns (address[] memory) {
        address[] memory array = new address[](ownersCount);

        uint256 index = 0;
        address currentOwner = owners[Constants.SENTINEL_OWNER];
        while (currentOwner != Constants.SENTINEL_OWNER) {
            array[index] = currentOwner;
            currentOwner = owners[currentOwner];
            index++;
        }
        return array;
    }

    function _executeProposal(uint256 _proposalId) internal {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.approvalCount >= threshold, "NotEnoughApproval");

        if (keccak256(bytes(proposal.proposalType)) == keccak256(bytes(Constants.PROPOSAL_TYPE_CHANGE_ADMIN))) {
            ITransparentUpgradeableProxy(proposal.target).changeAdmin(proposal.data);
            emit ChangeAdmin(proposal.target, proposal.data);
        } else if (keccak256(bytes(proposal.proposalType)) == keccak256(bytes(Constants.PROPOSAL_TYPE_UPGRADE))) {
            ITransparentUpgradeableProxy(proposal.target).upgradeTo(proposal.data);
            emit Upgrade(proposal.target, proposal.data);
        } else {
            revert("Unexpected proposal type");
        }

        // update proposal
        _deletePendingProposalId(_proposalId);
        proposals[_proposalId].status = Constants.PROPOSAL_STATUS_EXECUTED;
    }

    function _deletePendingProposalId(uint256 _proposalId) internal {
        // find index to be deleted
        uint256 valueIndex = 0;
        for (uint256 i = 0; i < pendingProposalIds.length; i++) {
            if (_proposalId == pendingProposalIds[i]) {
                // plus 1 because index 0
                // means a value is not in the array.
                valueIndex = i + 1;
                break;
            }
        }

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = pendingProposalIds.length - 1;
            if (lastIndex != toDeleteIndex) {
                pendingProposalIds[toDeleteIndex] = pendingProposalIds[lastIndex];
            }

            // delete the slot
            pendingProposalIds.pop();
        }
    }

    function _hasApproved(address _owner, uint256 _proposalId) internal view returns (bool) {
        uint256 valueIndex;
        Proposal memory proposal = proposals[_proposalId];
        for (uint256 i = 0; i < proposal.approvals.length; i++) {
            if (_owner == proposal.approvals[i]) {
                // plus 1 because index 0
                // means a value is not in the array.
                valueIndex = i + 1;
                break;
            }
        }
        return valueIndex != 0;
    }

    function _isPendingProposal(uint256 _proposalId) internal view returns (bool) {
        uint256 valueIndex;
        for (uint256 i = 0; i < pendingProposalIds.length; i++) {
            if (_proposalId == pendingProposalIds[i]) {
                // plus 1 because index 0
                // means a value is not in the array.
                valueIndex = i + 1;
                break;
            }
        }

        return valueIndex != 0;
    }
}
