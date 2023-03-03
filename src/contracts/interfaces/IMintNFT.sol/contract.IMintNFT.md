# IMintNFT
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/1bc9213c7fb7853b038310c6b20bef0fd2cf388b/contracts/interfaces/IMintNFT.sol)


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

