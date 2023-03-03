# LinkModuleLogic
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/1bc9213c7fb7853b038310c6b20bef0fd2cf388b/contracts/libraries/LinkModuleLogic.sol)


## Functions
### setLinkModule4Note


```solidity
function setLinkModule4Note(
    uint256 characterId,
    uint256 noteId,
    address linkModule,
    bytes calldata linkModuleInitData,
    mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
) external;
```

### setLinkModule4Address


```solidity
function setLinkModule4Address(
    address account,
    address linkModule,
    bytes calldata linkModuleInitData,
    mapping(address => address) storage _linkModules4Address
) external;
```

### setMintModule4Note


```solidity
function setMintModule4Note(
    uint256 characterId,
    uint256 noteId,
    address mintModule,
    bytes calldata mintModuleInitData,
    mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
) external;
```

### setLinkModule4Linklist


```solidity
function setLinkModule4Linklist(
    uint256 linklistId,
    address linkModule,
    bytes calldata linkModuleInitData,
    mapping(uint256 => address) storage _linkModules4Linklist
) external;
```

### setLinkModule4ERC721


```solidity
function setLinkModule4ERC721(
    address tokenAddress,
    uint256 tokenId,
    address linkModule,
    bytes calldata linkModuleInitData,
    mapping(address => mapping(uint256 => address)) storage _linkModules4ERC721
) external;
```

