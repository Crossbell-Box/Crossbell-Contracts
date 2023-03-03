# Web3EntryExtendStorage
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/7dd103c70343d6410d08f7bb25b0b513c4d92016/contracts/storage/Web3EntryExtendStorage.sol)


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


