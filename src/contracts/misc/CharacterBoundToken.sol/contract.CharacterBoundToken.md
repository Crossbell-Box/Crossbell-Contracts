# CharacterBoundToken
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/301046e95eacfa631ca751822adb220cbb30103a/contracts/misc/CharacterBoundToken.sol)

**Inherits:**
Context, ERC165, IERC1155, IERC1155MetadataURI, AccessControlEnumerable


## State Variables
### MINTER_ROLE

```solidity
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
```


### _balances

```solidity
mapping(uint256 => mapping(uint256 => uint256)) private _balances;
```


### _operatorApprovals

```solidity
mapping(address => mapping(address => bool)) private _operatorApprovals;
```


### _tokenURIs

```solidity
mapping(uint256 => string) private _tokenURIs;
```


### web3Entry

```solidity
address public web3Entry;
```


### _currentTokenNumbers

```solidity
mapping(uint256 => uint256) private _currentTokenNumbers;
```


## Functions
### constructor


```solidity
constructor(address web3Entry_);
```

### mint


```solidity
function mint(uint256 characterId, uint256 tokenId) external onlyRole(MINTER_ROLE);
```

### burn


```solidity
function burn(uint256 characterId, uint256 tokenId, uint256 amount) external;
```

### setTokenURI


```solidity
function setTokenURI(uint256 tokenId, string memory tokenURI) external onlyRole(MINTER_ROLE);
```

### safeTransferFrom

*See {IERC1155-safeTransferFrom}.*


```solidity
function safeTransferFrom(address, address, uint256, uint256, bytes memory) external virtual override;
```

### safeBatchTransferFrom

*See {IERC1155-safeBatchTransferFrom}.*


```solidity
function safeBatchTransferFrom(address, address, uint256[] memory, uint256[] memory, bytes memory)
    external
    virtual
    override;
```

### setApprovalForAll

*See {IERC1155-setApprovalForAll}.*


```solidity
function setApprovalForAll(address operator, bool approved) external virtual override;
```

### balanceOfBatch


```solidity
function balanceOfBatch(address[] memory accounts, uint256[] memory tokenIds)
    external
    view
    virtual
    override
    returns (uint256[] memory);
```

### supportsInterface

*See {IERC165-supportsInterface}.*


```solidity
function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControlEnumerable, ERC165, IERC165)
    returns (bool);
```

### balanceOf


```solidity
function balanceOf(address account, uint256 tokenId) public view virtual override returns (uint256 balance);
```

### balanceOf


```solidity
function balanceOf(uint256 characterId, uint256 tokenId) public view virtual returns (uint256);
```

### uri


```solidity
function uri(uint256 tokenId) public view virtual override returns (string memory);
```

### isApprovedForAll

*See {IERC1155-isApprovedForAll}.*


```solidity
function isApprovedForAll(address account, address operator) public view virtual override returns (bool);
```

### _setApprovalForAll

*Approve `operator` to operate on all of `owner` tokens
Emits an {ApprovalForAll} event.*


```solidity
function _setApprovalForAll(address owner, address operator, bool approved) internal virtual;
```

### _setURI


```solidity
function _setURI(uint256 tokenId, string memory tokenURI) internal virtual;
```

## Events
### Mint

```solidity
event Mint(uint256 indexed to, uint256 indexed tokenId, uint256 indexed tokenNumber);
```

### Burn

```solidity
event Burn(uint256 indexed from, uint256 indexed tokenId, uint256 indexed amount);
```

