# ILinkModule
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/c7f31e42711569b1cb499ae27680e91d1ff85e00/contracts/interfaces/ILinkModule.sol)


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

