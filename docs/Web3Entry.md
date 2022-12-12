# Solidity API

## Web3Entry

### _operatorsPermissionBitMap

```solidity
mapping(uint256 => mapping(address => uint256)) _operatorsPermissionBitMap
```

### _operatorsPermission4NoteBitMap

```solidity
mapping(uint256 => mapping(uint256 => mapping(address => uint256))) _operatorsPermission4NoteBitMap
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

### grantOperatorPermissions4Note

```solidity
function grantOperatorPermissions4Note(uint256 characterId, uint256 noteId, address operator, uint256 permissionBitMap) external
```

Grant an address as an operator and authorize it with custom permissions for a single note.

_Every bit in permissionBitMap stands for a single note that this character posted.
The notes are open to all operators who are granted with note permissions by default, until the Permissions4Note are set.
With grantOperatorPermissions4Note, users can restrict permissions on individual notes,
for example: I authorize bob to set uri for my notes, but only for my third notes(noteId = 3)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of your character that you want to authorize. |
| noteId | uint256 | ID of your note that you want to authorize. |
| operator | address | Address to grant operator permissions to. |
| permissionBitMap | uint256 | an uint256 bitmap used for finer grained operator permissions controls over notes |

### migrateOperator

```solidity
function migrateOperator(uint256[] characterIds) external
```

Migrates operators permissions to operatorsSignBitMap

_`addOperator`, `removeOperator`, `setOperator` will all be deprecated soon. We recommend to use
 `migrateOperator` to grant OPERATOR_SIGN_PERMISSION_BITMAP to all previous operators._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterIds | uint256[] | List of characters to migrate. |

### isOperator

```solidity
function isOperator(uint256 characterId, address operator) external view returns (bool)
```

Check if an address is the operator of a character.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character to query. |
| operator | address | operator address to query. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | true if the address is the operator of a character, otherwise false. |

### addOperator

```solidity
function addOperator(uint256 characterId, address operator) external
```

### removeOperator

```solidity
function removeOperator(uint256 characterId, address operator) external
```

Cancel authorization on operators and remove them from operator list.

### setOperator

```solidity
function setOperator(uint256 characterId, address operator) external
```

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

### getOperatorPermissions4Note

```solidity
function getOperatorPermissions4Note(uint256 characterId, uint256 noteId, address operator) external view returns (uint256)
```

Get permission bitmap of an operator for a note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of character that you want to check. |
| noteId | uint256 | ID of note that you want to authorize. |
| operator | address | Address to grant operator permissions to. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | Permission bitmap of this operator. |

### _validateCallerPermission

```solidity
function _validateCallerPermission(uint256 characterId, uint256 permissionId) internal view
```

### _validateCallerPermission4Note

```solidity
function _validateCallerPermission4Note(uint256 characterId, uint256 noteId, uint256 permissionId) internal view
```

### _bitmapFilter

```solidity
function _bitmapFilter(uint256 bitmap) internal pure returns (uint256)
```

__bitmapFilter unsets bits of non-existent permission IDs to zero. These unset permission IDs are 
     meaningless now, but they are reserved for future use, so it's best to leave them blank and avoid messing
      up with future methods._

### _checkBit

```solidity
function _checkBit(uint256 x, uint256 i) internal pure returns (bool)
```

__checkBit checks if the value of the i'th bit of x is 1_

### _setOperatorPermissions

```solidity
function _setOperatorPermissions(uint256 characterId, address operator, uint256 permissionBitMap) internal
```

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

_Operator lists will be reset to blank before the characters are transferred in order to grant the
whole control power to receivers of character transfers.
Permissions4Note is left unset, because permissions for notes are always stricter than default._

