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

### removeOperator

```solidity
function removeOperator(uint256 characterId, address operator) external
```

### isOperator

```solidity
function isOperator(uint256 characterId, address operator) external view returns (bool)
```

### getOperators

```solidity
function getOperators(uint256 characterId) external view returns (address[])
```

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

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual
```

_Hook that is called before any token transfer. This includes minting
and burning.

Calling conditions:

- When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
transferred to `to`.
- When `from` is zero, `tokenId` will be minted for `to`.
- When `to` is zero, ``from``'s `tokenId` will be burned.
- `from` cannot be the zero address.
- `to` cannot be the zero address.

To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks]._

