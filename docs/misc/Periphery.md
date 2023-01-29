# Solidity API

## Periphery

### web3Entry

```solidity
address web3Entry
```

### _linklistInitialized

```solidity
bool _linklistInitialized
```

### linklist

```solidity
address linklist
```

### initialize

```solidity
function initialize(address web3Entry_, address linklist_) external
```

### linkCharactersInBatch

```solidity
function linkCharactersInBatch(struct DataTypes.linkCharactersInBatchData vars) external
```

### sync

```solidity
function sync(address account, string handle, string uri, address[] toAddresses, bytes32 linkType) external
```

### migrate

```solidity
function migrate(struct DataTypes.MigrateData vars) external
```

### getNotesByCharacterId

```solidity
function getNotesByCharacterId(uint256 characterId, uint256 offset, uint256 limit) external view returns (struct DataTypes.Note[] results)
```

### getLinkingCharacterIds

```solidity
function getLinkingCharacterIds(uint256 fromCharacterId, bytes32 linkType) external view returns (uint256[] results)
```

### getLinkingNotes

```solidity
function getLinkingNotes(uint256 fromCharacterId, bytes32 linkType) external view returns (struct DataTypes.Note[] results)
```

### getLinkingNote

```solidity
function getLinkingNote(bytes32 linkKey) external view returns (struct DataTypes.NoteStruct)
```

### getLinkingERC721s

```solidity
function getLinkingERC721s(uint256 fromCharacterId, bytes32 linkType) external view returns (struct DataTypes.ERC721Struct[] results)
```

### getLinkingERC721

```solidity
function getLinkingERC721(bytes32 linkKey) external view returns (struct DataTypes.ERC721Struct)
```

### getLinkingAnyUris

```solidity
function getLinkingAnyUris(uint256 fromCharacterId, bytes32 linkType) external view returns (string[] results)
```

### getLinkingAnyUri

```solidity
function getLinkingAnyUri(bytes32 linkKey) external view returns (string)
```

### getLinkingAddresses

```solidity
function getLinkingAddresses(uint256 fromCharacterId, bytes32 linkType) external view returns (address[])
```

### getLinkingLinklistIds

```solidity
function getLinkingLinklistIds(uint256 fromCharacterId, bytes32 linkType) external view returns (uint256[] linklistIds)
```

### getLinkingLinklistId

```solidity
function getLinkingLinklistId(bytes32 linkKey) external pure returns (uint256 linklistId)
```

### getLinkingAddress

```solidity
function getLinkingAddress(bytes32 linkKey) external pure returns (address)
```

### getLinkingCharacterId

```solidity
function getLinkingCharacterId(bytes32 linkKey) external pure returns (uint256 characterId)
```

### _migrate

```solidity
function _migrate(address account, string handle, string uri, address[] toAddresses, bytes32 linkType) internal
```

__migrate will not update handle if the target character already exists_

### _exists

```solidity
function _exists(uint256 characterId) internal view returns (bool)
```

