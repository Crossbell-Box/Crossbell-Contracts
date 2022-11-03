# Solidity API

## LinkModuleLogic

### setLinkModule4Note

```solidity
function setLinkModule4Note(uint256 characterId, uint256 noteId, address linkModule, bytes linkModuleInitData, mapping(uint256 => mapping(uint256 => struct DataTypes.Note)) _noteByIdByCharacter) external
```

### setLinkModule4Address

```solidity
function setLinkModule4Address(address account, address linkModule, bytes linkModuleInitData, mapping(address => address) _linkModules4Address) external
```

### setMintModule4Note

```solidity
function setMintModule4Note(uint256 characterId, uint256 noteId, address mintModule, bytes mintModuleInitData, mapping(uint256 => mapping(uint256 => struct DataTypes.Note)) _noteByIdByCharacter) external
```

### setLinkModule4Linklist

```solidity
function setLinkModule4Linklist(uint256 linklistId, address linkModule, bytes linkModuleInitData, mapping(uint256 => address) _linkModules4Linklist) external
```

### setLinkModule4ERC721

```solidity
function setLinkModule4ERC721(address tokenAddress, uint256 tokenId, address linkModule, bytes linkModuleInitData, mapping(address => mapping(uint256 => address)) _linkModules4ERC721) external
```

