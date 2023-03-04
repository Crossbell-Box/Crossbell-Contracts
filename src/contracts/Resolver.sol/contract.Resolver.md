# Resolver
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/d4bcd4403377f0886ae184e5f617e94fbdfa377b(/Crossbell-Contracts/contracts/Resolver.sol)

**Inherits:**
[IResolver]((/Crossbell-Contracts/contracts/interfaces/IResolver.sol/contract.IResolver.md), Ownable


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

