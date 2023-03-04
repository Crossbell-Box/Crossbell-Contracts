# ILinkModule
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/7fb0a111be44c9c39adc514360ef463c6a04b62a/contracts/interfaces/ILinkModule.sol)


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

