# Web3EntryStorage
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/7fb0a111be44c9c39adc514360ef463c6a04b62a/contracts/storage/Web3EntryStorage.sol)


## State Variables
### _characterById

```solidity
mapping(uint256 => DataTypes.Character) internal _characterById;
```


### _characterIdByHandleHash

```solidity
mapping(bytes32 => uint256) internal _characterIdByHandleHash;
```


### _primaryCharacterByAddress

```solidity
mapping(address => uint256) internal _primaryCharacterByAddress;
```


### _attachedLinklists

```solidity
mapping(uint256 => mapping(bytes32 => uint256)) internal _attachedLinklists;
```


### _noteByIdByCharacter

```solidity
mapping(uint256 => mapping(uint256 => DataTypes.Note)) internal _noteByIdByCharacter;
```


### _linkModules4Linklist

```solidity
mapping(uint256 => address) internal _linkModules4Linklist;
```


### _linkModules4ERC721
*disable `uninitialized-state` check, as linkmodule for erc721 is not enabled currently*


```solidity
mapping(address => mapping(uint256 => address)) internal _linkModules4ERC721;
```


### _linkModules4Address

```solidity
mapping(address => address) internal _linkModules4Address;
```


### _characterCounter

```solidity
uint256 internal _characterCounter;
```


### _linklist

```solidity
address internal _linklist;
```


### MINT_NFT_IMPL

```solidity
address internal MINT_NFT_IMPL;
```


