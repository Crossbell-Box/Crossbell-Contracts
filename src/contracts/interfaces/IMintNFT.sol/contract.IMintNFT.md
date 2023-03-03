# IMintNFT
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/c7f31e42711569b1cb499ae27680e91d1ff85e00/contracts/interfaces/IMintNFT.sol)


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

