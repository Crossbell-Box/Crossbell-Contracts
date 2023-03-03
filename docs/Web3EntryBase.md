# Solidity API

## Web3EntryBase

### REVISION

```solidity
uint256 REVISION
```

### initialize

```solidity
function initialize(string name_, string symbol_, address linklist_, address mintNFTImpl_, address periphery_, address newbieVilla_) external
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

### createCharacter

```solidity
function createCharacter(struct DataTypes.CreateCharacterData vars) external returns (uint256 characterId)
```

This method creates a character with the given parameters to the given address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| vars | struct DataTypes.CreateCharacterData | The CreateCharacterData struct containing the following parameters:      * to: The address receiving the character.      * handle: The handle to set for the character.      * uri: The URI to set for the character metadata.      * linkModule: The link module to use, can be the zero address.      * linkModuleInitData: The link module initialization data, if any. |

### setHandle

```solidity
function setHandle(uint256 characterId, string newHandle) external
```

Sets new handle for a given character.

_Owner permission only._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The character id to set new handle for. |
| newHandle | string | New handle to set. |

### setSocialToken

```solidity
function setSocialToken(uint256 characterId, address tokenAddress) external
```

Sets a social token for a given character.

_Owner permission only._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The characterId to set social token for. |
| tokenAddress | address | Token address to be set. |

### setPrimaryCharacterId

```solidity
function setPrimaryCharacterId(uint256 characterId) external
```

Sets a given character as primary.

_Owner permission only._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The character id to to be set. |

### setCharacterUri

```solidity
function setCharacterUri(uint256 characterId, string newUri) external
```

Sets a new URI for a given character.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The characterId to to be set. |
| newUri | string | New URI to be set. |

### setLinklistUri

```solidity
function setLinklistUri(uint256 linklistId, string uri) external
```

Sets a new metadataURI for a given link list..

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| linklistId | uint256 |  |
| uri | string | The metadata uri to set. |

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

### setLinkModule4Linklist

```solidity
function setLinkModule4Linklist(struct DataTypes.setLinkModule4LinklistData vars) external
```

Set linkModule for a ERC721 token that you own.

_Operators can't setLinkModule4ERC721, because operators are set for 
     characters but erc721 tokens belong to address and not characters._

### setLinkModule4Address

```solidity
function setLinkModule4Address(struct DataTypes.setLinkModule4AddressData vars) external
```

Set linkModule for an address.

_Operators can't setLinkModule4Address, because this linkModule is for 
     addresses and is irrelevant to characters._

### mintNote

```solidity
function mintNote(struct DataTypes.MintNoteData vars) external returns (uint256 tokenId)
```

### setMintModule4Note

```solidity
function setMintModule4Note(struct DataTypes.setMintModule4NoteData vars) external
```

### postNote

```solidity
function postNote(struct DataTypes.PostNoteData vars) external returns (uint256 noteId)
```

### setNoteUri

```solidity
function setNoteUri(uint256 characterId, uint256 noteId, string newUri) external
```

Set URI for a note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The character ID of the note owner. |
| noteId | uint256 | The ID of the note to set. |
| newUri | string | The new URI. |

### lockNote

```solidity
function lockNote(uint256 characterId, uint256 noteId) external
```

Lock a note and put it into a immutable state where no modifications are 
     allowed. Locked notes are usually assumed as final versions.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The character ID of the note owner. |
| noteId | uint256 | The ID of the note to lock. |

### deleteNote

```solidity
function deleteNote(uint256 characterId, uint256 noteId) external
```

Delete a note.

_Deleting a note doesn't essentially mean that the txs or contents are being removed due to the
      immutability of blockchain itself, but the deleted notes will be tagged as `deleted` after calling `deleteNote`._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The character ID of the note owner. |
| noteId | uint256 | The ID of the note to delete. |

### postNote4Character

```solidity
function postNote4Character(struct DataTypes.PostNoteData vars, uint256 toCharacterId) external returns (uint256)
```

### postNote4Address

```solidity
function postNote4Address(struct DataTypes.PostNoteData vars, address ethAddress) external returns (uint256)
```

### postNote4Linklist

```solidity
function postNote4Linklist(struct DataTypes.PostNoteData vars, uint256 toLinklistId) external returns (uint256)
```

### postNote4Note

```solidity
function postNote4Note(struct DataTypes.PostNoteData vars, struct DataTypes.NoteStruct note) external returns (uint256)
```

### postNote4ERC721

```solidity
function postNote4ERC721(struct DataTypes.PostNoteData vars, struct DataTypes.ERC721Struct erc721) external returns (uint256)
```

### postNote4AnyUri

```solidity
function postNote4AnyUri(struct DataTypes.PostNoteData vars, string uri) external returns (uint256)
```

### getOperators

```solidity
function getOperators(uint256 characterId) external view returns (address[])
```

Get operator list of a character. This operator list has only a sole purpose, which is
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

### getPrimaryCharacterId

```solidity
function getPrimaryCharacterId(address account) external view returns (uint256)
```

### isPrimaryCharacter

```solidity
function isPrimaryCharacter(uint256 characterId) external view returns (bool)
```

### getCharacter

```solidity
function getCharacter(uint256 characterId) external view returns (struct DataTypes.Character)
```

### getCharacterByHandle

```solidity
function getCharacterByHandle(string handle) external view returns (struct DataTypes.Character)
```

### getHandle

```solidity
function getHandle(uint256 characterId) external view returns (string)
```

### getCharacterUri

```solidity
function getCharacterUri(uint256 characterId) external view returns (string)
```

### getNote

```solidity
function getNote(uint256 characterId, uint256 noteId) external view returns (struct DataTypes.Note)
```

### getLinkModule4Address

```solidity
function getLinkModule4Address(address account) external view returns (address)
```

### getLinkModule4Linklist

```solidity
function getLinkModule4Linklist(uint256 tokenId) external view returns (address)
```

### getLinkModule4ERC721

```solidity
function getLinkModule4ERC721(address tokenAddress, uint256 tokenId) external view returns (address)
```

### getLinklistUri

```solidity
function getLinklistUri(uint256 tokenId) external view returns (string)
```

### getLinklistId

```solidity
function getLinklistId(uint256 characterId, bytes32 linkType) external view returns (uint256)
```

### getLinklistType

```solidity
function getLinklistType(uint256 linkListId) external view returns (bytes32)
```

### getLinklistContract

```solidity
function getLinklistContract() external view returns (address)
```

### getRevision

```solidity
function getRevision() external pure returns (uint256)
```

### burn

```solidity
function burn(uint256 tokenId) public virtual
```

### tokenURI

```solidity
function tokenURI(uint256 characterId) public view returns (string)
```

### _createThenLinkCharacter

```solidity
function _createThenLinkCharacter(uint256 fromCharacterId, address to, bytes32 linkType, bytes data) internal
```

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

_Operators will be reset to blank before the characters are transferred in order to grant the
whole control power to receivers of character transfers.
If character is transferred from newbieVilla contract, don't clear operators.

Permissions4Note is left unset, because permissions for notes are always stricter than default._

### _afterTokenTransfer

```solidity
function _afterTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

