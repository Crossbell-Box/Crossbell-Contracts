# ILinkModule
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/301046e95eacfa631ca751822adb220cbb30103a/contracts/interfaces/ILinkModule.sol)


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

