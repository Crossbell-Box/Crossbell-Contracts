# Solidity API

## CharacterNoteData

```solidity
struct CharacterNoteData {
  uint256 amount;
  address token;
  address recipient;
}
```

## FeeMintModule

This is a simple MintModule implementation, inheriting from the IMintModule4Note interface.

### _dataByNoteByCharacter

```solidity
mapping(uint256 => mapping(uint256 => struct CharacterNoteData)) _dataByNoteByCharacter
```

### constructor

```solidity
constructor(address web3Entry) public
```

### initializeMintModule

```solidity
function initializeMintModule(uint256 characterId, uint256 noteId, bytes data) external returns (bytes)
```

### processMint

```solidity
function processMint(address to, uint256 characterId, uint256 noteId, bytes data) external
```

Processes the mint logic by charging a fee.
Triggered when the `mintNote` of web3Entry  is called, if mint module of note if set.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address |  |
| characterId | uint256 | ID of character. |
| noteId | uint256 | ID of note. |
| data | bytes | The mintModuleData passed by user who called the `mintNote` of web3Entry . |

### getNoteData

```solidity
function getNoteData(uint256 characterId, uint256 noteId) external view returns (struct CharacterNoteData)
```

Returns the associated data for a given note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character to query. |
| noteId | uint256 | ID of note to query. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct CharacterNoteData | Returns the associated data for a given  note. |

