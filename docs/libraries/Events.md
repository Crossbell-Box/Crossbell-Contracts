# Solidity API

## Events

### BaseInitialized

```solidity
event BaseInitialized(string name, string symbol, uint256 timestamp)
```

### Web3EntryInitialized

```solidity
event Web3EntryInitialized(uint256 timestamp)
```

### LinklistNFTInitialized

```solidity
event LinklistNFTInitialized(uint256 timestamp)
```

### MintNFTInitialized

```solidity
event MintNFTInitialized(uint256 characterId, uint256 noteId, uint256 timestamp)
```

### CharacterCreated

```solidity
event CharacterCreated(uint256 characterId, address creator, address to, string handle, uint256 timestamp)
```

### SetPrimaryCharacterId

```solidity
event SetPrimaryCharacterId(address account, uint256 characterId, uint256 oldCharacterId)
```

### SetHandle

```solidity
event SetHandle(address account, uint256 characterId, string newHandle)
```

### SetSocialToken

```solidity
event SetSocialToken(address account, uint256 characterId, address tokenAddress)
```

### GrantOperatorPermissions

```solidity
event GrantOperatorPermissions(uint256 characterId, address operator, uint256 permissionBitMap)
```

### AddOperators4Note

```solidity
event AddOperators4Note(uint256 characterId, uint256 noteId, address[] blacklist, address[] whitelist)
```

### RemoveOperators4Note

```solidity
event RemoveOperators4Note(uint256 characterId, uint256 noteId, address[] blacklist, address[] whitelist)
```

### SetCharacterUri

```solidity
event SetCharacterUri(uint256 characterId, string newUri)
```

### PostNote

```solidity
event PostNote(uint256 characterId, uint256 noteId, bytes32 linkKey, bytes32 linkItemType, bytes data)
```

### SetNoteUri

```solidity
event SetNoteUri(uint256 characterId, uint256 noteId, string newUri)
```

### DeleteNote

```solidity
event DeleteNote(uint256 characterId, uint256 noteId)
```

### LockNote

```solidity
event LockNote(uint256 characterId, uint256 noteId)
```

### LinkCharacter

```solidity
event LinkCharacter(address account, uint256 fromCharacterId, uint256 toCharacterId, bytes32 linkType, uint256 linklistId)
```

### UnlinkCharacter

```solidity
event UnlinkCharacter(address account, uint256 fromCharacterId, uint256 toCharacterId, bytes32 linkType)
```

### LinkNote

```solidity
event LinkNote(uint256 fromCharacterId, uint256 toCharacterId, uint256 toNoteId, bytes32 linkType, uint256 linklistId)
```

### UnlinkNote

```solidity
event UnlinkNote(uint256 fromCharacterId, uint256 toCharacterId, uint256 toNoteId, bytes32 linkType, uint256 linklistId)
```

### LinkERC721

```solidity
event LinkERC721(uint256 fromCharacterId, address tokenAddress, uint256 toNoteId, bytes32 linkType, uint256 linklistId)
```

### LinkAddress

```solidity
event LinkAddress(uint256 fromCharacterId, address ethAddress, bytes32 linkType, uint256 linklistId)
```

### UnlinkAddress

```solidity
event UnlinkAddress(uint256 fromCharacterId, address ethAddress, bytes32 linkType)
```

### LinkAnyUri

```solidity
event LinkAnyUri(uint256 fromCharacterId, string toUri, bytes32 linkType, uint256 linklistId)
```

### UnlinkAnyUri

```solidity
event UnlinkAnyUri(uint256 fromCharacterId, string toUri, bytes32 linkType)
```

### LinkCharacterLink

```solidity
event LinkCharacterLink(uint256 fromCharacterId, bytes32 linkType, uint256 clFromCharacterId, uint256 clToCharacterId, bytes32 clLinkType)
```

### UnlinkCharacterLink

```solidity
event UnlinkCharacterLink(uint256 fromCharacterId, bytes32 linkType, uint256 clFromCharactereId, uint256 clToCharacterId, bytes32 clLinkType)
```

### UnlinkERC721

```solidity
event UnlinkERC721(uint256 fromCharacterId, address tokenAddress, uint256 toNoteId, bytes32 linkType, uint256 linklistId)
```

### LinkLinklist

```solidity
event LinkLinklist(uint256 fromCharacterId, uint256 toLinklistId, bytes32 linkType, uint256 linklistId)
```

### UnlinkLinklist

```solidity
event UnlinkLinklist(uint256 fromCharacterId, uint256 toLinklistId, bytes32 linkType, uint256 linklistId)
```

### MintNote

```solidity
event MintNote(address to, uint256 characterId, uint256 noteId, address tokenAddress, uint256 tokenId)
```

### SetLinkModule4Character

```solidity
event SetLinkModule4Character(uint256 characterId, address linkModule, bytes returnData, uint256 timestamp)
```

### SetLinkModule4Note

```solidity
event SetLinkModule4Note(uint256 characterId, uint256 noteId, address linkModule, bytes returnData, uint256 timestamp)
```

### SetLinkModule4Address

```solidity
event SetLinkModule4Address(address account, address linkModule, bytes returnData, uint256 timestamp)
```

### SetLinkModule4ERC721

```solidity
event SetLinkModule4ERC721(address tokenAddress, uint256 tokenId, address linkModule, bytes returnData, uint256 timestamp)
```

### SetLinkModule4Linklist

```solidity
event SetLinkModule4Linklist(uint256 linklistId, address linkModule, bytes returnData, uint256 timestamp)
```

### SetMintModule4Note

```solidity
event SetMintModule4Note(uint256 characterId, uint256 noteId, address mintModule, bytes returnData, uint256 timestamp)
```

### AttachLinklist

```solidity
event AttachLinklist(uint256 linklistId, uint256 characterId, bytes32 linkType)
```

### DetachLinklist

```solidity
event DetachLinklist(uint256 linklistId, uint256 characterId, bytes32 linkType)
```

