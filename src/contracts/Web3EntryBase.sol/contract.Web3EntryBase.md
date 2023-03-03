# Web3EntryBase
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/c7f31e42711569b1cb499ae27680e91d1ff85e00/contracts/Web3EntryBase.sol)

**Inherits:**
[IWeb3Entry](/contracts/interfaces/IWeb3Entry.sol/contract.IWeb3Entry.md), Multicall, [NFTBase](/contracts/base/NFTBase.sol/contract.NFTBase.md), [Web3EntryStorage](/contracts/storage/Web3EntryStorage.sol/contract.Web3EntryStorage.md), Initializable, [Web3EntryExtendStorage](/contracts/storage/Web3EntryExtendStorage.sol/contract.Web3EntryExtendStorage.md)


## State Variables
### REVISION

```solidity
uint256 internal constant REVISION = 4;
```


## Functions
### initialize


```solidity
function initialize(
    string calldata name_,
    string calldata symbol_,
    address linklist_,
    address mintNFTImpl_,
    address periphery_,
    address newbieVilla_
) external override reinitializer(2);
```

### grantOperatorPermissions

Grant an address as an operator and authorize it with custom permissions.

*Every bit in permissionBitMap stands for a corresponding method in Web3Entry. more details in OP.sol.*


```solidity
function grantOperatorPermissions(uint256 characterId, address operator, uint256 permissionBitMap) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterId`|`uint256`|ID of your character that you want to authorize.|
|`operator`|`address`|Address to grant operator permissions to.|
|`permissionBitMap`|`uint256`|Bitmap used for finer grained operator permissions controls.|


### grantOperators4Note

Grant operators allowlist and blocklist roles of a note.


```solidity
function grantOperators4Note(
    uint256 characterId,
    uint256 noteId,
    address[] calldata blocklist,
    address[] calldata allowlist
) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterId`|`uint256`|ID of character that you want to set.|
|`noteId`|`uint256`|ID of note that you want to set.|
|`blocklist`|`address[]`|blocklist addresses that you want to grant.|
|`allowlist`|`address[]`|allowlist addresses that you want to grant.|


### createCharacter

This method creates a character with the given parameters to the given address.


```solidity
function createCharacter(DataTypes.CreateCharacterData calldata vars) external override returns (uint256 characterId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`vars`|`CreateCharacterData.DataTypes`|The CreateCharacterData struct containing the following parameters: to: The address receiving the character. handle: The handle to set for the character. uri: The URI to set for the character metadata. linkModule: The link module to use, can be the zero address. linkModuleInitData: The link module initialization data, if any.|


### setHandle


```solidity
function setHandle(uint256 characterId, string calldata newHandle) external override;
```

### setSocialToken


```solidity
function setSocialToken(uint256 characterId, address tokenAddress) external override;
```

### setPrimaryCharacterId


```solidity
function setPrimaryCharacterId(uint256 characterId) external override;
```

### setCharacterUri


```solidity
function setCharacterUri(uint256 characterId, string calldata newUri) external override;
```

### setLinklistUri


```solidity
function setLinklistUri(uint256 linklistId, string calldata uri) external override;
```

### linkCharacter


```solidity
function linkCharacter(DataTypes.linkCharacterData calldata vars) external override;
```

### unlinkCharacter


```solidity
function unlinkCharacter(DataTypes.unlinkCharacterData calldata vars) external override;
```

### createThenLinkCharacter


```solidity
function createThenLinkCharacter(DataTypes.createThenLinkCharacterData calldata vars) external override;
```

### linkNote


```solidity
function linkNote(DataTypes.linkNoteData calldata vars) external override;
```

### unlinkNote


```solidity
function unlinkNote(DataTypes.unlinkNoteData calldata vars) external override;
```

### linkERC721


```solidity
function linkERC721(DataTypes.linkERC721Data calldata vars) external override;
```

### unlinkERC721


```solidity
function unlinkERC721(DataTypes.unlinkERC721Data calldata vars) external override;
```

### linkAddress


```solidity
function linkAddress(DataTypes.linkAddressData calldata vars) external override;
```

### unlinkAddress


```solidity
function unlinkAddress(DataTypes.unlinkAddressData calldata vars) external override;
```

### linkAnyUri


```solidity
function linkAnyUri(DataTypes.linkAnyUriData calldata vars) external override;
```

### unlinkAnyUri


```solidity
function unlinkAnyUri(DataTypes.unlinkAnyUriData calldata vars) external override;
```

### linkLinklist


```solidity
function linkLinklist(DataTypes.linkLinklistData calldata vars) external override;
```

### unlinkLinklist


```solidity
function unlinkLinklist(DataTypes.unlinkLinklistData calldata vars) external override;
```

### setLinkModule4Linklist

set link module for his character

Set linkModule for a ERC721 token that you own.

*Operators can't setLinkModule4ERC721, because operators are set for
characters but erc721 tokens belong to address and not characters.*


```solidity
function setLinkModule4Linklist(DataTypes.setLinkModule4LinklistData calldata vars) external override;
```

### setLinkModule4Address

Set linkModule for an address.

*Operators can't setLinkModule4Address, because this linkModule is for
addresses and is irrelevan to characters.*


```solidity
function setLinkModule4Address(DataTypes.setLinkModule4AddressData calldata vars) external override;
```

### mintNote


```solidity
function mintNote(DataTypes.MintNoteData calldata vars) external override returns (uint256 tokenId);
```

### setMintModule4Note


```solidity
function setMintModule4Note(DataTypes.setMintModule4NoteData calldata vars) external override;
```

### postNote


```solidity
function postNote(DataTypes.PostNoteData calldata vars) external override returns (uint256 noteId);
```

### setNoteUri


```solidity
function setNoteUri(uint256 characterId, uint256 noteId, string calldata newUri) external override;
```

### lockNote

lockNote put a note into a immutable state where no modifications are
allowed. You should call this method to announce that this is the final version.


```solidity
function lockNote(uint256 characterId, uint256 noteId) external override;
```

### deleteNote


```solidity
function deleteNote(uint256 characterId, uint256 noteId) external override;
```

### postNote4Character


```solidity
function postNote4Character(DataTypes.PostNoteData calldata vars, uint256 toCharacterId)
    external
    override
    returns (uint256);
