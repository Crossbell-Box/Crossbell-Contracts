# IMintNFT
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/182c82c216a4cf11409d4311d9773152bbe60ccf/contracts/interfaces/IMintNFT.sol)


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

