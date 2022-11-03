# Solidity API

## MintNFT

### Web3Entry

```solidity
address Web3Entry
```

### _characterId

```solidity
uint256 _characterId
```

### _noteId

```solidity
uint256 _noteId
```

### _tokenIdCounter

```solidity
struct Counters.Counter _tokenIdCounter
```

### initialize

```solidity
function initialize(uint256 characterId, uint256 noteId, address web3Entry, string name, string symbol) external
```

### mint

```solidity
function mint(address to) external returns (uint256)
```

### getSourcePublicationPointer

```solidity
function getSourcePublicationPointer() external view returns (uint256, uint256)
```

### tokenURI

```solidity
function tokenURI(uint256 tokenId) public view returns (string)
```

_See {IERC721Metadata-tokenURI}._

