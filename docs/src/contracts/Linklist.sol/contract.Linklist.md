# Linklist
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/d7930db5cd89d52737395aa81b0ec583ccadb80c/contracts/Linklist.sol)

**Inherits:**
[ILinklist](/contracts/interfaces/ILinklist.sol/contract.ILinklist.md), [NFTBase](/contracts/base/NFTBase.sol/contract.NFTBase.md), [LinklistStorage](/contracts/storage/LinklistStorage.sol/contract.LinklistStorage.md), Initializable, [LinklistExtendStorage](/contracts/storage/LinklistExtendStorage.sol/contract.LinklistExtendStorage.md)


## Functions
### initialize


```solidity
function initialize(string calldata name_, string calldata symbol_, address web3Entry_) external override initializer;
```

### mint


```solidity
function mint(uint256 characterId, bytes32 linkType) external override returns (uint256 tokenId);
```

### setUri

Set URI for a linklist. You can set any URI for your linklist, and the functionality of this URI
is undetermined and expandable. One scenario that comes to mind is setting a cover for your liked notes
or following list in your bookmarks.


```solidity
function setUri(uint256 tokenId, string memory newUri) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`| Linklist ID.|
|`newUri`|`string`| Any URI.|


### addLinkingCharacterId


```solidity
function addLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external override;
```

### removeLinkingCharacterId


```solidity
function removeLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external override;
```

### addLinkingNote


```solidity
function addLinkingNote(uint256 tokenId, uint256 toCharacterId, uint256 toNoteId) external override returns (bytes32);
```

### removeLinkingNote


```solidity
function removeLinkingNote(uint256 tokenId, uint256 toCharacterId, uint256 toNoteId) external override;
```

### addLinkingCharacterLink


```solidity
function addLinkingCharacterLink(uint256 tokenId, DataTypes.CharacterLinkStruct calldata linkData) external override;
```

### removeLinkingCharacterLink


```solidity
function removeLinkingCharacterLink(uint256 tokenId, DataTypes.CharacterLinkStruct calldata linkData)
    external
    override;
```

### addLinkingERC721


```solidity
function addLinkingERC721(uint256 tokenId, address tokenAddress, uint256 erc721TokenId)
    external
    override
    returns (bytes32);
```

### removeLinkingERC721


```solidity
function removeLinkingERC721(uint256 tokenId, address tokenAddress, uint256 erc721TokenId) external override;
```

### addLinkingAddress


```solidity
function addLinkingAddress(uint256 tokenId, address ethAddress) external override;
```

### removeLinkingAddress


```solidity
function removeLinkingAddress(uint256 tokenId, address ethAddress) external override;
```

### addLinkingAnyUri


```solidity
function addLinkingAnyUri(uint256 tokenId, string memory toUri) external override returns (bytes32);
```

### removeLinkingAnyUri


```solidity
function removeLinkingAnyUri(uint256 tokenId, string memory toUri) external override;
```

### addLinkingLinklistId


```solidity
function addLinkingLinklistId(uint256 tokenId, uint256 linklistId) external override;
```

### removeLinkingLinklistId


```solidity
function removeLinkingLinklistId(uint256 tokenId, uint256 linklistId) external override;
```

### getLinkingCharacterIds


```solidity
function getLinkingCharacterIds(uint256 tokenId) external view override returns (uint256[] memory);
```

### getLinkingCharacterListLength


```solidity
function getLinkingCharacterListLength(uint256 tokenId) external view override returns (uint256);
```

### getOwnerCharacterId


```solidity
function getOwnerCharacterId(uint256 tokenId) external view override returns (uint256);
```

### getLinkingNotes


```solidity
function getLinkingNotes(uint256 tokenId) external view override returns (DataTypes.NoteStruct[] memory results);
```

### getLinkingNote


```solidity
function getLinkingNote(bytes32 linkKey) external view override returns (DataTypes.NoteStruct memory);
```

