# ILinkModule
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/1bc9213c7fb7853b038310c6b20bef0fd2cf388b/contracts/interfaces/ILinkModule.sol)


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

