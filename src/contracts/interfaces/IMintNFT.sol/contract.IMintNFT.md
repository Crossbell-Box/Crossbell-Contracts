# IMintNFT
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/34b32749a8bd5815fbe2026db07c401bb7f54d20/contracts/interfaces/IMintNFT.sol)


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

