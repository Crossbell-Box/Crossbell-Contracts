# Solidity API

## ApprovalLinkModule4Note

### _approvedByCharacterByNoteByOwner

```solidity
mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => bool)))) _approvedByCharacterByNoteByOwner
```

### constructor

```solidity
constructor(address web3Entry) public
```

### initializeLinkModule

```solidity
function initializeLinkModule(uint256 characterId, uint256 noteId, bytes data) external returns (bytes)
```

### approve

```solidity
function approve(uint256 characterId, uint256 noteId, address[] addresses, bool[] toApprove) external
```

### processLink

```solidity
function processLink(address caller, uint256 characterId, uint256 noteId, bytes) external view
```

### isApproved

```solidity
function isApproved(address characterOwner, uint256 characterId, uint256 noteId, address toCheck) external view returns (bool)
```

