# CharacterLogic
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/301046e95eacfa631ca751822adb220cbb30103a/contracts/libraries/CharacterLogic.sol)


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

