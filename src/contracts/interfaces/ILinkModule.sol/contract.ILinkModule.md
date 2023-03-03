# ILinkModule
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/eafad9b7237b4175827150168fbfde105ec8c367/contracts/interfaces/ILinkModule.sol)


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

