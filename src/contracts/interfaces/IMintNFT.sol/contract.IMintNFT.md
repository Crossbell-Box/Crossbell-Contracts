# IMintNFT
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/301046e95eacfa631ca751822adb220cbb30103a/contracts/interfaces/IMintNFT.sol)


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

