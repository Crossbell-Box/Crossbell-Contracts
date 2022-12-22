# Solidity API

## OperatorLogic

### grantOperatorPermissions

```solidity
function grantOperatorPermissions(uint256 characterId, address operator, uint256 permissionBitMap, mapping(uint256 => struct EnumerableSet.AddressSet) _operatorsByCharacter, mapping(uint256 => mapping(address => uint256)) _operatorsPermissionBitMap) external
```

### grantOperators4Note

```solidity
function grantOperators4Note(uint256 characterId, uint256 noteId, address[] blocklist, address[] allowlist, mapping(uint256 => mapping(uint256 => struct DataTypes.Operators4Note)) _operators4Note) external
```

### revokeOperators4Note

```solidity
function revokeOperators4Note(uint256 characterId, uint256 noteId, address[] blocklist, address[] allowlist, mapping(uint256 => mapping(uint256 => struct DataTypes.Operators4Note)) _operators4Note) external
```

### _bitmapFilter

```solidity
function _bitmapFilter(uint256 bitmap) internal pure returns (uint256)
```

__bitmapFilter unsets bits of non-existent permission IDs to zero. These unset permission IDs are
     meaningless now, but they are reserved for future use, so it's best to leave them blank and avoid messing
      up with future methods._

