# Solidity API

## ApprovalLinkModule4Character

### _approvedByCharacterByOwner

```solidity
mapping(address => mapping(uint256 => mapping(address => bool))) _approvedByCharacterByOwner
```

### constructor

```solidity
constructor(address web3Entry) public
```

### initializeLinkModule

```solidity
function initializeLinkModule(uint256 characterId, bytes data) external returns (bytes)
```

### approve

```solidity
function approve(uint256 characterId, address[] addresses, bool[] toApprove) external
```

### processLink

```solidity
function processLink(address caller, uint256 characterId, bytes) external view
```

### isApproved

```solidity
function isApproved(address characterOwner, uint256 characterId, address toCheck) external view returns (bool)
```

