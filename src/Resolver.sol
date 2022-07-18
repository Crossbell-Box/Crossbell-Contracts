// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./interfaces/IResolver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Resolver is IResolver, Ownable {
    mapping(bytes32 => address) internal ensRecords;
    mapping(bytes32 => address) internal rnsRecords;
    uint256 internal totalENSCount;
    uint256 internal totalRNSCount;

    function addENSRecords(string[] calldata labels, address[] calldata owners) external onlyOwner {
        _addRecords(labels, owners, true);
    }

    function addRNSRecords(string[] calldata labels, address[] calldata owners) external onlyOwner {
        _addRecords(labels, owners, false);
    }

    function deleteENSRecords(string[] calldata labels) external onlyOwner {
        _deleteRecords(labels, true);
    }

    function deleteRNSRecords(string[] calldata labels) external onlyOwner {
        _deleteRecords(labels, false);
    }

    function getENSRecord(string calldata label) external view returns (address) {
        bytes32 hash = keccak256(bytes(label));
        return ensRecords[hash];
    }

    function getRNSRecord(string calldata label) external view returns (address) {
        bytes32 hash = keccak256(bytes(label));
        return rnsRecords[hash];
    }

    function getTotalENSCount() external view returns (uint256) {
        return totalENSCount;
    }

    function getTotalRNSCount() external view returns (uint256) {
        return totalRNSCount;
    }

    function _addRecords(
        string[] memory labels,
        address[] memory owners,
        bool ens
    ) internal {
        require(labels.length == owners.length, "ArrayLengthMismatch");
        for (uint256 i = 0; i < labels.length; i++) {
            bytes32 hash = keccak256(bytes(labels[i]));
            if (ens) {
                // add ens record
                require(ensRecords[hash] == address(0), "RecordExists");
                ensRecords[hash] = owners[i];
                totalENSCount++;
            } else {
                // add rns record
                require(rnsRecords[hash] == address(0), "RecordExists");
                rnsRecords[hash] = owners[i];
                totalRNSCount++;
            }
        }
    }

    function _deleteRecords(string[] calldata labels, bool ens) internal {
        for (uint256 i = 0; i < labels.length; i++) {
            bytes32 hash = keccak256(bytes(labels[i]));
            if (ens) {
                delete ensRecords[hash];
                totalENSCount--;
            } else {
                delete rnsRecords[hash];
                totalRNSCount--;
            }
        }
    }
}
