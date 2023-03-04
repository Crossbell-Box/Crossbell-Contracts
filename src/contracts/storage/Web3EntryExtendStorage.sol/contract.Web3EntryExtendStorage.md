# Web3EntryExtendStorage
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/d4bcd4403377f0886ae184e5f617e94fbdfa377b(/Crossbell-Contracts/contracts/storage/Web3EntryExtendStorage.sol)


## State Variables
### _periphery

```solidity
address internal _periphery;
```


### _operatorByCharacter

```solidity
mapping(uint256 => address) internal _operatorByCharacter;
```


### resolver

```solidity
address public resolver;
```


### _operatorsByCharacter

```solidity
mapping(uint256 => EnumerableSet.AddressSet) internal _operatorsByCharacter;
```


### _operatorsPermissionBitMap

```solidity
mapping(uint256 => mapping(address => uint256)) internal _operatorsPermissionBitMap;
```


### _operators4Note

```solidity
mapping(uint256 => mapping(uint256 => DataTypes.Operators4Note)) internal _operators4Note;
```


### _newbieVilla

```solidity
address internal _newbieVilla;
```


