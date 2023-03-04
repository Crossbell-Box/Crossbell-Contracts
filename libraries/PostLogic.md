# Solidity API

## PostLogic

### postNoteWithLink

```solidity
function postNoteWithLink(struct DataTypes.PostNoteData vars, uint256 noteId, bytes32 linkItemType, bytes32 linkKey, bytes data, mapping(uint256 => mapping(uint256 => struct DataTypes.Note)) _noteByIdByCharacter) external
```

### mintNote

```solidity
function mintNote(uint256 characterId, uint256 noteId, address to, bytes mintModuleData, address mintNFTImpl, mapping(uint256 => struct DataTypes.Character) _characterById, mapping(uint256 => mapping(uint256 => struct DataTypes.Note)) _noteByIdByCharacter) external returns (uint256 tokenId)
```

### setNoteUri

```solidity
function setNoteUri(uint256 characterId, uint256 noteId, string newUri, mapping(uint256 => mapping(uint256 => struct DataTypes.Note)) _noteByIdByCharacter) external
```

### _deployMintNFT

```solidity
function _deployMintNFT(uint256 characterId, uint256 noteId, string handle, address mintNFTImpl) internal returns (address)
```

