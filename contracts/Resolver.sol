// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./interfaces/IResolver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Resolver is IResolver, Ownable {
    mapping(bytes32 => address) internal ensRecords;
    mapping(bytes32 => address) internal rnsRecords;

    function addENSRecords(string[] calldata labels, address[] calldata owners) external onlyOwner {
        require(labels.length == owners.length, "ArrayLengthMismatch");
        for (uint256 i = 0; i < labels.length; i++) {
            bytes32 hash = keccak256(bytes(labels[i]));
            require(ensRecords[hash] == address(0), "RecordExists");
            ensRecords[hash] = owners[i];
        }
    }

    function addRNSRecords(string[] calldata labels, address[] calldata owners) external onlyOwner {
        require(labels.length == owners.length, "ArrayLengthMismatch");
        for (uint256 i = 0; i < labels.length; i++) {
            bytes32 hash = keccak256(bytes(labels[i]));
            require(rnsRecords[hash] == address(0), "RecordExists");
            rnsRecords[hash] = owners[i];
        }
    }

    function deleteENSRecords(string[] calldata labels, address[] calldata owners)
        external
        onlyOwner
    {
        require(labels.length == owners.length, "ArrayLengthMismatch");
        for (uint256 i = 0; i < labels.length; i++) {
            bytes32 hash = keccak256(bytes(labels[i]));
            delete ensRecords[hash];
        }
    }

    function deleteRNSRecords(string[] calldata labels, address[] calldata owners)
        external
        onlyOwner
    {
        require(labels.length == owners.length, "ArrayLengthMismatch");
        for (uint256 i = 0; i < labels.length; i++) {
            bytes32 hash = keccak256(bytes(labels[i]));
            delete rnsRecords[hash];
        }
    }

    function getENSRecord(string calldata label) external view returns (address) {
        bytes32 hash = keccak256(bytes(label));
        return ensRecords[hash];
    }

    function getRNSRecord(string calldata label) external view returns (address) {
        bytes32 hash = keccak256(bytes(label));
        return rnsRecords[hash];
    }
}
