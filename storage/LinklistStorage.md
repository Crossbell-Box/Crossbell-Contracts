# Solidity API

## LinklistStorage

### Web3Entry

```solidity
address Web3Entry
```

### _linkTypes

```solidity
mapping(uint256 => bytes32) _linkTypes
```

### _linkingCharacters

```solidity
mapping(uint256 => struct EnumerableSet.UintSet) _linkingCharacters
```

### _linkingAddresses

```solidity
mapping(uint256 => struct EnumerableSet.AddressSet) _linkingAddresses
```

### _linkingLinklists

```solidity
mapping(uint256 => struct EnumerableSet.UintSet) _linkingLinklists
```

### _linkKeys

```solidity
mapping(uint256 => struct EnumerableSet.Bytes32Set) _linkKeys
```

### _linkingERC721s

```solidity
mapping(bytes32 => struct DataTypes.ERC721Struct) _linkingERC721s
```

### _linkNotes

```solidity
mapping(bytes32 => struct DataTypes.NoteStruct) _linkNotes
```

### _linkingCharacterLinks

```solidity
mapping(bytes32 => struct DataTypes.CharacterLinkStruct) _linkingCharacterLinks
```

### _linkingAnys

```solidity
mapping(bytes32 => string) _linkingAnys
```

### _currentTakeOver

```solidity
mapping(uint256 => uint256) _currentTakeOver
```

### _uris

```solidity
mapping(uint256 => string) _uris
```

### _linkingERC721Keys

```solidity
mapping(uint256 => struct EnumerableSet.Bytes32Set) _linkingERC721Keys
```

### _linkNoteKeys

```solidity
mapping(uint256 => struct EnumerableSet.Bytes32Set) _linkNoteKeys
```

### _linkingCharacterLinkKeys

```solidity
mapping(uint256 => struct EnumerableSet.Bytes32Set) _linkingCharacterLinkKeys
```

### _linkingAnyKeys

```solidity
mapping(uint256 => struct EnumerableSet.Bytes32Set) _linkingAnyKeys
```

