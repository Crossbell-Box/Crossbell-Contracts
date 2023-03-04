# ApprovalLinkModule4Note
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/301046e95eacfa631ca751822adb220cbb30103a/contracts/modules/link/ApprovalLinkModule4Note.sol)

**Inherits:**
[ILinkModule4Note](/contracts/interfaces/ILinkModule4Note.sol/contract.ILinkModule4Note.md), [ModuleBase](/contracts/modules/ModuleBase.sol/contract.ModuleBase.md)

This is a simple LinkModule implementation, inheriting from the ILinkModule4Note interface.


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

### initializeLinkModule


```solidity
function initializeLinkModule(uint256 characterId, uint256 noteId, bytes calldata data)
    external
    override
    returns (bytes memory);
```

### approve


```solidity
function approve(uint256 characterId, uint256 noteId, address[] calldata addresses, bool[] calldata toApprove)
    external;
```

### processLink


```solidity
function processLink(address caller, uint256 characterId, uint256 noteId, bytes calldata)
    external
    view
    override
    onlyWeb3Entry;
```

### isApproved


```solidity
function isApproved(address characterOwner, uint256 characterId, uint256 noteId, address toCheck)
    external
    view
    returns (bool);
```

