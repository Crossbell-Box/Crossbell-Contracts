# Solidity API

## Tips

_Logic to handle rewards that user can send to character and note._

### ERC1820_REGISTRY

```solidity
contract IERC1820Registry ERC1820_REGISTRY
```

### TOKENS_RECIPIENT_INTERFACE_HASH

```solidity
bytes32 TOKENS_RECIPIENT_INTERFACE_HASH
```

### _web3Entry

```solidity
address _web3Entry
```

### _token

```solidity
address _token
```

### ErrCallerNotCharacterOwner

```solidity
error ErrCallerNotCharacterOwner()
```

### TipCharacter

```solidity
event TipCharacter(uint256 fromCharacterId, uint256 toCharacterId, address token, uint256 amount)
```

_Emitted when the assets are rewarded to a character._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The token ID of character that initiated a reward. |
| toCharacterId | uint256 | The token ID of character that. |
| token | address | Address of token to reward. |
| amount | uint256 | Amount of token to reward. |

### TipCharacterForNote

```solidity
event TipCharacterForNote(uint256 fromCharacterId, uint256 toCharacterId, uint256 toNoteId, address token, uint256 amount)
```

_Emitted when the assets are rewarded to a note._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The token ID of character that calls this contract. |
| toCharacterId | uint256 | The token ID of character that will receive the token. |
| toNoteId | uint256 | The note ID. |
| token | address | Address of token. |
| amount | uint256 | Amount of token. |

### initialize

```solidity
function initialize(address web3Entry_, address token_) external
```

Initialize the contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| web3Entry_ | address | Address of web3Entry. |
| token_ | address |  |

### tokensReceived

```solidity
function tokensReceived(address, address from, address to, uint256 amount, bytes userData, bytes operatorData) external
```

_Called by an {IERC777} token contract whenever tokens are being
moved or created into a registered account (`to`). The type of operation
is conveyed by `from` being the zero address or not.

This call occurs _after_ the token contract's state is updated, so
{IERC777-balanceOf}, etc., can be used to query the post-operation state.

This function may revert to prevent the operation from being executed._

### getWeb3Entry

```solidity
function getWeb3Entry() external view returns (address)
```

Returns the address of web3Entry contract.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address of web3Entry contract. |

### getToken

```solidity
function getToken() external view returns (address)
```

Returns the address of mira token contract.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address of mira token contract. |

### _tipCharacter

```solidity
function _tipCharacter(address from, uint256 fromCharacterId, uint256 toCharacterId, address token, uint256 amount) internal
```

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

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | The caller's account who sends token. |
| fromCharacterId | uint256 | The token ID of character that calls this contract. |
| toCharacterId | uint256 | The token ID of character that will receive the token. |
| token | address | Address of token. |
| amount | uint256 | Amount of token. |

### _tipCharacterForNote

```solidity
function _tipCharacterForNote(address from, uint256 fromCharacterId, uint256 toCharacterId, uint256 toNoteId, address token, uint256 amount) internal
```

Tips a character's note by transferring `amount` tokens
from the `fromCharacterId` account to `toCharacterId` account.
Emits the `ThankNote` event.

User should call `send` erc777 token to the Tips contract, with `fromCharacterId`,
 `toCharacterId` and `toNoteId` encoded in the `data`.

Requirements:
- The `from` account must be the character owner of `fromCharacterId.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | The caller's account who sends token. |
| fromCharacterId | uint256 | The token ID of character that calls this contract. |
| toCharacterId | uint256 | The token ID of character that will receive the token. |
| toNoteId | uint256 | The note ID. |
| token | address | Address of token. |
| amount | uint256 | Amount of token. |

### _sendToken

```solidity
function _sendToken(address from, uint256 fromCharacterId, uint256 toCharacterId, address token, uint256 amount) internal
```

