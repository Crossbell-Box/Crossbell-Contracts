# IMintNFT
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/d7461dc986f92c02778fae6c468f62f2db6d2f91/contracts/interfaces/IMintNFT.sol)


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

