# MintNFT
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/7fb0a111be44c9c39adc514360ef463c6a04b62a/contracts/MintNFT.sol)

**Inherits:**
[NFTBase](/contracts/base/NFTBase.sol/contract.NFTBase.md), [IMintNFT](/contracts/interfaces/IMintNFT.sol/contract.IMintNFT.md), Initializable


## State Variables
### Web3Entry

```solidity
address public Web3Entry;
```


### _characterId

```solidity
uint256 internal _characterId;
```


### _noteId

```solidity
uint256 internal _noteId;
```


### _tokenIdCounter

```solidity
Counters.Counter internal _tokenIdCounter;
```


## Functions
### initialize


```solidity
function initialize(
    uint256 characterId,
    uint256 noteId,
    address web3Entry,
    string calldata name_,
    string calldata symbol_
) external override initializer;
```

### mint


```solidity
function mint(address to) external override returns (uint256);
```

### tokenURI


```solidity
function tokenURI(uint256 tokenId) public view override returns (string memory uri);
```

