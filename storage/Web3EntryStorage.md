# Solidity API

## Web3EntryStorage

### _characterById

```solidity
mapping(uint256 => struct DataTypes.Character) _characterById
```

### _characterIdByHandleHash

```solidity
mapping(bytes32 => uint256) _characterIdByHandleHash
```

### _primaryCharacterByAddress

```solidity
mapping(address => uint256) _primaryCharacterByAddress
```

### _attachedLinklists

```solidity
mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists
```

### _noteByIdByCharacter

```solidity
mapping(uint256 => mapping(uint256 => struct DataTypes.Note)) _noteByIdByCharacter
```

### _linkModules4Linklist

```solidity
mapping(uint256 => address) _linkModules4Linklist
```

### _linkModules4ERC721

```solidity
mapping(address => mapping(uint256 => address)) _linkModules4ERC721
```

### _linkModules4Address

```solidity
mapping(address => address) _linkModules4Address
```

### _characterCounter

```solidity
uint256 _characterCounter
```

### _linklist

```solidity
address _linklist
```

### MINT_NFT_IMPL

```solidity
address MINT_NFT_IMPL
```

