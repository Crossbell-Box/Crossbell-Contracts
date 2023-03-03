# OperatorLogic
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/d7930db5cd89d52737395aa81b0ec583ccadb80c/contracts/libraries/OperatorLogic.sol)


## Functions
### grantOperatorPermissions


```solidity
function grantOperatorPermissions(
    uint256 characterId,
    address operator,
    uint256 permissionBitMap,
    mapping(uint256 => EnumerableSet.AddressSet) storage _operatorsByCharacter,
    mapping(uint256 => mapping(address => uint256)) storage _operatorsPermissionBitMap
) external;
```

### grantOperators4Note

Set blocklist and allowlist for a specific note. Blocklist and allowlist are overwritten every time.


```solidity
function grantOperators4Note(
    uint256 characterId,
    uint256 noteId,
    address[] calldata blocklist,
    address[] calldata allowlist,
    mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) storage _operators4Note
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterId`|`uint256`|The character Id of the note owner.|
|`noteId`|`uint256`|The note Id to grant.|
|`blocklist`|`address[]`|The addresses list of blocked operators.|
|`allowlist`|`address[]`|The addresses list of allowed operators.|
|`_operators4Note`|`mapping(uint256 => mapping(uint256 => Operators4Note.DataTypes))`||


### _clearOperators4Note


```solidity
function _clearOperators4Note(DataTypes.Operators4Note storage operators4Note) internal;
```

### _updateOperators4Note


```solidity
function _updateOperators4Note(
    DataTypes.Operators4Note storage operators4Note,
    address[] calldata blocklist,
    address[] calldata allowlist
) internal;
```

### _bitmapFilter

*_bitmapFilter unsets bits of non-existent permission IDs to zero.
These unset permission IDs are meaningless now, but they are reserved for future use,
so it's best to leave them blank and avoid messing up with future methods.*


```solidity
function _bitmapFilter(uint256 bitmap) internal pure returns (uint256);
```

