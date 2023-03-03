# ILinklist
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/7dd103c70343d6410d08f7bb25b0b513c4d92016/contracts/interfaces/ILinklist.sol)


## Functions
### initialize


```solidity
function initialize(string calldata name_, string calldata symbol_, address web3Entry_) external;
```

### mint


```solidity
function mint(uint256 characterId, bytes32 linkType) external returns (uint256 tokenId);
```

### setUri


```solidity
function setUri(uint256 tokenId, string memory newUri) external;
```

### addLinkingCharacterId


```solidity
function addLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external;
```

### removeLinkingCharacterId


```solidity
function removeLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external;
```

### addLinkingNote


```solidity
function addLinkingNote(uint256 tokenId, uint256 toCharacterId, uint256 toNoteId) external returns (bytes32);
```

### removeLinkingNote


```solidity
function removeLinkingNote(uint256 tokenId, uint256 toCharacterId, uint256 toNoteId) external;
```

### addLinkingERC721


```solidity
function addLinkingERC721(uint256 tokenId, address tokenAddress, uint256 erc721TokenId) external returns (bytes32);
```

### removeLinkingERC721


```solidity
function removeLinkingERC721(uint256 tokenId, address tokenAddress, uint256 erc721TokenId) external;
```

### addLinkingAddress


```solidity
function addLinkingAddress(uint256 tokenId, address ethAddress) external;
```

### removeLinkingAddress


```solidity
function removeLinkingAddress(uint256 tokenId, address ethAddress) external;
```

### addLinkingAnyUri


```solidity
function addLinkingAnyUri(uint256 tokenId, string memory toUri) external returns (bytes32);
```

### removeLinkingAnyUri


```solidity
function removeLinkingAnyUri(uint256 tokenId, string memory toUri) external;
```

### addLinkingLinklistId


```solidity
function addLinkingLinklistId(uint256 tokenId, uint256 linklistId) external;
```

### removeLinkingLinklistId


```solidity
function removeLinkingLinklistId(uint256 tokenId, uint256 linklistId) external;
```

### addLinkingCharacterLink


```solidity
function addLinkingCharacterLink(uint256 tokenId, DataTypes.CharacterLinkStruct calldata linkData) external;
```

### removeLinkingCharacterLink


```solidity
function removeLinkingCharacterLink(uint256 tokenId, DataTypes.CharacterLinkStruct calldata linkData) external;
```

### getLinkingCharacterIds


```solidity
function getLinkingCharacterIds(uint256 tokenId) external view returns (uint256[] memory);
```

### getLinkingCharacterListLength


```solidity
function getLinkingCharacterListLength(uint256 tokenId) external view returns (uint256);
```

### getOwnerCharacterId


```solidity
function getOwnerCharacterId(uint256 tokenId) external view returns (uint256);
```

### getLinkingNotes


```solidity
function getLinkingNotes(uint256 tokenId) external view returns (DataTypes.NoteStruct[] memory results);
```

### getLinkingNote


```solidity
function getLinkingNote(bytes32 linkKey) external view returns (DataTypes.NoteStruct memory);
```

### getLinkingNoteListLength


```solidity
function getLinkingNoteListLength(uint256 tokenId) external view returns (uint256);
```

### getLinkingCharacterLinks


```solidity
function getLinkingCharacterLinks(uint256 tokenId)
    external
    view
    returns (DataTypes.CharacterLinkStruct[] memory results);
```

### getLinkingCharacterLink


```solidity
function getLinkingCharacterLink(bytes32 linkKey) external view returns (DataTypes.CharacterLinkStruct memory);
```

### getLinkingCharacterLinkListLength


```solidity
function getLinkingCharacterLinkListLength(uint256 tokenId) external view returns (uint256);
```

### getLinkingERC721s


```solidity
function getLinkingERC721s(uint256 tokenId) external view returns (DataTypes.ERC721Struct[] memory results);
```

### getLinkingERC721


```solidity
function getLinkingERC721(bytes32 linkKey) external view returns (DataTypes.ERC721Struct memory);
```

### getLinkingERC721ListLength


```solidity
function getLinkingERC721ListLength(uint256 tokenId) external view returns (uint256);
```

### getLinkingAddresses


```solidity
function getLinkingAddresses(uint256 tokenId) external view returns (address[] memory);
```

### getLinkingAddressListLength


```solidity
function getLinkingAddressListLength(uint256 tokenId) external view returns (uint256);
```

### getLinkingAnyUris


```solidity
function getLinkingAnyUris(uint256 tokenId) external view returns (string[] memory results);
```

### getLinkingAnyUri


```solidity
function getLinkingAnyUri(bytes32 linkKey) external view returns (string memory);
```

### getLinkingAnyUriKeys


```solidity
function getLinkingAnyUriKeys(uint256 tokenId) external view returns (bytes32[] memory);
```

### getLinkingAnyListLength


```solidity
function getLinkingAnyListLength(uint256 tokenId) external view returns (uint256);
```

### getLinkingLinklistIds


```solidity
function getLinkingLinklistIds(uint256 tokenId) external view returns (uint256[] memory);
```

### getLinkingLinklistLength


```solidity
function getLinkingLinklistLength(uint256 tokenId) external view returns (uint256);
```

### getCurrentTakeOver


```solidity
function getCurrentTakeOver(uint256 tokenId) external view returns (uint256);
```

### getLinkType


```solidity
function getLinkType(uint256 tokenId) external view returns (bytes32);
```

### Uri


```solidity
function Uri(uint256 tokenId) external view returns (string memory);
```

### characterOwnerOf


```solidity
function characterOwnerOf(uint256 tokenId) external view returns (uint256);
```

### balanceOf


```solidity
function balanceOf(uint256 characterId) external view returns (uint256);
```

