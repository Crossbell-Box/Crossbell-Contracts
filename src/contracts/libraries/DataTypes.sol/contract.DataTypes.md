# DataTypes
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/4ba4e225416bca003567c0e6ae31b9c6258df17e/contracts/libraries/DataTypes.sol)

A standard library of data types.


## Structs
### MigrateData

```solidity
struct MigrateData {
    address account;
    string handle;
    string uri;
    address[] toAddresses;
    bytes32 linkType;
}
```

### CreateCharacterData

```solidity
struct CreateCharacterData {
    address to;
    string handle;
    string uri;
    address linkModule;
    bytes linkModuleInitData;
}
```

### createThenLinkCharacterData

```solidity
struct createThenLinkCharacterData {
    uint256 fromCharacterId;
    address to;
    bytes32 linkType;
}
```

### linkNoteData

```solidity
struct linkNoteData {
    uint256 fromCharacterId;
    uint256 toCharacterId;
    uint256 toNoteId;
    bytes32 linkType;
    bytes data;
}
```

### unlinkNoteData

```solidity
struct unlinkNoteData {
    uint256 fromCharacterId;
    uint256 toCharacterId;
    uint256 toNoteId;
    bytes32 linkType;
}
```

### linkCharacterData

```solidity
struct linkCharacterData {
    uint256 fromCharacterId;
    uint256 toCharacterId;
    bytes32 linkType;
    bytes data;
}
```

### unlinkCharacterData

```solidity
struct unlinkCharacterData {
    uint256 fromCharacterId;
    uint256 toCharacterId;
    bytes32 linkType;
}
```

### linkERC721Data

```solidity
struct linkERC721Data {
    uint256 fromCharacterId;
    address tokenAddress;
    uint256 tokenId;
    bytes32 linkType;
    bytes data;
}
```

### unlinkERC721Data

```solidity
struct unlinkERC721Data {
    uint256 fromCharacterId;
    address tokenAddress;
    uint256 tokenId;
    bytes32 linkType;
}
```

### linkAddressData

```solidity
struct linkAddressData {
    uint256 fromCharacterId;
    address ethAddress;
    bytes32 linkType;
    bytes data;
}
```

### unlinkAddressData

```solidity
struct unlinkAddressData {
    uint256 fromCharacterId;
    address ethAddress;
    bytes32 linkType;
}
```

### linkAnyUriData

```solidity
struct linkAnyUriData {
    uint256 fromCharacterId;
    string toUri;
    bytes32 linkType;
    bytes data;
}
```

### unlinkAnyUriData

```solidity
struct unlinkAnyUriData {
    uint256 fromCharacterId;
    string toUri;
    bytes32 linkType;
}
```

### linkLinklistData

```solidity
struct linkLinklistData {
    uint256 fromCharacterId;
    uint256 toLinkListId;
    bytes32 linkType;
    bytes data;
}
```

### unlinkLinklistData

```solidity
struct unlinkLinklistData {
    uint256 fromCharacterId;
    uint256 toLinkListId;
    bytes32 linkType;
}
```

### setLinkModule4CharacterData

```solidity
struct setLinkModule4CharacterData {
    uint256 characterId;
    address linkModule;
    bytes linkModuleInitData;
}
```

### setLinkModule4NoteData

```solidity
struct setLinkModule4NoteData {
    uint256 characterId;
    uint256 noteId;
    address linkModule;
    bytes linkModuleInitData;
}
```

### setLinkModule4LinklistData

```solidity
struct setLinkModule4LinklistData {
    uint256 linklistId;
    address linkModule;
    bytes linkModuleInitData;
}
```

### setLinkModule4ERC721Data

```solidity
struct setLinkModule4ERC721Data {
    address tokenAddress;
    uint256 tokenId;
    address linkModule;
    bytes linkModuleInitData;
}
```

### setLinkModule4AddressData

```solidity
struct setLinkModule4AddressData {
    address account;
    address linkModule;
    bytes linkModuleInitData;
}
```

### setMintModule4NoteData

```solidity
struct setMintModule4NoteData {
    uint256 characterId;
    uint256 noteId;
    address mintModule;
    bytes mintModuleInitData;
}
```

### linkCharactersInBatchData

```solidity
struct linkCharactersInBatchData {
    uint256 fromCharacterId;
    uint256[] toCharacterIds;
    bytes[] data;
    address[] toAddresses;
    bytes32 linkType;
}
```

### LinkData

```solidity
struct LinkData {
    uint256 linklistId;
    uint256 linkItemType;
    uint256 linkingCharacterId;
    address linkingAddress;
    uint256 linkingLinklistId;
    bytes32 linkKey;
}
```

### PostNoteData

```solidity
struct PostNoteData {
    uint256 characterId;
    string contentUri;
    address linkModule;
    bytes linkModuleInitData;
    address mintModule;
    bytes mintModuleInitData;
    bool locked;
}
```

### MintNoteData

```solidity
struct MintNoteData {
    uint256 characterId;
    uint256 noteId;
    address to;
    bytes mintModuleData;
}
```

### Character

```solidity
struct Character {
    uint256 characterId;
    string handle;
    string uri;
    uint256 noteCount;
    address socialToken;
    address linkModule;
}
```

### Note
*A struct containing data associated with each new note.*


```solidity
struct Note {
    bytes32 linkItemType;
    bytes32 linkKey;
    string contentUri;
    address linkModule;
    address mintModule;
    address mintNFT;
    bool deleted;
    bool locked;
}
```

### CharacterLinkStruct

```solidity
struct CharacterLinkStruct {
    uint256 fromCharacterId;
    uint256 toCharacterId;
    bytes32 linkType;
}
```

### NoteStruct

```solidity
struct NoteStruct {
    uint256 characterId;
    uint256 noteId;
}
```

### ERC721Struct

```solidity
struct ERC721Struct {
    address tokenAddress;
    uint256 erc721TokenId;
}
```

### Operators4Note

```solidity
struct Operators4Note {
    EnumerableSet.AddressSet blocklist;
    EnumerableSet.AddressSet allowlist;
}
```

