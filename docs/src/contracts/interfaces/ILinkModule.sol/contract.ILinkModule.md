# ILinkModule
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/d7930db5cd89d52737395aa81b0ec583ccadb80c/contracts/interfaces/ILinkModule.sol)


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

