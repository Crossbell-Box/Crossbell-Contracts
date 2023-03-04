# FeeMintModule
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/4ba4e225416bca003567c0e6ae31b9c6258df17e/contracts/modules/mint/FeeMintModule.sol)

**Inherits:**
[IMintModule4Note](/contracts/interfaces/IMintModule4Note.sol/contract.IMintModule4Note.md), [ModuleBase](/contracts/modules/ModuleBase.sol/contract.ModuleBase.md)

This is a simple MintModule implementation, inheriting from the IMintModule4Note interface.


## State Variables
### _dataByNoteByCharacter

```solidity
mapping(uint256 => mapping(uint256 => CharacterNoteData)) internal _dataByNoteByCharacter;
```


## Functions
### constructor


```solidity
constructor(address web3Entry_) ModuleBase(web3Entry_);
```

### initializeMintModule


```solidity
function initializeMintModule(uint256 characterId, uint256 noteId, bytes calldata data)
    external
    override
    onlyWeb3Entry
    returns (bytes memory);
```

### processMint

Processes the mint logic by charging a fee.
Triggered when the `mintNote` of web3Entry  is called, if mint module of note if set.


```solidity
function processMint(address to, uint256 characterId, uint256 noteId, bytes calldata data)
    external
    override
    onlyWeb3Entry;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`||
|`characterId`|`uint256`|ID of character.|
|`noteId`|`uint256`|ID of note.|
|`data`|`bytes`|The mintModuleData passed by user who called the `mintNote` of web3Entry .|


### getNoteData

Returns the associated data for a given note.

*onlyWeb3Entry can call `processMint`*


```solidity
function getNoteData(uint256 characterId, uint256 noteId) external view returns (CharacterNoteData memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterId`|`uint256`|ID of character to query.|
|`noteId`|`uint256`| ID of note to query.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`CharacterNoteData`|Returns the associated data for a given  note.|


