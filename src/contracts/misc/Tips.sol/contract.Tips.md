# Tips
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/c7f31e42711569b1cb499ae27680e91d1ff85e00/contracts/misc/Tips.sol)

**Inherits:**
Initializable, IERC777Recipient

*Logic to handle rewards that user can send to character and note.*


## State Variables
### ERC1820_REGISTRY

```solidity
IERC1820Registry public constant ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
```


### TOKENS_RECIPIENT_INTERFACE_HASH

```solidity
bytes32 public constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
```


### _web3Entry

```solidity
address internal _web3Entry;
```


### _token

```solidity
address internal _token;
```


## Functions
### initialize

Initialize the contract.


```solidity
function initialize(address web3Entry_, address token_) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`web3Entry_`|`address`|Address of web3Entry.|
|`token_`|`address`||


### tokensReceived


```solidity
function tokensReceived(
    address,
    address from,
    address to,
    uint256 amount,
    bytes calldata userData,
    bytes calldata operatorData
) external override(IERC777Recipient);
```

### getWeb3Entry

Returns the address of web3Entry contract.

*The userData/operatorData should be an abi encoded bytes of `fromCharacterId`, `toCharacter`
and `toNoteId`(optional),  which are all uint256 type, so the length of data is 64 or 96.*


```solidity
function getWeb3Entry() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of web3Entry contract.|


### getToken

Returns the address of mira token contract.


```solidity
function getToken() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of mira token contract.|


### _tipCharacter

Tips a character by transferring `amount` tokens
from the `fromCharacterId` account to `toCharacterId` account.
Emits the `ThankCharacter` event.
User should call `send` erc777 token to the Tips contract, with `fromCharacterId`
and `toCharacterId` encoded in the `data`.
`send` interface is
[IERC777-send](https://docs.openzeppelin.com/contracts/2.x/api/token/erc777#IERC777-send-address-uint256-bytes-),
and parameters encode refers [AbiCoder-encode](https://docs.ethers.org/v5/api/utils/abi/coder/#AbiCoder-encode) .
Requirements:
- The `from` account must be the character owner of `fromCharacterId.


```solidity
function _tipCharacter(address from, uint256 fromCharacterId, uint256 toCharacterId, address token, uint256 amount)
    internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The caller's account who sends token.|
|`fromCharacterId`|`uint256`|The token ID of character that calls this contract.|
|`toCharacterId`|`uint256`|The token ID of character that will receive the token.|
|`token`|`address`|Address of token.|
|`amount`|`uint256`|Amount of token.|


### _tipCharacterForNote

Tips a character's note by transferring `amount` tokens
from the `fromCharacterId` account to `toCharacterId` account.
Emits the `ThankNote` event.
User should call `send` erc777 token to the Tips contract, with `fromCharacterId`,
`toCharacterId` and `toNoteId` encoded in the `data`.
Requirements:
- The `from` account must be the character owner of `fromCharacterId.


```solidity
function _tipCharacterForNote(
    address from,
    uint256 fromCharacterId,
    uint256 toCharacterId,
    uint256 toNoteId,
    address token,
    uint256 amount
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The caller's account who sends token.|
|`fromCharacterId`|`uint256`|The token ID of character that calls this contract.|
|`toCharacterId`|`uint256`|The token ID of character that will receive the token.|
|`toNoteId`|`uint256`|The note ID.|
|`token`|`address`|Address of token.|
|`amount`|`uint256`|Amount of token.|


### _sendToken


```solidity
function _sendToken(address from, uint256 fromCharacterId, uint256 toCharacterId, address token, uint256 amount)
    internal;
```

## Events
### TipCharacter
*Emitted when the assets are rewarded to a character.*


```solidity
event TipCharacter(uint256 indexed fromCharacterId, uint256 indexed toCharacterId, address token, uint256 amount);
```

### TipCharacterForNote
*Emitted when the assets are rewarded to a note.*


```solidity
event TipCharacterForNote(
    uint256 indexed fromCharacterId,
    uint256 indexed toCharacterId,
    uint256 indexed toNoteId,
    address token,
    uint256 amount
);
```

## Errors
### ErrCallerNotCharacterOwner

```solidity
error ErrCallerNotCharacterOwner();
```

