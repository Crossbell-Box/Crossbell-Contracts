// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IResolver {
    function addENSRecords(string[] calldata labels, address[] calldata owners) external;

    function addRNSRecords(string[] calldata labels, address[] calldata owners) external;

    function deleteENSRecords(string[] calldata labels, address[] calldata owners) external;

    function deleteRNSRecords(string[] calldata labels, address[] calldata owners) external;

    function getENSRecord(string calldata label) external view returns (address);

    function getRNSRecord(string calldata label) external view returns (address);
}
