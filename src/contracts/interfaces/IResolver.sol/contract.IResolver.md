# IResolver
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/d7461dc986f92c02778fae6c468f62f2db6d2f91/contracts/interfaces/IResolver.sol)


## Functions
### addENSRecords


```solidity
function addENSRecords(string[] calldata labels, address[] calldata owners) external;
```

### addRNSRecords


```solidity
function addRNSRecords(string[] calldata labels, address[] calldata owners) external;
```

### deleteENSRecords


```solidity
function deleteENSRecords(string[] calldata labels) external;
```

### deleteRNSRecords


```solidity
function deleteRNSRecords(string[] calldata labels) external;
```

### getENSRecord


```solidity
function getENSRecord(string calldata label) external view returns (address);
```

### getRNSRecord


```solidity
function getRNSRecord(string calldata label) external view returns (address);
```

### getTotalENSCount


```solidity
function getTotalENSCount() external view returns (uint256);
```

### getTotalRNSCount


```solidity
function getTotalRNSCount() external view returns (uint256);
```

