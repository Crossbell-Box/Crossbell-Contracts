# Solidity API

## Linklist

### Transfer

```solidity
event Transfer(address from, uint256 characterId, uint256 tokenId)
```

### initialize

```solidity
function initialize(string name_, string symbol_, address web3Entry_) external
```

### mint

```solidity
function mint(uint256 characterId, bytes32 linkType, uint256 tokenId) external
```

### setUri

```solidity
function setUri(uint256 tokenId, string newUri) external
```

### addLinkingCharacterId

```solidity
function addLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external
```

### removeLinkingCharacterId

```solidity
function removeLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external
```

### addLinkingNote

```solidity
function addLinkingNote(uint256 tokenId, uint256 toCharacterId, uint256 toNoteId) external returns (bytes32)
```

### removeLinkingNote

```solidity
function removeLinkingNote(uint256 tokenId, uint256 toCharacterId, uint256 toNoteId) external
```

### addLinkingCharacterLink

```solidity
function addLinkingCharacterLink(uint256 tokenId, struct DataTypes.CharacterLinkStruct linkData) external
```

### removeLinkingCharacterLink

```solidity
function removeLinkingCharacterLink(uint256 tokenId, struct DataTypes.CharacterLinkStruct linkData) external
```

### addLinkingERC721

```solidity
function addLinkingERC721(uint256 tokenId, address tokenAddress, uint256 erc721TokenId) external returns (bytes32)
```

### removeLinkingERC721

```solidity
function removeLinkingERC721(uint256 tokenId, address tokenAddress, uint256 erc721TokenId) external
```

### addLinkingAddress

```solidity
function addLinkingAddress(uint256 tokenId, address ethAddress) external
```

### removeLinkingAddress

```solidity
function removeLinkingAddress(uint256 tokenId, address ethAddress) external
```

### addLinkingAnyUri

```solidity
function addLinkingAnyUri(uint256 tokenId, string toUri) external returns (bytes32)
```

### removeLinkingAnyUri

```solidity
function removeLinkingAnyUri(uint256 tokenId, string toUri) external
```

### addLinkingLinklistId

```solidity
function addLinkingLinklistId(uint256 tokenId, uint256 linklistId) external
```

### removeLinkingLinklistId

```solidity
function removeLinkingLinklistId(uint256 tokenId, uint256 linklistId) external
```

### getLinkingCharacterIds

```solidity
function getLinkingCharacterIds(uint256 tokenId) external view returns (uint256[])
```

### getLinkingCharacterListLength

```solidity
function getLinkingCharacterListLength(uint256 tokenId) external view returns (uint256)
```

### getOwnerCharacterId

```solidity
function getOwnerCharacterId(uint256 tokenId) external view returns (uint256)
```

### getLinkingNotes

```solidity
function getLinkingNotes(uint256 tokenId) external view returns (struct DataTypes.NoteStruct[] results)
```

### getLinkingNote

```solidity
function getLinkingNote(bytes32 linkKey) external view returns (struct DataTypes.NoteStruct)
```

### getLinkingNoteListLength

```solidity
function getLinkingNoteListLength(uint256 tokenId) external view returns (uint256)
```

### getLinkingCharacterLinks

```solidity
function getLinkingCharacterLinks(uint256 tokenId) external view returns (struct DataTypes.CharacterLinkStruct[] results)
```

### getLinkingCharacterLink

```solidity
function getLinkingCharacterLink(bytes32 linkKey) external view returns (struct DataTypes.CharacterLinkStruct)
```

### getLinkingCharacterLinkListLength

```solidity
function getLinkingCharacterLinkListLength(uint256 tokenId) external view returns (uint256)
```

### getLinkingERC721s

```solidity
function getLinkingERC721s(uint256 tokenId) external view returns (struct DataTypes.ERC721Struct[] results)
```

### getLinkingERC721

```solidity
function getLinkingERC721(bytes32 linkKey) external view returns (struct DataTypes.ERC721Struct)
```

### getLinkingERC721ListLength

```solidity
function getLinkingERC721ListLength(uint256 tokenId) external view returns (uint256)
```

### getLinkingAddresses

```solidity
function getLinkingAddresses(uint256 tokenId) external view returns (address[])
```

### getLinkingAddressListLength

```solidity
function getLinkingAddressListLength(uint256 tokenId) external view returns (uint256)
```

### getLinkingAnyUris

```solidity
function getLinkingAnyUris(uint256 tokenId) external view returns (string[] results)
```

### getLinkingAnyUri

```solidity
function getLinkingAnyUri(bytes32 linkKey) external view returns (string)
```

### getLinkingAnyUriKeys

```solidity
function getLinkingAnyUriKeys(uint256 tokenId) external view returns (bytes32[])
```

### getLinkingAnyListLength

```solidity
function getLinkingAnyListLength(uint256 tokenId) external view returns (uint256)
```

### getLinkingLinklistIds

```solidity
function getLinkingLinklistIds(uint256 tokenId) external view returns (uint256[])
```

### getLinkingLinklistLength

```solidity
function getLinkingLinklistLength(uint256 tokenId) external view returns (uint256)
```

### getCurrentTakeOver

```solidity
function getCurrentTakeOver(uint256 tokenId) external view returns (uint256 characterId)
```

### getLinkType

```solidity
function getLinkType(uint256 tokenId) external view returns (bytes32)
```

### Uri

```solidity
function Uri(uint256 tokenId) external view returns (string)
```

### totalSupply

```solidity
function totalSupply() public view returns (uint256)
```

_See {IERC721Enumerable-totalSupply}._

### balanceOf

```solidity
function balanceOf(uint256 characterId) public view returns (uint256)
```

### balanceOf

```solidity
function balanceOf(address account) public view returns (uint256 balance)
```

### characterOwnerOf

```solidity
function characterOwnerOf(uint256 tokenId) public view returns (uint256)
```

returns the characterId who owns the given tokenId.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The token id of the linklist. |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) public view returns (address)
```

### _getTokenUri

```solidity
function _getTokenUri(uint256 tokenId) internal view returns (string)
```

### _validateCallerIsWeb3Entry

```solidity
function _validateCallerIsWeb3Entry() internal view
```

### _validateCallerIsWeb3EntryOrOwner

```solidity
function _validateCallerIsWeb3EntryOrOwner(uint256 tokenId) internal view
```

### _safeTransfer

```solidity
function _safeTransfer(address, address, uint256, bytes) internal pure
```

### _transfer

```solidity
function _transfer(address, address, uint256) internal pure
```

