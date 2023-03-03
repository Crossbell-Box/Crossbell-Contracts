# Resolver
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/c7f31e42711569b1cb499ae27680e91d1ff85e00/contracts/Resolver.sol)

**Inherits:**
[IResolver](/contracts/interfaces/IResolver.sol/contract.IResolver.md), Ownable


## State Variables
### _ensRecords

```solidity
mapping(bytes32 => address) internal _ensRecords;
```


### _rnsRecords

```solidity
mapping(bytes32 => address) internal _rnsRecords;
```


### _totalENSCount

```solidity
uint256 internal _totalENSCount;
```


### _totalRNSCount

```solidity
uint256 internal _totalRNSCount;
```


## Functions
### addENSRecords


```solidity
function addENSRecords(string[] calldata labels, address[] calldata owners) external override onlyOwner;
```

### addRNSRecords


```solidity
function addRNSRecords(string[] calldata labels, address[] calldata owners) external override onlyOwner;
```

### deleteENSRecords


```solidity
function deleteENSRecords(string[] calldata labels) external override onlyOwner;
```

### deleteRNSRecords


```solidity
function deleteRNSRecords(string[] calldata labels) external override onlyOwner;
```

### getENSRecord


```solidity
function getENSRecord(string calldata label) external view override returns (address);
```

### getRNSRecord


```solidity
function getRNSRecord(string calldata label) external view override returns (address);
```

### getTotalENSCount


```solidity
function getTotalENSCount() external view override returns (uint256);
```

### getTotalRNSCount


```solidity
function getTotalRNSCount() external view override returns (uint256);
```

### _addRecords


```solidity
function _addRecords(string[] memory labels, address[] memory owners, bool ens) internal;
```

### _deleteRecords


```solidity
function _deleteRecords(string[] calldata labels, bool ens) internal;
```