```

### postNote4Address


```solidity
function postNote4Address(DataTypes.PostNoteData calldata vars, address ethAddress)
    external
    override
    returns (uint256);
```

### postNote4Linklist


```solidity
function postNote4Linklist(DataTypes.PostNoteData calldata vars, uint256 toLinklistId)
    external
    override
    returns (uint256);
```

### postNote4Note


```solidity
function postNote4Note(DataTypes.PostNoteData calldata vars, DataTypes.NoteStruct calldata note)
    external
    override
    returns (uint256);
```

### postNote4ERC721


```solidity
function postNote4ERC721(DataTypes.PostNoteData calldata vars, DataTypes.ERC721Struct calldata erc721)
    external
    override
    returns (uint256);
```

### postNote4AnyUri


```solidity
function postNote4AnyUri(DataTypes.PostNoteData calldata vars, string calldata uri)
    external
    override
    returns (uint256);
```

### getOperators

Get operator list of a character. This operator list has only a sole purpose, which is
keeping records of keys of `operatorsPermissionBitMap`. Thus, addresses queried by this function
not always have operator permissions. Keep in mind don't use this function to check
authorizations!!!


```solidity
function getOperators(uint256 characterId) external view override returns (address[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterId`|`uint256`|ID of your character that you want to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|All keys of operatorsPermission4NoteBitMap.|


### getOperatorPermissions

Get permission bitmap of an operator.


```solidity
function getOperatorPermissions(uint256 characterId, address operator) external view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterId`|`uint256`|ID of character that you want to check.|
|`operator`|`address`|Address to grant operator permissions to.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Permission bitmap of this operator.|


### getOperators4Note

Get operators blocklist and allowlist for a note.


```solidity
function getOperators4Note(uint256 characterId, uint256 noteId)
    external
    view
    override
    returns (address[] memory blocklist, address[] memory allowlist);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterId`|`uint256`|ID of character to query.|
|`noteId`|`uint256`|ID of note to query.|


### isOperatorAllowedForNote

Query if a operator has permission for a note.


```solidity
function isOperatorAllowedForNote(uint256 characterId, uint256 noteId, address operator)
    external
    view
    override
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`characterId`|`uint256`|ID of character that you want to query.|
|`noteId`|`uint256`|ID of note that you want to query.|
|`operator`|`address`|Address to query.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if Operator has permission for a note, otherwise false.|


### getPrimaryCharacterId


```solidity
function getPrimaryCharacterId(address account) external view override returns (uint256);
```

### isPrimaryCharacter


```solidity
function isPrimaryCharacter(uint256 characterId) external view override returns (bool);
```

### getCharacter


```solidity
function getCharacter(uint256 characterId) external view override returns (DataTypes.Character memory);
```

### getCharacterByHandle


```solidity
function getCharacterByHandle(string calldata handle) external view override returns (DataTypes.Character memory);
```

### getHandle


```solidity
function getHandle(uint256 characterId) external view override returns (string memory);
```

### getCharacterUri


```solidity
function getCharacterUri(uint256 characterId) external view override returns (string memory);
```

### getNote


```solidity
function getNote(uint256 characterId, uint256 noteId) external view override returns (DataTypes.Note memory);
```

### getLinkModule4Address


```solidity
function getLinkModule4Address(address account) external view override returns (address);
```

### getLinkModule4Linklist


```solidity
function getLinkModule4Linklist(uint256 tokenId) external view override returns (address);
```

### getLinkModule4ERC721


```solidity
function getLinkModule4ERC721(address tokenAddress, uint256 tokenId) external view override returns (address);
```

### getLinklistUri


```solidity
function getLinklistUri(uint256 tokenId) external view override returns (string memory);
```

### getLinklistId


```solidity
function getLinklistId(uint256 characterId, bytes32 linkType) external view override returns (uint256);
```

### getLinklistType


```solidity
function getLinklistType(uint256 linkListId) external view override returns (bytes32);
```

### getLinklistContract


```solidity
function getLinklistContract() external view override returns (address);
```

### getRevision


```solidity
function getRevision() external pure override returns (uint256);
```

### burn


```solidity
function burn(uint256 tokenId) public virtual override;
```

### tokenURI


```solidity
function tokenURI(uint256 characterId) public view override returns (string memory);
```

### _createThenLinkCharacter


```solidity
function _createThenLinkCharacter(uint256 fromCharacterId, address to, bytes32 linkType, bytes memory data) internal;
```

### _beforeTokenTransfer

*Operators will be reset to blank before the characters are transferred in order to grant the
whole control power to receivers of character transfers.
If character is transferred from newbieVilla contract, don't clear operators.
Permissions4Note is left unset, because permissions for notes are always stricter than default.*


```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override;
```

### _afterTokenTransfer


```solidity
function _afterTokenTransfer(address from, address to, uint256 tokenId) internal virtual override;
```

### _nextNoteId


```solidity
function _nextNoteId(uint256 characterId) internal returns (uint256);
```

### _clearOperator


```solidity
function _clearOperator(uint256 tokenId, address operator) internal;
```

### _isOperatorAllowedForNote


```solidity
function _isOperatorAllowedForNote(uint256 characterId, uint256 noteId, address operator)
    internal
    view
    returns (bool);
```

### _checkHandleExists


```solidity
function _checkHandleExists(bytes32 handleHash) internal view;
```

### _validateCallerIsCharacterOwner


```solidity
function _validateCallerIsCharacterOwner(uint256 characterId) internal view;
```

### _validateCallerPermission


```solidity
function _validateCallerPermission(uint256 characterId, uint256 permissionId) internal view;
```

### _callerIsCharacterOwner


```solidity
function _callerIsCharacterOwner(uint256 characterId) internal view returns (bool);
```

### _validateCallerPermission4Note


```solidity
function _validateCallerPermission4Note(uint256 characterId, uint256 noteId) internal view;
```

### _validateCharacterExists


```solidity
function _validateCharacterExists(uint256 characterId) internal view;
```

### _validateNoteExists


```solidity
function _validateNoteExists(uint256 characterId, uint256 noteId) internal view;
```

### _validateNoteNotLocked


```solidity
function _validateNoteNotLocked(uint256 characterId, uint256 noteId) internal view;
```

### _validateHandle


```solidity
function _validateHandle(string calldata handle) internal pure;
```

### _validateChar


```solidity
function _validateChar(bytes1 c) internal pure;
```

### _checkBit

*_checkBit checks if the value of the i'th bit of x is 1*


```solidity
function _checkBit(uint256 x, uint256 i) internal pure returns (bool);
```