### getLinkingNoteListLength


```solidity
function getLinkingNoteListLength(uint256 tokenId) external view override returns (uint256);
```

### getLinkingCharacterLinks


```solidity
function getLinkingCharacterLinks(uint256 tokenId)
    external
    view
    override
    returns (DataTypes.CharacterLinkStruct[] memory results);
```

### getLinkingCharacterLink


```solidity
function getLinkingCharacterLink(bytes32 linkKey)
    external
    view
    override
    returns (DataTypes.CharacterLinkStruct memory);
```

### getLinkingCharacterLinkListLength


```solidity
function getLinkingCharacterLinkListLength(uint256 tokenId) external view override returns (uint256);
```

### getLinkingERC721s


```solidity
function getLinkingERC721s(uint256 tokenId) external view override returns (DataTypes.ERC721Struct[] memory results);
```

### getLinkingERC721


```solidity
function getLinkingERC721(bytes32 linkKey) external view override returns (DataTypes.ERC721Struct memory);
```

### getLinkingERC721ListLength


```solidity
function getLinkingERC721ListLength(uint256 tokenId) external view override returns (uint256);
```

### getLinkingAddresses


```solidity
function getLinkingAddresses(uint256 tokenId) external view override returns (address[] memory);
```

### getLinkingAddressListLength


```solidity
function getLinkingAddressListLength(uint256 tokenId) external view override returns (uint256);
```

### getLinkingAnyUris


```solidity
function getLinkingAnyUris(uint256 tokenId) external view override returns (string[] memory results);
```

### getLinkingAnyUri


```solidity
function getLinkingAnyUri(bytes32 linkKey) external view override returns (string memory);
```

### getLinkingAnyUriKeys


```solidity
function getLinkingAnyUriKeys(uint256 tokenId) external view override returns (bytes32[] memory);
```

### getLinkingAnyListLength


```solidity
function getLinkingAnyListLength(uint256 tokenId) external view override returns (uint256);
```

### getLinkingLinklistIds


```solidity
function getLinkingLinklistIds(uint256 tokenId) external view override returns (uint256[] memory);
```

### getLinkingLinklistLength


```solidity
function getLinkingLinklistLength(uint256 tokenId) external view override returns (uint256);
```

### getCurrentTakeOver


```solidity
function getCurrentTakeOver(uint256 tokenId) external view override returns (uint256 characterId);
```

### getLinkType


```solidity
function getLinkType(uint256 tokenId) external view override returns (bytes32);
```

### Uri


```solidity
function Uri(uint256 tokenId) external view override returns (string memory);
```

### totalSupply


```solidity
function totalSupply() public view override returns (uint256);
```

### balanceOf


```solidity
function balanceOf(uint256 characterId) public view override returns (uint256);
```

### balanceOf


```solidity
function balanceOf(address account) public view override(IERC721, ERC721) returns (uint256 balance);
```

### characterOwnerOf

returns the characterId who owns the given tokenId.


```solidity
function characterOwnerOf(uint256 tokenId) public view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The token id of the linklist.|


### ownerOf


```solidity
function ownerOf(uint256 tokenId) public view override(IERC721, ERC721) returns (address);
```

### _getTokenUri


```solidity
function _getTokenUri(uint256 tokenId) internal view returns (string memory);
```

### _validateCallerIsWeb3Entry


```solidity
function _validateCallerIsWeb3Entry() internal view;
```

### _validateCallerIsWeb3EntryOrOwner


```solidity
function _validateCallerIsWeb3EntryOrOwner(uint256 tokenId) internal view;
```

### _safeTransfer


```solidity
function _safeTransfer(address, address, uint256, bytes memory) internal pure override;
```

### _transfer


```solidity
function _transfer(address, address, uint256) internal pure override;
```

## Events
### Transfer

```solidity
event Transfer(address indexed from, uint256 indexed characterId, uint256 indexed tokenId);
```

