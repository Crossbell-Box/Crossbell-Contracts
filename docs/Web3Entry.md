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

### migrateOwner

```solidity
address migrateOwner
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
function grantOperators4Note(uint256 characterId, uint256 noteId, address[] blacklist, address[] whitelist) external
```

Grant operators whitelist and blacklist roles of a note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character that you want to set. |
| noteId | uint256 | ID of note that you want to set. |
| blacklist | address[] | Blacklist addresses that you want to grant. |
| whitelist | address[] | Whitelist addresses that you want to grant. |

### revokeOperators4Note

```solidity
function revokeOperators4Note(uint256 characterId, uint256 noteId, address[] blacklist, address[] whitelist) external
```

Remove operators's blacklist and whitelist roles of a note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character that you want to set. |
| noteId | uint256 | ID of note that you want to set. |
| blacklist | address[] | Blacklist addresses that you want to remove. |
| whitelist | address[] | Whitelist addresses that you want to remove. |

### migrateOperator

```solidity
function migrateOperator(address newbieVilla, uint256[] characterIds) external
```

Migrates old operators permissions.

_set operators of newbieVilla DEFAULT_PERMISSION, and others OPERATOR_SYNC_PERMISSION.
This function should be removed in the next release._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| newbieVilla | address |  |
| characterIds | uint256[] | List of characters to migrate. |

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
function getOperators4Note(uint256 characterId, uint256 noteId) external view returns (address[] blacklist, address[] whitelist)
```

Get operators blacklist and whitelist for a note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character to query. |
| noteId | uint256 | ID of note to query. |

### hasNotePermission

```solidity
function hasNotePermission(uint256 characterId, uint256 noteId, address operator) external view returns (bool)
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

### _hasNotePermission

```solidity
function _hasNotePermission(uint256 characterId, uint256 noteId, address operator) internal view returns (bool)
```

### _validateCallerPermission

```solidity
function _validateCallerPermission(uint256 characterId, uint256 permissionId) internal view
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

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

_Operator lists will be reset to blank before the characters are transferred in order to grant the
whole control power to receivers of character transfers.
Permissions4Note is left unset, because permissions for notes are always stricter than default._

