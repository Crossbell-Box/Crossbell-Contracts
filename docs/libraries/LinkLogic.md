# Solidity API

## LinkLogic

### linkCharacter

```solidity
function linkCharacter(uint256 fromCharacterId, uint256 toCharacterId, bytes32 linkType, bytes data, address linker, address linklist, address linkModule, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

### unlinkCharacter

```solidity
function unlinkCharacter(struct DataTypes.unlinkCharacterData vars, address linker, address linklist, uint256 linklistId) external
```

### linkNote

```solidity
function linkNote(struct DataTypes.linkNoteData vars, address linker, address linklist, mapping(uint256 => mapping(uint256 => struct DataTypes.Note)) _noteByIdByCharacter, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

### unlinkNote

```solidity
function unlinkNote(struct DataTypes.unlinkNoteData vars, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

### linkCharacterLink

```solidity
function linkCharacterLink(uint256 fromCharacterId, struct DataTypes.CharacterLinkStruct linkData, address linker, bytes32 linkType, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

### unlinkCharacterLink

```solidity
function unlinkCharacterLink(uint256 fromCharacterId, struct DataTypes.CharacterLinkStruct linkData, bytes32 linkType, address linklist, uint256 linklistId) external
```

### linkLinklist

```solidity
function linkLinklist(struct DataTypes.linkLinklistData vars, address linker, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

### unlinkLinklist

```solidity
function unlinkLinklist(struct DataTypes.unlinkLinklistData vars, address linklist, uint256 linklistId) external
```

### linkERC721

```solidity
function linkERC721(struct DataTypes.linkERC721Data vars, address linker, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

### unlinkERC721

```solidity
function unlinkERC721(struct DataTypes.unlinkERC721Data vars, address linklist, uint256 linklistId) external
```

### linkAddress

```solidity
function linkAddress(struct DataTypes.linkAddressData vars, address linker, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

### unlinkAddress

```solidity
function unlinkAddress(struct DataTypes.unlinkAddressData vars, address linklist, uint256 linklistId) external
```

### linkAnyUri

```solidity
function linkAnyUri(struct DataTypes.linkAnyUriData vars, address linker, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

### unlinkAnyUri

```solidity
function unlinkAnyUri(struct DataTypes.unlinkAnyUriData vars, address linklist, uint256 linklistId) external
```

### _mintLinklist

```solidity
function _mintLinklist(uint256 fromCharacterId, bytes32 linkType, address to, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) internal returns (uint256 linklistId)
```

