# ERC721
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/d7930db5cd89d52737395aa81b0ec583ccadb80c/contracts/base/ERC721.sol)

**Inherits:**
Context, ERC165, IERC721, IERC721Metadata

*Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
the Metadata extension, but not including the Enumerable extension, which is available separately as
{ERC721Enumerable}.*


## State Variables
### _name

```solidity
string private _name;
```


### _symbol

```solidity
string private _symbol;
```


### _owners

```solidity
mapping(uint256 => address) private _owners;
```


### _balances

```solidity
mapping(address => uint256) private _balances;
```


### _tokenApprovals

```solidity
mapping(uint256 => address) private _tokenApprovals;
```


### _operatorApprovals

```solidity
mapping(address => mapping(address => bool)) private _operatorApprovals;
```


## Functions
### __ERC721_Init


```solidity
function __ERC721_Init(string calldata name_, string calldata symbol_) internal;
```

### supportsInterface

*See {IERC165-supportsInterface}.*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool);
```

### balanceOf

*See {IERC721-balanceOf}.*


```solidity
function balanceOf(address owner) public view virtual override returns (uint256);
```

### ownerOf

*See {IERC721-ownerOf}.*


```solidity
function ownerOf(uint256 tokenId) public view virtual override returns (address);
```

### name

*See {IERC721Metadata-name}.*


```solidity
function name() public view virtual override returns (string memory);
```

### symbol

*See {IERC721Metadata-symbol}.*


```solidity
function symbol() public view virtual override returns (string memory);
```

### tokenURI

*See {IERC721Metadata-tokenURI}.*


```solidity
function tokenURI(uint256 tokenId) public view virtual override returns (string memory);
```

### _baseURI

*Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, can be overridden in child contracts.*


```solidity
function _baseURI() internal view virtual returns (string memory);
```

### approve

*See {IERC721-approve}.*


```solidity
function approve(address to, uint256 tokenId) public virtual override;
```

### getApproved

*See {IERC721-getApproved}.*


```solidity
function getApproved(uint256 tokenId) public view virtual override returns (address);
```

### setApprovalForAll

*See {IERC721-setApprovalForAll}.*


```solidity
function setApprovalForAll(address operator, bool approved) public virtual override;
```

### isApprovedForAll

*See {IERC721-isApprovedForAll}.*


```solidity
function isApprovedForAll(address owner, address operator) public view virtual override returns (bool);
```

### transferFrom

*See {IERC721-transferFrom}.*


```solidity
function transferFrom(address from, address to, uint256 tokenId) public virtual override;
```

### safeTransferFrom

*See {IERC721-safeTransferFrom}.*


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override;
```

### safeTransferFrom

*See {IERC721-safeTransferFrom}.*


```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override;
```

### _safeTransfer

*Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
are aware of the ERC721 protocol to prevent tokens from being forever locked.
`_data` is additional data, it has no specified format and it is sent in call to `to`.
This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
implement alternative mechanisms to perform token transfer, such as signature-based.
Requirements:
- `from` cannot be the zero address.
- `to` cannot be the zero address.
- `tokenId` token must exist and be owned by `from`.
- If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received},
which is called upon a safe transfer.
Emits a {Transfer} event.*


```solidity
function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual;
```

### _exists

*Returns whether `tokenId` exists.
Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
Tokens start existing when they are minted (`_mint`),
and stop existing when they are burned (`_burn`).*


```solidity
function _exists(uint256 tokenId) internal view virtual returns (bool);
```

### _isApprovedOrOwner

*Returns whether `spender` is allowed to manage `tokenId`.
Requirements:
- `tokenId` must exist.*


```solidity
function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool);
```

### _safeMint

*Safely mints `tokenId` and transfers it to `to`.
Requirements:
- `tokenId` must not exist.
- If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received},
which is called upon a safe transfer.
Emits a {Transfer} event.*


```solidity
function _safeMint(address to, uint256 tokenId) internal virtual;
```

### _safeMint

*Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
forwarded in {IERC721Receiver-onERC721Received} to contract recipients.*


```solidity
function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual;
```

### _mint

*Mints `tokenId` and transfers it to `to`.
WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
Requirements:
- `tokenId` must not exist.
- `to` cannot be the zero address.
Emits a {Transfer} event.*


```solidity
function _mint(address to, uint256 tokenId) internal virtual;
```

### _burn

*Destroys `tokenId`.
The approval is cleared when the token is burned.
Requirements:
- `tokenId` must exist.
Emits a {Transfer} event.*


```solidity
function _burn(uint256 tokenId) internal virtual;
```

### _transfer

*Transfers `tokenId` from `from` to `to`.
As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
Requirements:
- `to` cannot be the zero address.
- `tokenId` token must be owned by `from`.
Emits a {Transfer} event.*


```solidity
function _transfer(address from, address to, uint256 tokenId) internal virtual;
```

### _approve

*Approve `to` to operate on `tokenId`
Emits a {Approval} event.*


```solidity
function _approve(address to, uint256 tokenId) internal virtual;
```

### _setApprovalForAll

*Approve `operator` to operate on all of `owner` tokens
Emits a {ApprovalForAll} event.*


```solidity
function _setApprovalForAll(address owner, address operator, bool approved) internal virtual;
```

### _checkOnERC721Received

*Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
The call is not executed if the target address is not a contract.*


```solidity
function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|address representing the previous owner of the given token ID|
|`to`|`address`|target address that will receive the tokens|
|`tokenId`|`uint256`|uint256 ID of the token to be transferred|
|`_data`|`bytes`|bytes optional data to send along with the call|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool whether the call correctly returned the expected magic value|


### _beforeTokenTransfer

*Hook that is called before any token transfer. This includes minting
and burning.
Calling conditions:
- When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
transferred to `to`.
- When `from` is zero, `tokenId` will be minted for `to`.
- When `to` is zero, ``from``'s `tokenId` will be burned.
- `from` and `to` are never both zero.
To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].*


```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual;
```

### _afterTokenTransfer

*Hook that is called after any transfer of tokens. This includes
minting and burning.
Calling conditions:
- when `from` and `to` are both non-zero.
- `from` and `to` are never both zero.
To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].*


```solidity
function _afterTokenTransfer(address from, address to, uint256 tokenId) internal virtual;
```

