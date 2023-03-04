# CharacterLogic
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/7fb0a111be44c9c39adc514360ef463c6a04b62a/contracts/libraries/CharacterLogic.sol)


## Functions
### createCharacter


```solidity
function createCharacter(
    DataTypes.CreateCharacterData calldata vars,
    uint256 characterId,
    mapping(bytes32 => uint256) storage _characterIdByHandleHash,
    mapping(uint256 => DataTypes.Character) storage _characterById
) external;
```

### setSocialToken


```solidity
function setSocialToken(
    uint256 characterId,
    address tokenAddress,
    mapping(uint256 => DataTypes.Character) storage _characterById
) external;
```

### setCharacterLinkModule


```solidity
function setCharacterLinkModule(
    uint256 characterId,
    address linkModule,
    bytes calldata linkModuleInitData,
    DataTypes.Character storage _character
) external;
```

### setHandle


```solidity
function setHandle(
    uint256 characterId,
    string calldata newHandle,
    mapping(bytes32 => uint256) storage _characterIdByHandleHash,
    mapping(uint256 => DataTypes.Character) storage _characterById
) external;
```

