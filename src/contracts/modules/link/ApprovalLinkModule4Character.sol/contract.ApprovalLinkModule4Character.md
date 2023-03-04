# ApprovalLinkModule4Character
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/4ba4e225416bca003567c0e6ae31b9c6258df17e/contracts/modules/link/ApprovalLinkModule4Character.sol)

**Inherits:**
[ILinkModule4Character](/contracts/interfaces/ILinkModule4Character.sol/contract.ILinkModule4Character.md), [ModuleBase](/contracts/modules/ModuleBase.sol/contract.ModuleBase.md)

This is a simple LinkModule implementation, inheriting from the ILinkModule4Character interface.


## State Variables
### _approvedByCharacterByOwner

```solidity
mapping(address => mapping(uint256 => mapping(address => bool))) internal _approvedByCharacterByOwner;
```


## Functions
### constructor


```solidity
constructor(address web3Entry_) ModuleBase(web3Entry_);
```

### initializeLinkModule


```solidity
function initializeLinkModule(uint256 characterId, bytes calldata data) external override returns (bytes memory);
```

### approve

A custom function that allows character owners to customize approved addresses.


```solidity
function approve(uint256 characterId, address[] calldata addresses, bool[] calldata toApprove) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterId`|`uint256`|The character ID to approve/disapprove.|
|`addresses`|`address[]`|The addresses to approve/disapprove for linking the character.|
|`toApprove`|`bool[]`|Whether to approve or disapprove the addresses for linking the character.|


### processLink


```solidity
function processLink(address caller, uint256 characterId, bytes calldata) external view override onlyWeb3Entry;
```

### isApproved


```solidity
function isApproved(address characterOwner, uint256 characterId, address toCheck) external view returns (bool);
```

