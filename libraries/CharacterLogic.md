# Solidity API

## CharacterLogic

### createCharacter

```solidity
function createCharacter(struct DataTypes.CreateCharacterData vars, uint256 characterId, mapping(bytes32 => uint256) _characterIdByHandleHash, mapping(uint256 => struct DataTypes.Character) _characterById) external
```

### setSocialToken

```solidity
function setSocialToken(uint256 characterId, address tokenAddress, mapping(uint256 => struct DataTypes.Character) _characterById) external
```

### setCharacterLinkModule

```solidity
function setCharacterLinkModule(uint256 characterId, address linkModule, bytes linkModuleInitData, struct DataTypes.Character _character) external
```

### setHandle

```solidity
function setHandle(uint256 characterId, string newHandle, mapping(bytes32 => uint256) _characterIdByHandleHash, mapping(uint256 => struct DataTypes.Character) _characterById) external
```