_Hook that is called after any transfer of tokens. This includes
minting and burning.

Calling conditions:

- when `from` and `to` are both non-zero.
- `from` and `to` are never both zero.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

### _nextNoteId

```solidity
function _nextNoteId(uint256 characterId) internal returns (uint256)
```

### _clearOperator

```solidity
function _clearOperator(uint256 tokenId, address operator) internal
```

### _isOperatorAllowedForNote

```solidity
function _isOperatorAllowedForNote(uint256 characterId, uint256 noteId, address operator) internal view returns (bool)
```

### _checkHandleExists

```solidity
function _checkHandleExists(bytes32 handleHash) internal view
```

### _validateCallerIsCharacterOwner

```solidity
function _validateCallerIsCharacterOwner(uint256 characterId) internal view
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

### _validateCharacterExists

```solidity
function _validateCharacterExists(uint256 characterId) internal view
```

### _validateNoteExists

```solidity
function _validateNoteExists(uint256 characterId, uint256 noteId) internal view
```

### _validateNoteNotLocked

```solidity
function _validateNoteNotLocked(uint256 characterId, uint256 noteId) internal view
```

### _validateHandle

```solidity
function _validateHandle(string handle) internal pure
```

### _validateChar

```solidity
function _validateChar(bytes1 c) internal pure
```

### _checkBit

```solidity
function _checkBit(uint256 x, uint256 i) internal pure returns (bool)
```

__checkBit checks if the value of the i'th bit of x is 1_

