# IWeb3Entry
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/182c82c216a4cf11409d4311d9773152bbe60ccf/contracts/interfaces/IWeb3Entry.sol)


## Functions
### initialize


```solidity
function initialize(
    string calldata name_,
    string calldata symbol_,
    address linklist_,
    address mintNFTImpl_,
    address periphery_,
    address newbieVilla_
) external;
```

### createCharacter

EXTERNAL  FUNCTIONS


```solidity
function createCharacter(DataTypes.CreateCharacterData calldata vars) external returns (uint256 characterId);
```

### setHandle


```solidity
function setHandle(uint256 characterId, string calldata newHandle) external;
```

### setSocialToken


```solidity
function setSocialToken(uint256 characterId, address tokenAddress) external;
```

### setCharacterUri


```solidity
function setCharacterUri(uint256 characterId, string calldata newUri) external;
```

### setPrimaryCharacterId


```solidity
function setPrimaryCharacterId(uint256 characterId) external;
```

### grantOperatorPermissions


```solidity
function grantOperatorPermissions(uint256 characterId, address operator, uint256 permissionBitMap) external;
```

### grantOperators4Note


```solidity
function grantOperators4Note(
    uint256 characterId,
    uint256 noteId,
    address[] calldata blocklist,
    address[] calldata allowlist
) external;
```

### setLinklistUri


```solidity
function setLinklistUri(uint256 linkListId, string calldata uri) external;
```

### linkAddress


```solidity
function linkAddress(DataTypes.linkAddressData calldata vars) external;
```

### unlinkAddress


```solidity
function unlinkAddress(DataTypes.unlinkAddressData calldata vars) external;
```

### linkCharacter


```solidity
function linkCharacter(DataTypes.linkCharacterData calldata vars) external;
```

### unlinkCharacter


```solidity
function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars) external;
```

### createThenLinkCharacter


```solidity
function createThenLinkCharacter(DataTypes.createThenLinkCharacterData calldata vars) external;
```

### linkNote


```solidity
function linkNote(DataTypes.linkNoteData calldata vars) external;
```

### unlinkNote


```solidity
function unlinkNote(DataTypes.unlinkNoteData calldata vars) external;
```

### linkERC721


```solidity
function linkERC721(DataTypes.linkERC721Data calldata vars) external;
```

### unlinkERC721


```solidity
function unlinkERC721(DataTypes.unlinkERC721Data calldata vars) external;
```

### linkAnyUri


```solidity
function linkAnyUri(DataTypes.linkAnyUriData calldata vars) external;
```

### unlinkAnyUri


```solidity
function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars) external;
```

### linkLinklist


```solidity
function linkLinklist(DataTypes.linkLinklistData calldata vars) external;
```

### unlinkLinklist


```solidity
function unlinkLinklist(DataTypes.unlinkLinklistData calldata vars) external;
```

### setLinkModule4Linklist


```solidity
function setLinkModule4Linklist(DataTypes.setLinkModule4LinklistData calldata vars) external;
```

### setLinkModule4Address


```solidity
function setLinkModule4Address(DataTypes.setLinkModule4AddressData calldata vars) external;
```

### mintNote


```solidity
function mintNote(DataTypes.MintNoteData calldata vars) external returns (uint256 tokenId);
```

### setMintModule4Note


```solidity
function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external;
```

### postNote


```solidity
function postNote(DataTypes.PostNoteData calldata postNoteData) external returns (uint256 noteId);
```

### setNoteUri


```solidity
function setNoteUri(uint256 characterId, uint256 noteId, string calldata newUri) external;
```

### lockNote


```solidity
function lockNote(uint256 characterId, uint256 noteId) external;
```

### deleteNote


```solidity
function deleteNote(uint256 characterId, uint256 noteId) external;
```

### postNote4Character


```solidity
function postNote4Character(DataTypes.PostNoteData calldata vars, uint256 toCharacterId) external returns (uint256);
```

### postNote4Address


```solidity
function postNote4Address(DataTypes.PostNoteData calldata vars, address ethAddress) external returns (uint256);
```

### postNote4Linklist


```solidity
function postNote4Linklist(DataTypes.PostNoteData calldata vars, uint256 toLinklistId) external returns (uint256);
```

### postNote4Note


```solidity
function postNote4Note(DataTypes.PostNoteData calldata vars, DataTypes.NoteStruct calldata note)
    external
    returns (uint256);
```

### postNote4ERC721


```solidity
function postNote4ERC721(DataTypes.PostNoteData calldata vars, DataTypes.ERC721Struct calldata erc721)
    external
    returns (uint256);
```

### postNote4AnyUri


```solidity
function postNote4AnyUri(DataTypes.PostNoteData calldata vars, string calldata uri) external returns (uint256);
```

### getOperators

VIEW FUNCTIONS


```solidity
function getOperators(uint256 characterId) external view returns (address[] memory);
```

### getOperatorPermissions


```solidity
function getOperatorPermissions(uint256 characterId, address operator) external view returns (uint256);
```

### getOperators4Note


```solidity
function getOperators4Note(uint256 characterId, uint256 noteId)
    external
    view
    returns (address[] memory blocklist, address[] memory allowlist);
```

### isOperatorAllowedForNote


```solidity
function isOperatorAllowedForNote(uint256 characterId, uint256 noteId, address operator) external view returns (bool);
```

### getPrimaryCharacterId


```solidity
function getPrimaryCharacterId(address account) external view returns (uint256);
```

### isPrimaryCharacter


```solidity
function isPrimaryCharacter(uint256 characterId) external view returns (bool);
```

### getCharacter


```solidity
function getCharacter(uint256 characterId) external view returns (DataTypes.Character memory);
```

### getCharacterByHandle


```solidity
function getCharacterByHandle(string calldata handle) external view returns (DataTypes.Character memory);
```

### getHandle


```solidity
function getHandle(uint256 characterId) external view returns (string memory);
```

### getCharacterUri


```solidity
function getCharacterUri(uint256 characterId) external view returns (string memory);
```

### getNote


```solidity
function getNote(uint256 characterId, uint256 noteId) external view returns (DataTypes.Note memory);
```

### getLinkModule4Address


```solidity
function getLinkModule4Address(address account) external view returns (address);
```

### getLinkModule4Linklist


```solidity
function getLinkModule4Linklist(uint256 tokenId) external view returns (address);
```

### getLinkModule4ERC721


```solidity
function getLinkModule4ERC721(address tokenAddress, uint256 tokenId) external view returns (address);
```

### getLinklistUri


```solidity
function getLinklistUri(uint256 tokenId) external view returns (string memory);
```

### getLinklistId


```solidity
function getLinklistId(uint256 characterId, bytes32 linkType) external view returns (uint256);
```

### getLinklistType


```solidity
function getLinklistType(uint256 linkListId) external view returns (bytes32);
```

### getLinklistContract


```solidity
function getLinklistContract() external view returns (address);
```

### getRevision


```solidity
function getRevision() external pure returns (uint256);
```

