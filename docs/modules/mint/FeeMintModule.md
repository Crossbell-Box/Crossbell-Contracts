# Solidity API

## CharacterNoteData

```solidity
struct CharacterNoteData {
  uint256 amount;
  address currency;
  address recipient;
}
```

## FeeMintModule

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

### getNoteData

```solidity
function getNoteData(uint256 characterId, uint256 noteId) external view returns (struct CharacterNoteData)
```

