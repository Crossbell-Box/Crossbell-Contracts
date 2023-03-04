# ILinkModule
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/d4bcd4403377f0886ae184e5f617e94fbdfa377b(/Crossbell-Contracts/contracts/interfaces/ILinkModule.sol)


## Functions
### initializeLinkModule


```solidity
function initializeLinkModule(uint256 characterId, uint256 noteId, string calldata name, string calldata symbol)
    external
    returns (bytes memory);
```

### processLink


```solidity
function processLink(address to, uint256 characterId, uint256 noteId, bytes calldata data) external;
```

