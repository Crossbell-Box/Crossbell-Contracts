# Solidity API

## Tips

_Logic to handle rewards that user can send to character and note._

### web3Entry

```solidity
address web3Entry
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
function initialize(address web3Entry_) external
```

Initialize the contract.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| web3Entry_ | address | Address of web3Entry. |

### tipCharacter

```solidity
function tipCharacter(uint256 fromCharacterId, uint256 toCharacterId, address token, uint256 amount) external
```

Tips a character by transferring `amount` tokens
from the `fromCharacterId` account to `toCharacterId` account.
Emits the `ThankCharacter` event.

Requirements:
- The caller must be the character owner of `fromCharacterId.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The token ID of character that calls this contract. |
| toCharacterId | uint256 | The token ID of character that will receive the token. |
| token | address | Address of token. |
| amount | uint256 | Amount of token. |

### tipCharacterForNote

```solidity
function tipCharacterForNote(uint256 fromCharacterId, uint256 toCharacterId, uint256 toNoteId, address token, uint256 amount) external
```

Tips a character's note by transferring `amount` tokens
from the `fromCharacterId` account to `toCharacterId` account.
Emits the `ThankNote` event.

Requirements:
- The caller must be the character owner of `fromCharacterId.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| fromCharacterId | uint256 | The token ID of character that calls this contract. |
| toCharacterId | uint256 | The token ID of character that will receive the token. |
| toNoteId | uint256 | The note ID. |
| token | address | Address of token. |
| amount | uint256 | Amount of token. |

