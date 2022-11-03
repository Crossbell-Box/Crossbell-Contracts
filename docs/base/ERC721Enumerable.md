# Solidity API

## ERC721Enumerable

### _ownedTokens

```solidity
mapping(address => mapping(uint256 => uint256)) _ownedTokens
```

### _ownedTokensIndex

```solidity
mapping(uint256 => uint256) _ownedTokensIndex
```

### _allTokens

```solidity
uint256[] _allTokens
```

### _allTokensIndex

```solidity
mapping(uint256 => uint256) _allTokensIndex
```

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

_See {IERC165-supportsInterface}._

### tokenOfOwnerByIndex

```solidity
function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256)
```

_See {IERC721Enumerable-tokenOfOwnerByIndex}._

### totalSupply

```solidity
function totalSupply() public view virtual returns (uint256)
```

_See {IERC721Enumerable-totalSupply}._

### tokenByIndex

```solidity
function tokenByIndex(uint256 index) public view virtual returns (uint256)
```

_See {IERC721Enumerable-tokenByIndex}._

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

### _addTokenToOwnerEnumeration

```solidity
function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private
```

_Private function to add a token to this extension's ownership-tracking data structures._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | address representing the new owner of the given token ID |
| tokenId | uint256 | uint256 ID of the token to be added to the tokens list of the given address |

### _addTokenToAllTokensEnumeration

```solidity
function _addTokenToAllTokensEnumeration(uint256 tokenId) private
```

_Private function to add a token to this extension's token tracking data structures._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | uint256 ID of the token to be added to the tokens list |

### _removeTokenFromOwnerEnumeration

```solidity
function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private
```

_Private function to remove a token from this extension's ownership-tracking data structures. Note that
while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
gas optimizations e.g. when performing a transfer operation (avoiding double writes).
This has O(1) time complexity, but alters the order of the _ownedTokens array._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | address representing the previous owner of the given token ID |
| tokenId | uint256 | uint256 ID of the token to be removed from the tokens list of the given address |

### _removeTokenFromAllTokensEnumeration

```solidity
function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private
```

_Private function to remove a token from this extension's token tracking data structures.
This has O(1) time complexity, but alters the order of the _allTokens array._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | uint256 ID of the token to be removed from the tokens list |

