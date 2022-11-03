# Solidity API

## LinklistStorage

### Web3Entry

```solidity
address Web3Entry
```

### linkTypes

```solidity
mapping(uint256 => bytes32) linkTypes
```

### linkingCharacterList

```solidity
mapping(uint256 => struct EnumerableSet.UintSet) linkingCharacterList
```

### linkingAddressList

```solidity
mapping(uint256 => struct EnumerableSet.AddressSet) linkingAddressList
```

### linkingLinklists

```solidity
mapping(uint256 => struct EnumerableSet.UintSet) linkingLinklists
```

### linkKeysList

```solidity
mapping(uint256 => struct EnumerableSet.Bytes32Set) linkKeysList
```

### linkingERC721List

```solidity
mapping(bytes32 => struct DataTypes.ERC721Struct) linkingERC721List
```

### linkNoteList

```solidity
mapping(bytes32 => struct DataTypes.NoteStruct) linkNoteList
```

### linkingCharacterLinkList

```solidity
mapping(bytes32 => struct DataTypes.CharacterLinkStruct) linkingCharacterLinkList
```

### linkingAnylist

```solidity
mapping(bytes32 => string) linkingAnylist
```

### currentTakeOver

```solidity
mapping(uint256 => uint256) currentTakeOver
```

### _uris

```solidity
mapping(uint256 => string) _uris
```

### linkingERC721Keys

```solidity
mapping(uint256 => struct EnumerableSet.Bytes32Set) linkingERC721Keys
```

### linkNoteKeys

```solidity
mapping(uint256 => struct EnumerableSet.Bytes32Set) linkNoteKeys
```

### linkingCharacterLinkKeys

```solidity
mapping(uint256 => struct EnumerableSet.Bytes32Set) linkingCharacterLinkKeys
```

### linkingAnyKeys

```solidity
mapping(uint256 => struct EnumerableSet.Bytes32Set) linkingAnyKeys
```

