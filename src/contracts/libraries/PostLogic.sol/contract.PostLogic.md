# PostLogic
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/d7461dc986f92c02778fae6c468f62f2db6d2f91/contracts/libraries/PostLogic.sol)


## Functions
### postNoteWithLink


```solidity
function postNoteWithLink(
    DataTypes.PostNoteData calldata vars,
    uint256 noteId,
    bytes32 linkItemType,
    bytes32 linkKey,
    bytes calldata data,
    mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
) external;
```

### mintNote


```solidity
function mintNote(
    uint256 characterId,
    uint256 noteId,
    address to,
    bytes calldata mintModuleData,
    address mintNFTImpl,
    mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
) external returns (uint256 tokenId);
```

### setNoteUri


```solidity
function setNoteUri(
    uint256 characterId,
    uint256 noteId,
    string calldata newUri,
    mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
) external;
```

### _deployMintNFT


```solidity
function _deployMintNFT(uint256 characterId, uint256 noteId, address mintNFTImpl) internal returns (address mintNFT);
```

