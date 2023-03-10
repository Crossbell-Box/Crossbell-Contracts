// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import {IResolver} from "./interfaces/IResolver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Resolver is IResolver, Ownable {
    mapping(bytes32 => address) internal _ensRecords;
    mapping(bytes32 => address) internal _rnsRecords;
    uint256 internal _totalENSCount;
    uint256 internal _totalRNSCount;

    function addENSRecords(
        string[] calldata labels,
        address[] calldata owners
    ) external override onlyOwner {
        _addRecords(labels, owners, true);
    }

    function addRNSRecords(
        string[] calldata labels,
        address[] calldata owners
    ) external override onlyOwner {
        _addRecords(labels, owners, false);
    }

    function deleteENSRecords(string[] calldata labels) external override onlyOwner {
        _deleteRecords(labels, true);
    }

    function deleteRNSRecords(string[] calldata labels) external override onlyOwner {
        _deleteRecords(labels, false);
    }

    function getENSRecord(string calldata label) external view override returns (address) {
        bytes32 hash = keccak256(bytes(label));
        return _ensRecords[hash];
    }

    function getRNSRecord(string calldata label) external view override returns (address) {
        bytes32 hash = keccak256(bytes(label));
        return _rnsRecords[hash];
    }

    function getTotalENSCount() external view override returns (uint256) {
        return _totalENSCount;
    }

    function getTotalRNSCount() external view override returns (uint256) {
        return _totalRNSCount;
    }

    function _addRecords(string[] memory labels, address[] memory owners, bool ens) internal {
        require(labels.length == owners.length, "ArrayLengthMismatch");
        for (uint256 i = 0; i < labels.length; i++) {
            bytes32 hash = keccak256(bytes(labels[i]));
            if (ens) {
                // add ens record
                require(_ensRecords[hash] == address(0), "RecordExists");
                _ensRecords[hash] = owners[i];
                _totalENSCount++;
            } else {
                // add rns record
                require(_rnsRecords[hash] == address(0), "RecordExists");
                _rnsRecords[hash] = owners[i];
                _totalRNSCount++;
            }
        }
    }

    function _deleteRecords(string[] calldata labels, bool ens) internal {
        for (uint256 i = 0; i < labels.length; i++) {
            bytes32 hash = keccak256(bytes(labels[i]));
            if (ens) {
                delete _ensRecords[hash];
                _totalENSCount--;
            } else {
                delete _rnsRecords[hash];
                _totalRNSCount--;
            }
        }
    }
}
