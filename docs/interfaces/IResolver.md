# Solidity API

## IResolver

### addENSRecords

```solidity
function addENSRecords(string[] labels, address[] owners) external
```

### addRNSRecords

```solidity
function addRNSRecords(string[] labels, address[] owners) external
```

### deleteENSRecords

```solidity
function deleteENSRecords(string[] labels) external
```

### deleteRNSRecords

```solidity
function deleteRNSRecords(string[] labels) external
```

### getENSRecord

```solidity
function getENSRecord(string label) external view returns (address)
```

### getRNSRecord

```solidity
function getRNSRecord(string label) external view returns (address)
```

### getTotalENSCount

```solidity
function getTotalENSCount() external view returns (uint256)
```

### getTotalRNSCount

```solidity
function getTotalRNSCount() external view returns (uint256)
```

