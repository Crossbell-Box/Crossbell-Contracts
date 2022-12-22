# Solidity API

## IWeb3Entry

### initialize

```solidity
function initialize(string _name, string _symbol, address _linklistContract, address _mintNFTImpl, address _periphery, address resolver) external
```

### createCharacter

```solidity
function createCharacter(struct DataTypes.CreateCharacterData vars) external
```

EXTERNAL VIEW FUNCTIONS

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

### grantOperatorPermissions

```solidity
function grantOperatorPermissions(uint256 characterId, address operator, uint256 permissionBitMap) external
```

### grantOperators4Note

```solidity
function grantOperators4Note(uint256 characterId, uint256 noteId, address[] blocklist, address[] allowlist) external
```

### revokeOperators4Note

```solidity
function revokeOperators4Note(uint256 characterId, uint256 noteId, address[] blocklist, address[] allowlist) external
```

### setLinklistUri

```solidity
function setLinklistUri(uint256 linkListId, string uri) external
```

### linkAddress

```solidity
function linkAddress(struct DataTypes.linkAddressData vars) external
```

### unlinkAddress

```solidity
function unlinkAddress(struct DataTypes.unlinkAddressData vars) external
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

### setLinkModule4Address

```solidity
function setLinkModule4Address(struct DataTypes.setLinkModule4AddressData vars) external
```

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

VIEW FUNCTIONS

### getOperatorPermissions

```solidity
function getOperatorPermissions(uint256 characterId, address operator) external view returns (uint256)
```

### getOperators4Note

```solidity
function getOperators4Note(uint256 characterId, uint256 noteId) external view returns (address[] blocklist, address[] allowlist)
```

### hasNotePermission

```solidity
function hasNotePermission(uint256 characterId, uint256 noteId, address operator) external view returns (bool)
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

