# Solidity API

## Web3EntryBase

### REVISION

```solidity
uint256 REVISION
```

### initialize

```solidity
function initialize(string name_, string symbol_, address linklist_, address mintNFTImpl_, address periphery_) external
```

### grantOperatorPermissions

```solidity
function grantOperatorPermissions(uint256, address, uint256) external virtual
```

### grantOperators4Note

```solidity
function grantOperators4Note(uint256 characterId, uint256 noteId, address[] blocklist, address[] allowlist) external virtual
```

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

### setSocialToken

```solidity
function setSocialToken(uint256 characterId, address tokenAddress) external
```

### setPrimaryCharacterId

```solidity
function setPrimaryCharacterId(uint256 characterId) external
```

### setCharacterUri

```solidity
function setCharacterUri(uint256 characterId, string newUri) external
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
     addresses and is irrelevan to characters._

### mintNote

```solidity
function mintNote(struct DataTypes.MintNoteData vars) external returns (uint256)
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

lockNote put a note into a immutable state where no modifications are 
     allowed. You should call this method to announce that this is the final version.

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
function getOperatorPermissions(uint256, address) external view virtual returns (uint256)
```

### getOperators4Note

```solidity
function getOperators4Note(uint256 characterId, uint256 noteId) external view virtual returns (address[] blocklist, address[] allowlist)
```

### isOperatorAllowedForNote

```solidity
function isOperatorAllowedForNote(uint256 characterId, uint256 noteId, address operator) external view virtual returns (bool)
```

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

### _validateCallerIsCharacterOwner

```solidity
function _validateCallerIsCharacterOwner(uint256 characterId) internal view
```

### _validateCallerPermission

```solidity
function _validateCallerPermission(uint256, uint256) internal view virtual
```

### _validateCallerPermission4Note

```solidity
function _validateCallerPermission4Note(uint256 characterId, uint256 noteId) internal view virtual
```

### _validateCharacterExists

```solidity
function _validateCharacterExists(uint256 characterId) internal view
```

### _validateERC721Exists

```solidity
function _validateERC721Exists(address tokenAddress, uint256 tokenId) internal view
```

### _validateNoteExists

```solidity
function _validateNoteExists(uint256 characterId, uint256 noteId) internal view
```

### _validateNoteNotLocked

```solidity
function _validateNoteNotLocked(uint256 characterId, uint256 noteId) internal view
```

