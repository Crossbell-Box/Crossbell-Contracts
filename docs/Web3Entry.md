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

### getOperators

```solidity
function getOperators(uint256 characterId) external view returns (address[])
```

Get operator list of a character. This operatorList has only a sole purpose, which is
keeping records of keys of `operatorsPermissionBitMap`. Thus, addresses queried by this function
not always have operator permissions. Keep in mind don't use this function to check
authorizations!!!

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | ID of your character that you want to check. |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address[] | All keys of operatorsPermission4NoteBitMap. |

### migrateOperator

```solidity
function migrateOperator(uint256[] characterIds) external
```

Migrates operators permissions to operatorsAuthBitMap

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

Get permission bitmap of an opertor.

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

### setHandle

```solidity
function setHandle(uint256 characterId, string newHandle) external
```

### setSocialToken

```solidity
function setSocialToken(uint256 characterId, address tokenAddress) external
```

### _setCharacterUri

```solidity
function _setCharacterUri(uint256 profileId, string newUri) public
```

### setLinklistUri

```solidity
function setLinklistUri(uint256 linklistId, string uri) external
```

### linkCharacter

```solidity
function linkCharacter(struct DataTypes.linkCharacterData vars) external
```

### unlinkCharacter

```solidity
function unlinkCharacter(struct DataTypes.unlinkCharacterData vars) external
```

### createThenLinkCharacter

```solidity
function createThenLinkCharacter(struct DataTypes.createThenLinkCharacterData vars) external
```

### linkNote

```solidity
function linkNote(struct DataTypes.linkNoteData vars) external
```

### unlinkNote

```solidity
function unlinkNote(struct DataTypes.unlinkNoteData vars) external
```

### linkERC721

```solidity
function linkERC721(struct DataTypes.linkERC721Data vars) external
```

### unlinkERC721

```solidity
function unlinkERC721(struct DataTypes.unlinkERC721Data vars) external
```

### linkAddress

```solidity
function linkAddress(struct DataTypes.linkAddressData vars) external
```

### unlinkAddress

```solidity
function unlinkAddress(struct DataTypes.unlinkAddressData vars) external
```

### linkAnyUri

```solidity
function linkAnyUri(struct DataTypes.linkAnyUriData vars) external
```

### unlinkAnyUri

```solidity
function unlinkAnyUri(struct DataTypes.unlinkAnyUriData vars) external
```

### linkLinklist

```solidity
function linkLinklist(struct DataTypes.linkLinklistData vars) external
```

### unlinkLinklist

```solidity
function unlinkLinklist(struct DataTypes.unlinkLinklistData vars) external
```

### setMintModule4Note

```solidity
function setMintModule4Note(struct DataTypes.setMintModule4NoteData vars) external
```

### postNote

```solidity
function postNote(struct DataTypes.PostNoteData vars) external returns (uint256)
```

### setNoteUri

```solidity
function setNoteUri(uint256 characterId, uint256 noteId, string newUri) external
```

### lockNote

```solidity
function lockNote(uint256 characterId, uint256 noteId) external
```

lockNote put a note into a immutable state where no modifications are allowed. You should call this method to announce that this is the final version.

### deleteNote

```solidity
function deleteNote(uint256 characterId, uint256 noteId) external
```

### postNote4Character

```solidity
function postNote4Character(struct DataTypes.PostNoteData postNoteData, uint256 toCharacterId) external returns (uint256)
```

### postNote4Address

```solidity
function postNote4Address(struct DataTypes.PostNoteData noteData, address ethAddress) external returns (uint256)
```

### postNote4Linklist

```solidity
function postNote4Linklist(struct DataTypes.PostNoteData noteData, uint256 toLinklistId) external returns (uint256)
```

### postNote4Note

```solidity
function postNote4Note(struct DataTypes.PostNoteData postNoteData, struct DataTypes.NoteStruct note) external returns (uint256)
```

### postNote4ERC721

```solidity
function postNote4ERC721(struct DataTypes.PostNoteData postNoteData, struct DataTypes.ERC721Struct erc721) external returns (uint256)
```

### postNote4AnyUri

```solidity
function postNote4AnyUri(struct DataTypes.PostNoteData postNoteData, string uri) external returns (uint256)
```

### _validateCallerPermission

```solidity
function _validateCallerPermission(uint256 characterId, uint256 permissionId) internal view
```

### _validateCallerPermission4Note

```solidity
function _validateCallerPermission4Note(uint256 characterId, uint256 noteId, uint256 permissionId) internal view
```

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

