# LinkLogic
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/34b32749a8bd5815fbe2026db07c401bb7f54d20/contracts/libraries/LinkLogic.sol)


## Functions
### linkCharacter


```solidity
function linkCharacter(
    uint256 fromCharacterId,
    uint256 toCharacterId,
    bytes32 linkType,
    bytes memory data,
    address linklist,
    address linkModule,
    mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
) external;
```

### unlinkCharacter


```solidity
function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars, address linklist, uint256 linklistId) external;
```

### linkNote


```solidity
function linkNote(
    DataTypes.linkNoteData calldata vars,
    address linklist,
    address linkModule,
    mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
) external;
```

### unlinkNote


```solidity
function unlinkNote(
    DataTypes.unlinkNoteData calldata vars,
    address linklist,
    mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
) external;
```

### linkCharacterLink


```solidity
function linkCharacterLink(
    uint256 fromCharacterId,
    DataTypes.CharacterLinkStruct calldata linkData,
    bytes32 linkType,
    address linklist,
    mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
) external;
```

### unlinkCharacterLink


```solidity
function unlinkCharacterLink(
    uint256 fromCharacterId,
    DataTypes.CharacterLinkStruct calldata linkData,
    bytes32 linkType,
    address linklist,
    uint256 linklistId
) external;
```

### linkLinklist


```solidity
function linkLinklist(
    DataTypes.linkLinklistData calldata vars,
    address linklist,
    mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
) external;
```

### unlinkLinklist


```solidity
function unlinkLinklist(DataTypes.unlinkLinklistData calldata vars, address linklist, uint256 linklistId) external;
```

### linkERC721


```solidity
function linkERC721(
    DataTypes.linkERC721Data calldata vars,
    address linklist,
    mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
) external;
```

### unlinkERC721


```solidity
function unlinkERC721(DataTypes.unlinkERC721Data calldata vars, address linklist, uint256 linklistId) external;
```

### linkAddress


```solidity
function linkAddress(
    DataTypes.linkAddressData calldata vars,
    address linklist,
    mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
) external;
```

### unlinkAddress


```solidity
function unlinkAddress(DataTypes.unlinkAddressData calldata vars, address linklist, uint256 linklistId) external;
```

### linkAnyUri


```solidity
function linkAnyUri(
    DataTypes.linkAnyUriData calldata vars,
    address linklist,
    mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
) external;
```

### unlinkAnyUri


```solidity
function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars, address linklist, uint256 linklistId) external;
```

### _mintLinklist

Returns the linklistId if the linklist already exists, Otherwise, creates a new
linklist and return its ID.


```solidity
function _mintLinklist(
    uint256 fromCharacterId,
    bytes32 linkType,
    address linklist,
    mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
) internal returns (uint256 linklistId);
```

