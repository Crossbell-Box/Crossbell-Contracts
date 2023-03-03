# ILinkModule
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/7dd103c70343d6410d08f7bb25b0b513c4d92016/contracts/interfaces/ILinkModule.sol)


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

