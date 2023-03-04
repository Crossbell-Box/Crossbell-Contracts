# Solidity API

## ERC721Enumerable

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

