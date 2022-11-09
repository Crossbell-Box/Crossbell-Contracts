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
function _setCharacterUri(uint256 profileId, string newUri) internal
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
function setHandle(uint256 characterId, string newHandle) external
```

### setSocialToken

```solidity
function setSocialToken(uint256 characterId, address tokenAddress) external
```

### setCharacterUri

```solidity
function setCharacterUri(uint256 characterId, string newUri) external
```

### setPrimaryCharacterId

```solidity
function setPrimaryCharacterId(uint256 characterId) external
```

### setOperator

```solidity
function setOperator(uint256 characterId, address operator) external
```

### addOperator

```solidity
function addOperator(uint256, address) external virtual
```

### removeOperator

```solidity
function removeOperator(uint256, address) external virtual
```

### isOperator

```solidity
function isOperator(uint256, address) external view virtual returns (bool)
```

### getOperators

```solidity
function getOperators(uint256) external view virtual returns (address[])
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

### _createThenLinkCharacter

```solidity
function _createThenLinkCharacter(uint256 fromCharacterId, address to, bytes32 linkType, bytes data) internal
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

### setLinkModule4Character

```solidity
function setLinkModule4Character(struct DataTypes.setLinkModule4CharacterData vars) external
```

### setLinkModule4Note

```solidity
function setLinkModule4Note(struct DataTypes.setLinkModule4NoteData vars) external
```

### setLinkModule4Linklist

```solidity
function setLinkModule4Linklist(struct DataTypes.setLinkModule4LinklistData vars) external
```

### setLinkModule4ERC721

```solidity
function setLinkModule4ERC721(struct DataTypes.setLinkModule4ERC721Data vars) external
```

Set linkModule for a ERC721 token that you own.

_Operators can't setLinkModule4ERC721, because operators are set for characters but erc721 tokens belong to address and not characters._

### setLinkModule4Address

```solidity
function setLinkModule4Address(struct DataTypes.setLinkModule4AddressData vars) external
```

Set linkModule for an address.

_Operators can't setLinkModule4Address, because this linkModule is for addresses and is irrelevan to characters._

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

### burn

```solidity
function burn(uint256 tokenId) public
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

### getOperator

```solidity
function getOperator(uint256 characterId) external view returns (address)
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

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

_Hook that is called before any token transfer. This includes minting
and burning.

Calling conditions:

- When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
transferred to `to`.
- When `from` is zero, `tokenId` will be minted for `to`.
- When `to` is zero, ``from``'s `tokenId` will be burned.
- `from` cannot be the zero address.
- `to` cannot be the zero address.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

### _setOperator

```solidity
function _setOperator(uint256 characterId, address operator) internal
```

### _validateCallerIsCharacterOwnerOrOperator

```solidity
function _validateCallerIsCharacterOwnerOrOperator(uint256 characterId) internal view virtual
```

_This is a virtual function and it doesn't check anything, so you should complete validating logic in inheritance contracts that use this Web3EntryBase contract as parent contract._

### _validateCallerIsLinklistOwnerOrOperator

```solidity
function _validateCallerIsLinklistOwnerOrOperator(uint256 noteId) internal view virtual
```

### _validateCallerIsCharacterOwner

```solidity
function _validateCallerIsCharacterOwner(uint256 characterId) internal view
```

### _validateCallerIsLinklistOwner

```solidity
function _validateCallerIsLinklistOwner(uint256 tokenId) internal view
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

