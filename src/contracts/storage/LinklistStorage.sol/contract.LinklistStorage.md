# LinklistStorage
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/3060ff9b47459c3bc54ac39115cb04b01451f340/contracts/storage/LinklistStorage.sol)


## State Variables
### Web3Entry

```solidity
address public Web3Entry;
```


### _linkTypes

```solidity
mapping(uint256 => bytes32) internal _linkTypes;
```


### _linkingCharacters

```solidity
mapping(uint256 => EnumerableSet.UintSet) internal _linkingCharacters;
```


### _linkingAddresses

```solidity
mapping(uint256 => EnumerableSet.AddressSet) internal _linkingAddresses;
```


### _linkingLinklists

```solidity
mapping(uint256 => EnumerableSet.UintSet) internal _linkingLinklists;
```


### _linkKeys

```solidity
mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkKeys;
```


### _linkingERC721s

```solidity
mapping(bytes32 => DataTypes.ERC721Struct) internal _linkingERC721s;
```


### _linkNotes

```solidity
mapping(bytes32 => DataTypes.NoteStruct) internal _linkNotes;
```


### _linkingCharacterLinks

```solidity
mapping(bytes32 => DataTypes.CharacterLinkStruct) internal _linkingCharacterLinks;
```


### _linkingAnys

```solidity
mapping(bytes32 => string) internal _linkingAnys;
```


### _currentTakeOver

```solidity
mapping(uint256 => uint256) internal _currentTakeOver;
```


### _uris

```solidity
mapping(uint256 => string) internal _uris;
```


### _linkingERC721Keys

```solidity
mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkingERC721Keys;
```


### _linkNoteKeys

```solidity
mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkNoteKeys;
```


### _linkingCharacterLinkKeys

```solidity
mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkingCharacterLinkKeys;
```


### _linkingAnyKeys

```solidity
mapping(uint256 => EnumerableSet.Bytes32Set) internal _linkingAnyKeys;
```


