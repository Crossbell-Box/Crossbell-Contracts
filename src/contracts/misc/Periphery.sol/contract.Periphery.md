# Periphery
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/1bc9213c7fb7853b038310c6b20bef0fd2cf388b/contracts/misc/Periphery.sol)

**Inherits:**
Initializable


## State Variables
### web3Entry

```solidity
address public web3Entry;
```


### linklist

```solidity
address public linklist;
```


## Functions
### initialize


```solidity
function initialize(address web3Entry_, address linklist_) external initializer;
```

### linkCharactersInBatch


```solidity
function linkCharactersInBatch(DataTypes.linkCharactersInBatchData calldata vars) external;
```

### sync


```solidity
function sync(
    address account,
    string calldata handle,
    string calldata uri,
    address[] calldata toAddresses,
    bytes32 linkType
) external;
```

### migrate


```solidity
function migrate(DataTypes.MigrateData calldata vars) external;
```

### getNotesByCharacterId


```solidity
function getNotesByCharacterId(uint256 characterId, uint256 offset, uint256 limit)
    external
    view
    returns (DataTypes.Note[] memory results);
```

### getLinkingCharacterIds


```solidity
function getLinkingCharacterIds(uint256 fromCharacterId, bytes32 linkType)
    external
    view
    returns (uint256[] memory results);
```

### getLinkingNotes


```solidity
function getLinkingNotes(uint256 fromCharacterId, bytes32 linkType)
    external
    view
    returns (DataTypes.Note[] memory results);
```

### getLinkingNote


```solidity
function getLinkingNote(bytes32 linkKey) external view returns (DataTypes.NoteStruct memory);
```

### getLinkingERC721s


```solidity
function getLinkingERC721s(uint256 fromCharacterId, bytes32 linkType)
    external
    view
    returns (DataTypes.ERC721Struct[] memory results);
```

### getLinkingERC721


```solidity
function getLinkingERC721(bytes32 linkKey) external view returns (DataTypes.ERC721Struct memory);
```

### getLinkingAnyUris


```solidity
function getLinkingAnyUris(uint256 fromCharacterId, bytes32 linkType) external view returns (string[] memory results);
```

### getLinkingAnyUri


```solidity
function getLinkingAnyUri(bytes32 linkKey) external view returns (string memory);
```

### getLinkingAddresses


```solidity
function getLinkingAddresses(uint256 fromCharacterId, bytes32 linkType) external view returns (address[] memory);
```

### getLinkingLinklistIds


```solidity
function getLinkingLinklistIds(uint256 fromCharacterId, bytes32 linkType)
    external
    view
    returns (uint256[] memory linklistIds);
```

### getLinkingLinklistId


```solidity
function getLinkingLinklistId(bytes32 linkKey) external pure returns (uint256 linklistId);
```

### getLinkingAddress


```solidity
function getLinkingAddress(bytes32 linkKey) external pure returns (address);
```

### getLinkingCharacterId


```solidity
function getLinkingCharacterId(bytes32 linkKey) external pure returns (uint256 characterId);
```

### _migrate

*_migrate will not update handle if the target character already exists*


```solidity
function _migrate(
    address account,
    string memory handle,
    string memory uri,
    address[] memory toAddresses,
    bytes32 linkType
) internal;
```

### _exists


```solidity
function _exists(uint256 characterId) internal view returns (bool);
```

