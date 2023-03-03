# IMintNFT
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/eafad9b7237b4175827150168fbfde105ec8c367/contracts/interfaces/IMintNFT.sol)


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

