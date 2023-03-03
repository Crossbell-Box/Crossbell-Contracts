# Solidity API

## LinkLogic

### linkCharacter

```solidity
function linkCharacter(uint256 fromCharacterId, uint256 toCharacterId, bytes32 linkType, bytes data, address linklist, address linkModule, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

Link any characterId.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The characterId to sponsor a link action. |
| toCharacterId | uint256 | The characterId to be linked. |
| linkType | bytes32 | linkType, like “follow”. |
| data | bytes | The data to pass to the link module, if any. |
| linklist | address | The linklist contract address. |
| linkModule | address | The linkModule address of the character to link. |
| _attachedLinklists | mapping(uint256 &#x3D;&gt; mapping(bytes32 &#x3D;&gt; uint256)) |  |

### unlinkCharacter

```solidity
function unlinkCharacter(uint256 fromCharacterId, uint256 toCharacterId, bytes32 linkType, address linklist, uint256 linklistId) external
```

Unlinks a given character.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The characterId to sponsor a unlink action. |
| toCharacterId | uint256 | The characterId to be unlinked. |
| linkType | bytes32 | linkType, like “follow”. |
| linklist | address | The linklist contract address. |
| linklistId | uint256 | The ID of the linklist to unlink. |

### linkNote

```solidity
function linkNote(uint256 fromCharacterId, uint256 toCharacterId, uint256 toNoteId, bytes32 linkType, bytes data, address linklist, address linkModule, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

Links a given note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The characterId to sponsor a link action. |
| toCharacterId | uint256 | The owner characterId of the note to link. |
| toNoteId | uint256 | The id of the note to link. |
| linkType | bytes32 | The linkType, like “follow”. |
| data | bytes | The data to pass to the link module, if any. |
| linklist | address | The linklist contract address. |
| linkModule | address | The linkModule address of the note to link |
| _attachedLinklists | mapping(uint256 &#x3D;&gt; mapping(bytes32 &#x3D;&gt; uint256)) |  |

### unlinkNote

```solidity
function unlinkNote(uint256 fromCharacterId, uint256 toCharacterId, uint256 toNoteId, bytes32 linkType, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

Unlinks a given note.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The character Id to sponsor an unlink action. |
| toCharacterId | uint256 | The characterId of note to unlink. |
| toNoteId | uint256 | The id of note to unlink. |
| linkType | bytes32 | LinkType, like “follow”. |
| linklist | address | The linklist contract address. |
| _attachedLinklists | mapping(uint256 &#x3D;&gt; mapping(bytes32 &#x3D;&gt; uint256)) |  |

### linkCharacterLink

```solidity
function linkCharacterLink(uint256 fromCharacterId, uint256 toCharacterId, bytes32 linkType, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

Links a characterLink.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The from character id of characterLink. |
| toCharacterId | uint256 | The to character id of characterLink. |
| linkType | bytes32 | The linkType of characterLink. |
| linklist | address | The linklist contract address. |
| _attachedLinklists | mapping(uint256 &#x3D;&gt; mapping(bytes32 &#x3D;&gt; uint256)) |  |

### unlinkCharacterLink

```solidity
function unlinkCharacterLink(uint256 fromCharacterId, uint256 toCharacterId, bytes32 linkType, address linklist, uint256 linklistId) external
```

Unlinks a characterLink.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The from character id of characterLink. |
| toCharacterId | uint256 | The to character id of characterLink. |
| linkType | bytes32 | The linkType of characterLink. |
| linklist | address | The linklist contract address. |
| linklistId | uint256 | The ID of the linklist to unlink. |

### linkLinklist

```solidity
function linkLinklist(uint256 fromCharacterId, uint256 toLinkListId, bytes32 linkType, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

Links a linklist.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The character id to sponsor an link action. |
| toLinkListId | uint256 | The linklist if to link. |
| linkType | bytes32 | LinkType, like “follow”. |
| linklist | address | The linklist contract address. |
| _attachedLinklists | mapping(uint256 &#x3D;&gt; mapping(bytes32 &#x3D;&gt; uint256)) |  |

### unlinkLinklist

```solidity
function unlinkLinklist(uint256 fromCharacterId, uint256 toLinkListId, bytes32 linkType, address linklist, uint256 linklistId) external
```

Unlinks a linklist.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The character id to sponsor an unlink action. |
| toLinkListId | uint256 | The linklist if to unlink. |
| linkType | bytes32 | LinkType, like “follow”. |
| linklist | address | The linklist contract address. |
| linklistId | uint256 | The ID of the linklist to unlink. |

### linkERC721

```solidity
function linkERC721(uint256 fromCharacterId, address tokenAddress, uint256 tokenId, bytes32 linkType, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

Links an ERC721 token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The character Id to sponsor an link action. |
| tokenAddress | address | The token address of ERC721 to link. |
| tokenId | uint256 | The token id of ERC721 to link. |
| linkType | bytes32 | linkType, like “follow”. |
| linklist | address | The linklist contract address. |
| _attachedLinklists | mapping(uint256 &#x3D;&gt; mapping(bytes32 &#x3D;&gt; uint256)) |  |

### unlinkERC721

```solidity
function unlinkERC721(uint256 fromCharacterId, address tokenAddress, uint256 tokenId, bytes32 linkType, address linklist, uint256 linklistId) external
```

Unlinks an ERC721 token.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The character Id to sponsor an unlink action. |
| tokenAddress | address | The token address of ERC721 to unlink. |
| tokenId | uint256 | The token id of ERC721 to unlink. |
| linkType | bytes32 | LinkType, like “follow”. |
| linklist | address | The linklist contract address. |
| linklistId | uint256 | The ID of the linklist to unlink. |

### linkAddress

```solidity
function linkAddress(uint256 fromCharacterId, address ethAddress, bytes32 linkType, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

Create a link to a given address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The character id to init the link. |
| ethAddress | address | The address to link. |
| linkType | bytes32 | LinkType, like “follow”. |
| linklist | address | The linklist contract address. |
| _attachedLinklists | mapping(uint256 &#x3D;&gt; mapping(bytes32 &#x3D;&gt; uint256)) |  |

### unlinkAddress

```solidity
function unlinkAddress(uint256 fromCharacterId, address ethAddress, bytes32 linkType, address linklist, uint256 linklistId) external
```

Unlinks a given address.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The character id to init the unlink. |
| ethAddress | address | The address to unlink. |
| linkType | bytes32 | LinkType, like “follow”. |
| linklist | address | The linklist contract address. |
| linklistId | uint256 | The ID of the linklist to unlink. |

### linkAnyUri

```solidity
function linkAnyUri(uint256 fromCharacterId, string toUri, bytes32 linkType, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) external
```

Links any uri.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The character Id to sponsor an link action. |
| toUri | string | The uri to link. |
| linkType | bytes32 | LinkType, like “follow”. |
| linklist | address | The linklist contract address. |
| _attachedLinklists | mapping(uint256 &#x3D;&gt; mapping(bytes32 &#x3D;&gt; uint256)) |  |

### unlinkAnyUri

```solidity
function unlinkAnyUri(uint256 fromCharacterId, string toUri, bytes32 linkType, address linklist, uint256 linklistId) external
```

Unlinks any uri.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The character Id to sponsor an unlink action. |
| toUri | string | The uri to unlink. |
| linkType | bytes32 | LinkType, like “follow”. |
| linklist | address | The linklist contract address. |
| linklistId | uint256 | The ID of the linklist to unlink. |

### _mintLinklist

```solidity
function _mintLinklist(uint256 fromCharacterId, bytes32 linkType, address linklist, mapping(uint256 => mapping(bytes32 => uint256)) _attachedLinklists) internal returns (uint256 linklistId)
```

Returns the linklistId if the linklist already exists, Otherwise, creates a new 
        linklist and return its ID.

