# Solidity API

## ApprovalLinkModule4Character

This is a simple LinkModule implementation, inheriting from the ILinkModule4Character interface.

### _approvedByCharacterByOwner

```solidity
mapping(address => mapping(uint256 => mapping(address => bool))) _approvedByCharacterByOwner
```

### constructor

```solidity
constructor(address web3Entry_) public
```

### initializeLinkModule

```solidity
function initializeLinkModule(uint256 characterId, bytes data) external returns (bytes)
```

### approve

```solidity
function approve(uint256 characterId, address[] addresses, bool[] toApprove) external
```

A custom function that allows character owners to customize approved addresses.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The character ID to approve/disapprove. |
| addresses | address[] | The addresses to approve/disapprove for linking the character. |
| toApprove | bool[] | Whether to approve or disapprove the addresses for linking the character. |

### processLink

```solidity
function processLink(address caller, uint256 characterId, bytes) external view
```

### isApproved

```solidity
function isApproved(address characterOwner, uint256 characterId, address toCheck) external view returns (bool)
```

