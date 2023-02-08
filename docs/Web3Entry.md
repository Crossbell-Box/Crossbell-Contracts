# Solidity API

## Web3Entry

### _operatorsPermissionBitMap

```solidity
mapping(uint256 => mapping(address => uint256)) _operatorsPermissionBitMap
```

### _operators4Note

```solidity
mapping(uint256 => mapping(uint256 => struct DataTypes.Operators4Note)) _operators4Note
```

### grantOperatorPermissions

```solidity
function grantOperatorPermissions(uint256 characterId, address operator, uint256 permissionBitMap) external
```

Grant an address as an operator and authorize it with custom permissions.

_Every bit in permissionBitMap stands for a corresponding method in Web3Entry. more details in OP.sol._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of your character that you want to authorize. |
| operator | address | Address to grant operator permissions to. |
| permissionBitMap | uint256 | Bitmap used for finer grained operator permissions controls. |

### grantOperators4Note

```solidity
function grantOperators4Note(uint256 characterId, uint256 noteId, address[] blocklist, address[] allowlist) external
```

Grant operators allowlist and blocklist roles of a note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character that you want to set. |
| noteId | uint256 | ID of note that you want to set. |
| blocklist | address[] | blocklist addresses that you want to grant. |
| allowlist | address[] | allowlist addresses that you want to grant. |

### getOperatorPermissions

```solidity
function getOperatorPermissions(uint256 characterId, address operator) external view returns (uint256)
```

Get permission bitmap of an operator.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character that you want to check. |
| operator | address | Address to grant operator permissions to. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Permission bitmap of this operator. |

### getOperators4Note

```solidity
function getOperators4Note(uint256 characterId, uint256 noteId) external view returns (address[] blocklist, address[] allowlist)
```

Get operators blocklist and allowlist for a note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character to query. |
| noteId | uint256 | ID of note to query. |

### isOperatorAllowedForNote

```solidity
function isOperatorAllowedForNote(uint256 characterId, uint256 noteId, address operator) external view returns (bool)
```

Query if a operator has permission for a note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character that you want to query. |
| noteId | uint256 | ID of note that you want to query. |
| operator | address | Address to query. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | true if Operator has permission for a note, otherwise false. |

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

_Operator lists will be reset to blank before the characters are transferred in order to grant the
whole control power to receivers of character transfers.
Permissions4Note is left unset, because permissions for notes are always stricter than default._

### _clearOperator

```solidity
function _clearOperator(uint256 tokenId, address operator) internal
```

### _isOperatorAllowedForNote

```solidity
function _isOperatorAllowedForNote(uint256 characterId, uint256 noteId, address operator) internal view returns (bool)
```

### _validateCallerPermission

```solidity
function _validateCallerPermission(uint256 characterId, uint256 permissionId) internal view
```

### _callerIsCharacterOwner

```solidity
function _callerIsCharacterOwner(uint256 characterId) internal view returns (bool)
```

### _validateCallerPermission4Note

```solidity
function _validateCallerPermission4Note(uint256 characterId, uint256 noteId) internal view
```

### _checkBit

```solidity
function _checkBit(uint256 x, uint256 i) internal pure returns (bool)
```

__checkBit checks if the value of the i'th bit of x is 1_

