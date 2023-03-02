# Solidity API

## ApprovalMintModule

This is a simple MintModule implementation, inheriting from the IMintModule4Note interface.

### _approvedByCharacterByNoteByOwner

```solidity
mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => bool)))) _approvedByCharacterByNoteByOwner
```

### constructor

```solidity
constructor(address web3Entry_) public
```

### initializeMintModule

```solidity
function initializeMintModule(uint256 characterId, uint256 noteId, bytes data) external returns (bytes)
```

### approve

```solidity
function approve(uint256 characterId, uint256 noteId, address[] addresses, bool[] toApprove) external
```

The owner of specified note can call this function,
to approve accounts to mint specified note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character. |
| noteId | uint256 | ID of note. |
| addresses | address[] | Address to set. |
| toApprove | bool[] | To approve or revoke. |

### processMint

```solidity
function processMint(address to, uint256 characterId, uint256 noteId, bytes) external view
```

Processes the mint logic.
Triggered when the `mintNote` of web3Entry is called, if mint module of note if set.

### isApproved

```solidity
function isApproved(address characterOwner, uint256 characterId, uint256 noteId, address account) external view returns (bool)
```

Checks whether the `account` is approved to mint specified note .

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterOwner | address | Address of character owner. |
| characterId | uint256 | ID of character to query. |
| noteId | uint256 | ID of note to query. |
| account | address | Address of account to query. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | Returns true if the `account` is approved to mint, otherwise returns false. |

