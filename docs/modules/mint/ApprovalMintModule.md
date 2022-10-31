# Solidity API

## ApprovalMintModule

### _approvedByCharacterByNoteByOwner

```solidity
mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => bool)))) _approvedByCharacterByNoteByOwner
```

### constructor

```solidity
constructor(address web3Entry) public
```

### initializeMintModule

```solidity
function initializeMintModule(uint256 characterId, uint256 noteId, bytes data) external returns (bytes)
```

### approve

```solidity
function approve(uint256 characterId, uint256 noteId, address[] addresses, bool[] toApprove) external
```

### processMint

```solidity
function processMint(address to, uint256 characterId, uint256 noteId, bytes data) external
```

### isApproved

```solidity
function isApproved(address characterOwner, uint256 characterId, uint256 noteId, address toCheck) external view returns (bool)
```

