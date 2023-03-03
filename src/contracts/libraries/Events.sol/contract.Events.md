# Events
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/3060ff9b47459c3bc54ac39115cb04b01451f340/contracts/libraries/Events.sol)


## Events
### BaseInitialized

```solidity
event BaseInitialized(string name, string symbol, uint256 timestamp);
```

### Web3EntryInitialized

```solidity
event Web3EntryInitialized(uint256 timestamp);
```

### LinklistNFTInitialized

```solidity
event LinklistNFTInitialized(uint256 timestamp);
```

### MintNFTInitialized

```solidity
event MintNFTInitialized(uint256 characterId, uint256 noteId, uint256 timestamp);
```

### CharacterCreated

```solidity
event CharacterCreated(
    uint256 indexed characterId, address indexed creator, address indexed to, string handle, uint256 timestamp
);
```

### SetPrimaryCharacterId

```solidity
event SetPrimaryCharacterId(address indexed account, uint256 indexed characterId, uint256 indexed oldCharacterId);
```

### SetHandle

```solidity
event SetHandle(address indexed account, uint256 indexed characterId, string newHandle);
```

### SetSocialToken

```solidity
event SetSocialToken(address indexed account, uint256 indexed characterId, address indexed tokenAddress);
```

### GrantOperatorPermissions

```solidity
event GrantOperatorPermissions(uint256 indexed characterId, address indexed operator, uint256 permissionBitMap);
```

### GrantOperators4Note

```solidity
event GrantOperators4Note(
    uint256 indexed characterId, uint256 indexed noteId, address[] blocklist, address[] allowlist
);
```

### SetCharacterUri

```solidity
event SetCharacterUri(uint256 indexed characterId, string newUri);
```

### PostNote

```solidity
event PostNote(
    uint256 indexed characterId, uint256 indexed noteId, bytes32 indexed linkKey, bytes32 linkItemType, bytes data
);
```

### SetNoteUri

```solidity
event SetNoteUri(uint256 indexed characterId, uint256 noteId, string newUri);
```

### DeleteNote

```solidity
event DeleteNote(uint256 indexed characterId, uint256 noteId);
```

### LockNote

```solidity
event LockNote(uint256 indexed characterId, uint256 noteId);
```

### LinkCharacter

```solidity
event LinkCharacter(
    address indexed account,
    uint256 indexed fromCharacterId,
    uint256 indexed toCharacterId,
    bytes32 linkType,
    uint256 linklistId
);
```

### UnlinkCharacter

```solidity
event UnlinkCharacter(
    address indexed account, uint256 indexed fromCharacterId, uint256 indexed toCharacterId, bytes32 linkType
);
```

### LinkNote

```solidity
event LinkNote(
    uint256 indexed fromCharacterId,
    uint256 indexed toCharacterId,
    uint256 indexed toNoteId,
    bytes32 linkType,
    uint256 linklistId
);
```

### UnlinkNote

```solidity
event UnlinkNote(
    uint256 indexed fromCharacterId,
    uint256 indexed toCharacterId,
    uint256 indexed toNoteId,
    bytes32 linkType,
    uint256 linklistId
);
```

### LinkERC721

```solidity
event LinkERC721(
    uint256 indexed fromCharacterId,
    address indexed tokenAddress,
    uint256 indexed toNoteId,
    bytes32 linkType,
    uint256 linklistId
);
```

### LinkAddress

```solidity
event LinkAddress(uint256 indexed fromCharacterId, address indexed ethAddress, bytes32 linkType, uint256 linklistId);
```

### UnlinkAddress

```solidity
event UnlinkAddress(uint256 indexed fromCharacterId, address indexed ethAddress, bytes32 linkType);
```

### LinkAnyUri

```solidity
event LinkAnyUri(uint256 indexed fromCharacterId, string toUri, bytes32 linkType, uint256 linklistId);
```

### UnlinkAnyUri

```solidity
event UnlinkAnyUri(uint256 indexed fromCharacterId, string toUri, bytes32 linkType);
```

### LinkCharacterLink

```solidity
event LinkCharacterLink(
    uint256 indexed fromCharacterId,
    bytes32 indexed linkType,
    uint256 clFromCharacterId,
    uint256 clToCharacterId,
    bytes32 clLinkType
);
```

### UnlinkCharacterLink

```solidity
event UnlinkCharacterLink(
    uint256 indexed fromCharacterId,
    bytes32 indexed linkType,
    uint256 clFromCharactereId,
    uint256 clToCharacterId,
    bytes32 clLinkType
);
```

### UnlinkERC721

```solidity
event UnlinkERC721(
    uint256 indexed fromCharacterId,
    address indexed tokenAddress,
    uint256 indexed toNoteId,
    bytes32 linkType,
    uint256 linklistId
);
```

### LinkLinklist

```solidity
event LinkLinklist(
    uint256 indexed fromCharacterId, uint256 indexed toLinklistId, bytes32 linkType, uint256 indexed linklistId
);
```

### UnlinkLinklist

```solidity
event UnlinkLinklist(
    uint256 indexed fromCharacterId, uint256 indexed toLinklistId, bytes32 linkType, uint256 indexed linklistId
);
```

### MintNote

```solidity
event MintNote(
    address indexed to, uint256 indexed characterId, uint256 indexed noteId, address tokenAddress, uint256 tokenId
);
```

### SetLinkModule4Character

```solidity
event SetLinkModule4Character(
    uint256 indexed characterId, address indexed linkModule, bytes returnData, uint256 timestamp
);
```

### SetLinkModule4Note

```solidity
event SetLinkModule4Note(
    uint256 indexed characterId, uint256 indexed noteId, address indexed linkModule, bytes returnData, uint256 timestamp
);
```

### SetLinkModule4Address

```solidity
event SetLinkModule4Address(address indexed account, address indexed linkModule, bytes returnData, uint256 timestamp);
```

### SetLinkModule4ERC721

```solidity
event SetLinkModule4ERC721(
    address indexed tokenAddress,
    uint256 indexed tokenId,
    address indexed linkModule,
    bytes returnData,
    uint256 timestamp
);
```

### SetLinkModule4Linklist

```solidity
event SetLinkModule4Linklist(
    uint256 indexed linklistId, address indexed linkModule, bytes returnData, uint256 timestamp
);
```

### SetMintModule4Note

```solidity
event SetMintModule4Note(
    uint256 indexed characterId, uint256 indexed noteId, address indexed mintModule, bytes returnData, uint256 timestamp
);
```

### AttachLinklist

```solidity
event AttachLinklist(uint256 indexed linklistId, uint256 indexed characterId, bytes32 indexed linkType);
```

### DetachLinklist

```solidity
event DetachLinklist(uint256 indexed linklistId, uint256 indexed characterId, bytes32 indexed linkType);
```

