# IMintNFT
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/4ba4e225416bca003567c0e6ae31b9c6258df17e/contracts/interfaces/IMintNFT.sol)


## Functions
### initialize


```solidity
function initialize(
    uint256 characterId,
    uint256 noteId,
    address web3Entry,
    string calldata name,
    string calldata symbol
) external;
```

### mint


```solidity
function mint(address to) external returns (uint256);
```

