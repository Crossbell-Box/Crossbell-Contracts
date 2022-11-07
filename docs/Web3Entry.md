# Solidity API

## Web3Entry

### _operatorsByCharacter

```solidity
mapping(uint256 => struct EnumerableSet.AddressSet) _operatorsByCharacter
```

### addOperator

```solidity
function addOperator(uint256 characterId, address operator) external
```

Designate addresses as operators of your character so that it can send transactions on behalf
      of your characters(e.g. post notes or follow someone). This a high risk operation, so take special 
      attention and make sure the addresses you input is familiar to you.

### removeOperator

```solidity
function removeOperator(uint256 characterId, address operator) external
```

Cancel authorization on operators and remove them from operator list.

### isOperator

```solidity
function isOperator(uint256 characterId, address operator) external view returns (bool)
```

Check if an address is the operator of a character.

_`isOperator` is compatible with operators set by old `setOperator`, which is deprected and will
      be disabled in later updates._

### getOperators

```solidity
function getOperators(uint256 characterId) external view returns (address[])
```

Get operator addresses of a character.

_`getOperators` returns operators in _operatorsByCharacter, but doesn't return 
     _operatorByCharacter, which is deprected and will be disabled in later updates._

### _addOperator

```solidity
function _addOperator(uint256 characterId, address operator) internal
```

### _removeOperator

```solidity
function _removeOperator(uint256 characterId, address operator) internal
```

### _validateCallerIsCharacterOwnerOrOperator

```solidity
function _validateCallerIsCharacterOwnerOrOperator(uint256 characterId) internal view virtual
```

_This is a virtual function and it doesn't check anything, so you should complete validating logic in inheritance contracts that use this Web3EntryBase contract as parent contract._

### _validateCallerIsLinklistOwnerOrOperator

```solidity
function _validateCallerIsLinklistOwnerOrOperator(uint256 tokenId) internal view virtual
```

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

_Operator lists will be reset to blank before the characters are transferred in order to grant the
      whole control power to receivers of character transfers._

