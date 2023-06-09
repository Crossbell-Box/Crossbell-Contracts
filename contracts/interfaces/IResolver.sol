// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IResolver {
    function addENSRecords(string[] calldata labels, address[] calldata owners) external;

    function addRNSRecords(string[] calldata labels, address[] calldata owners) external;

    function deleteENSRecords(string[] calldata labels) external;

    function deleteRNSRecords(string[] calldata labels) external;

    function getENSRecord(string calldata label) external view returns (address);

    function getRNSRecord(string calldata label) external view returns (address);

    function getTotalENSCount() external view returns (uint256);

    function getTotalRNSCount() external view returns (uint256);
}
