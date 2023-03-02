# Solidity API

## CharacterLogic

### createCharacter

```solidity
function createCharacter(address to, string handle, string uri, address linkModule, bytes linkModuleInitData, uint256 characterId, mapping(bytes32 => uint256) _characterIdByHandleHash, mapping(uint256 => struct DataTypes.Character) _characterById) external
```

Create a character.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to mint the character to. |
| handle | string | The handle to set for the new character. |
| uri | string | The URI to set for the new character’s metadata. |
| linkModule | address | The link module to set for the new character or the zero address. |
| linkModuleInitData | bytes | Arbitrary data to be decoded in the link module for initialization. |
| characterId | uint256 | The ID of the new character. |
| _characterIdByHandleHash | mapping(bytes32 &#x3D;&gt; uint256) |  |
| _characterById | mapping(uint256 &#x3D;&gt; struct DataTypes.Character) |  |

### setSocialToken

```solidity
function setSocialToken(uint256 characterId, address tokenAddress, mapping(uint256 => struct DataTypes.Character) _characterById) external
```

Sets a social token for a given character..

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The characterId to set social token for. |
| tokenAddress | address | Token address to be set. |
| _characterById | mapping(uint256 &#x3D;&gt; struct DataTypes.Character) |  |

### setCharacterLinkModule

```solidity
function setCharacterLinkModule(uint256 characterId, address linkModule, bytes linkModuleInitData, struct DataTypes.Character _character) external
```

Sets link module for a given character..

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The character id to set link module for. |
| linkModule | address | The link module to set. |
| linkModuleInitData | bytes | The data to pass to the link module for initialization, if any. |
| _character | struct DataTypes.Character |  |

### setHandle

```solidity
function setHandle(uint256 characterId, string newHandle, mapping(bytes32 => uint256) _characterIdByHandleHash, mapping(uint256 => struct DataTypes.Character) _characterById) external
```

Sets new handle for a given character.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| characterId | uint256 | The character id to set new handle for. |
| newHandle | string | New handle to set. |
| _characterIdByHandleHash | mapping(bytes32 &#x3D;&gt; uint256) |  |
| _characterById | mapping(uint256 &#x3D;&gt; struct DataTypes.Character) |  |

