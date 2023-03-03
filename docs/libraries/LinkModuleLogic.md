# Solidity API

## LinkModuleLogic

### setLinkModule4Note

```solidity
function setLinkModule4Note(uint256 characterId, uint256 noteId, address linkModule, bytes linkModuleInitData, mapping(uint256 => mapping(uint256 => struct DataTypes.Note)) _noteByIdByCharacter) external
```

Sets link module for a given note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The character id to set link module for. |
| noteId | uint256 | The note id to set link module for. |
| linkModule | address | The link module to set. |
| linkModuleInitData | bytes | The data to pass to the link module for initialization, if any. |
| _noteByIdByCharacter | mapping(uint256 &#x3D;&gt; mapping(uint256 &#x3D;&gt; struct DataTypes.Note)) |  |

### setLinkModule4Address

```solidity
function setLinkModule4Address(address account, address linkModule, bytes linkModuleInitData, mapping(address => address) _linkModules4Address) external
```

Sets link module for a given address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The address to set link module for. |
| linkModule | address | The link module to set. |
| linkModuleInitData | bytes | The data to pass to the link module for initialization, if any. |
| _linkModules4Address | mapping(address &#x3D;&gt; address) |  |

### setMintModule4Note

```solidity
function setMintModule4Note(uint256 characterId, uint256 noteId, address mintModule, bytes mintModuleInitData, mapping(uint256 => mapping(uint256 => struct DataTypes.Note)) _noteByIdByCharacter) external
```

Sets the mint module for a given note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The character id of note to set the mint module for. |
| noteId | uint256 | The note id of note. |
| mintModule | address | The mint module to set for note. |
| mintModuleInitData | bytes | The data to pass to the mint module. |
| _noteByIdByCharacter | mapping(uint256 &#x3D;&gt; mapping(uint256 &#x3D;&gt; struct DataTypes.Note)) |  |

### setLinkModule4Linklist

```solidity
function setLinkModule4Linklist(uint256 linklistId, address linkModule, bytes linkModuleInitData, mapping(uint256 => address) _linkModules4Linklist) external
```

Sets link module for a given linklist.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| linklistId | uint256 | The linklist id to set link module for. |
| linkModule | address | The link module to set. |
| linkModuleInitData | bytes | The data to pass to the link module for initialization, if any. |
| _linkModules4Linklist | mapping(uint256 &#x3D;&gt; address) |  |

### setLinkModule4ERC721

```solidity
function setLinkModule4ERC721(address tokenAddress, uint256 tokenId, address linkModule, bytes linkModuleInitData, mapping(address => mapping(uint256 => address)) _linkModules4ERC721) external
```

Sets link module for a given ERC721 token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenAddress | address | The token address of erc721 to set link module for. |
| tokenId | uint256 | The token id of erc721 to set link module for. |
| linkModule | address | The link module to set. |
| linkModuleInitData | bytes | The data to pass to the link module for initialization, if any. |
| _linkModules4ERC721 | mapping(address &#x3D;&gt; mapping(uint256 &#x3D;&gt; address)) |  |

