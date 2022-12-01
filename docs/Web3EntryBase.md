# Solidity API

## Web3EntryBase

### REVISION

```solidity
uint256 REVISION
```

### initialize

```solidity
function initialize(string _name, string _symbol, address _linklistContract, address _mintNFTImpl, address _periphery, address _resolver) external
```

### _setCharacterUri

```solidity
function _setCharacterUri(uint256, string) public virtual
```

### createCharacter

```solidity
function createCharacter(struct DataTypes.CreateCharacterData vars) external
```

This method creates a character with the given parameters to the given address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| vars | struct DataTypes.CreateCharacterData | The CreateCharacterData struct containing the following parameters:      * to: The address receiving the character.      * handle: The handle to set for the character.      * uri: The URI to set for the character metadata.      * linkModule: The link module to use, can be the zero address.      * linkModuleInitData: The link module initialization data, if any. |

### _createCharacter

```solidity
function _createCharacter(struct DataTypes.CreateCharacterData vars) internal
```

### setHandle

```solidity
function setHandle(uint256, string) external virtual
```

### setSocialToken

```solidity
function setSocialToken(uint256, address) external virtual
```

### setPrimaryCharacterId

```solidity
function setPrimaryCharacterId(uint256 characterId) external
```

### setCharacterUri

```solidity
function setCharacterUri(uint256 characterId, string newUri) external
```

### grantOperatorPermissions

```solidity
function grantOperatorPermissions(uint256, address, uint256) external virtual
```

### grantOperatorPermissions4Note

```solidity
function grantOperatorPermissions4Note(uint256, uint256, address, uint256) external virtual
```

### setLinklistUri

```solidity
function setLinklistUri(uint256, string) external virtual
```

### linkCharacter

```solidity
function linkCharacter(struct DataTypes.linkCharacterData) external virtual
```

### unlinkCharacter

```solidity
function unlinkCharacter(struct DataTypes.unlinkCharacterData) external virtual
```

### createThenLinkCharacter

```solidity
function createThenLinkCharacter(struct DataTypes.createThenLinkCharacterData) external virtual
```

### _createThenLinkCharacter

```solidity
function _createThenLinkCharacter(uint256 fromCharacterId, address to, bytes32 linkType, bytes data) internal
```

### linkNote

```solidity
function linkNote(struct DataTypes.linkNoteData) external virtual
```

### unlinkNote

```solidity
function unlinkNote(struct DataTypes.unlinkNoteData) external virtual
```

### linkERC721

```solidity
function linkERC721(struct DataTypes.linkERC721Data) external virtual
```

### unlinkERC721

```solidity
function unlinkERC721(struct DataTypes.unlinkERC721Data) external virtual
```

### linkAddress

```solidity
function linkAddress(struct DataTypes.linkAddressData) external virtual
```

### unlinkAddress

```solidity
function unlinkAddress(struct DataTypes.unlinkAddressData) external virtual
```

### linkAnyUri

```solidity
function linkAnyUri(struct DataTypes.linkAnyUriData) external virtual
```

### unlinkAnyUri

```solidity
function unlinkAnyUri(struct DataTypes.unlinkAnyUriData) external virtual
```

### linkLinklist

```solidity
function linkLinklist(struct DataTypes.linkLinklistData) external virtual
```

### unlinkLinklist

```solidity
function unlinkLinklist(struct DataTypes.unlinkLinklistData) external virtual
```

### setLinkModule4Linklist

```solidity
function setLinkModule4Linklist(struct DataTypes.setLinkModule4LinklistData) external virtual
```

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
function setMintModule4Note(struct DataTypes.setMintModule4NoteData) external virtual
```

### postNote

```solidity
function postNote(struct DataTypes.PostNoteData) external virtual returns (uint256)
```

### setNoteUri

```solidity
function setNoteUri(uint256, uint256, string) external virtual
```

### lockNote

```solidity
function lockNote(uint256, uint256) external virtual
```

lockNote put a note into a immutable state where no modifications are 
     allowed. You should call this method to announce that this is the final version.

### deleteNote

```solidity
function deleteNote(uint256, uint256) external virtual
```

### postNote4Character

```solidity
function postNote4Character(struct DataTypes.PostNoteData, uint256) external virtual returns (uint256)
```

### postNote4Address

```solidity
function postNote4Address(struct DataTypes.PostNoteData, address) external virtual returns (uint256)
```

### postNote4Linklist

```solidity
function postNote4Linklist(struct DataTypes.PostNoteData, uint256) external virtual returns (uint256)
```

### postNote4Note

```solidity
function postNote4Note(struct DataTypes.PostNoteData, struct DataTypes.NoteStruct) external virtual returns (uint256)
```

### postNote4ERC721

```solidity
function postNote4ERC721(struct DataTypes.PostNoteData, struct DataTypes.ERC721Struct) external virtual returns (uint256)
```

### postNote4AnyUri

```solidity
function postNote4AnyUri(struct DataTypes.PostNoteData, string) external virtual returns (uint256)
```

### burn

```solidity
function burn(uint256 tokenId) public
```

### getOperators

```solidity
function getOperators(uint256) external view virtual returns (address[])
```

### getOperatorPermissions4Note

```solidity
function getOperatorPermissions4Note(uint256, uint256, address) external view virtual returns (uint256)
```

### getOperatorPermissions

```solidity
function getOperatorPermissions(uint256, address) external view virtual returns (uint256)
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

### tokenURI

```solidity
function tokenURI(uint256 characterId) public view returns (string)
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

### _validateCallerIsCharacterOwner

```solidity
function _validateCallerIsCharacterOwner(uint256 characterId) internal view
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

### getRevision

```solidity
function getRevision() external pure returns (uint256)
```

### isOperator

```solidity
function isOperator(uint256 characterId, address operator) external view virtual returns (bool)
```

### addOperator

```solidity
function addOperator(uint256 characterId, address operator) external virtual
```

### removeOperator

```solidity
function removeOperator(uint256 characterId, address operator) external virtual
```

### setOperator

```solidity
function setOperator(uint256 characterId, address operator) external virtual
```

