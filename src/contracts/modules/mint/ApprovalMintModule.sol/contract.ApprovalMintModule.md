# ApprovalMintModule
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/c7f31e42711569b1cb499ae27680e91d1ff85e00/contracts/modules/mint/ApprovalMintModule.sol)

**Inherits:**
[IMintModule4Note](/contracts/interfaces/IMintModule4Note.sol/contract.IMintModule4Note.md), [ModuleBase](/contracts/modules/ModuleBase.sol/contract.ModuleBase.md)

This is a simple MintModule implementation, inheriting from the IMintModule4Note interface.


## State Variables
### _approvedByCharacterByNoteByOwner

```solidity
mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => bool)))) internal
    _approvedByCharacterByNoteByOwner;
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
    returns (bytes memory);
```

### approve

The owner of specified note can call this function,
to approve accounts to mint specified note.


```solidity
function approve(uint256 characterId, uint256 noteId, address[] calldata addresses, bool[] calldata toApprove)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterId`|`uint256`|ID of character.|
|`noteId`|`uint256`|ID of note.|
|`addresses`|`address[]`|Address to set.|
|`toApprove`|`bool[]`|To approve or revoke.|


### processMint

Processes the mint logic.
Triggered when the `mintNote` of web3Entry is called, if mint module of note if set.


```solidity
function processMint(address to, uint256 characterId, uint256 noteId, bytes calldata)
    external
    view
    override
    onlyWeb3Entry;
```

### isApproved

Checks whether the `account` is approved to mint specified note .


```solidity
function isApproved(address characterOwner, uint256 characterId, uint256 noteId, address account)
    external
    view
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterOwner`|`address`|Address of character owner.|
|`characterId`|`uint256`|ID of character to query.|
|`noteId`|`uint256`| ID of note to query.|
|`account`|`address`|Address of account to query.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Returns true if the `account` is approved to mint, otherwise returns false.|


