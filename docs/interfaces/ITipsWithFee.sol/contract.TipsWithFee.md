# TipsWithFee
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/e766977bdc30280fa526980b0d06830fcccb4412/contracts/misc/TipsWithFee.sol)

**Inherits:**
[ITipsWithFee](/contracts/interfaces/ITipsWithFee.sol/interface.ITipsWithFee.md), Initializable, IERC777Recipient

*Logic to handle rewards that user can send to character and note.*

*The platform can set the commission ratio through the TipsWithFee contract,
and draw a commission from the user's tips. <br>
For `TipCharacter`
User/Client should call `send` erc777 token to the TipsWithFee contract, with `fromCharacterId`,
`toCharacterId` and `receiver`(a platform account) encoded in the `data`. <br>
`send` interface is
[IERC777-send](https://docs.openzeppelin.com/contracts/2.x/api/token/erc777#IERC777-send-address-uint256-bytes-),
and parameters encode refers
[AbiCoder-encode](https://docs.ethers.org/v5/api/utils/abi/coder/#AbiCoder-encode).<br>
For `TipCharacter4Note`
User should call `send` erc777 token to the TipsWithFee contract, with `fromCharacterId`,
`toCharacterId`, `toNoteId` and `receiver` encoded in the `data`. <br>
The platform account can set the commission ratio through `setDefaultFeeFraction`, `setFeeFraction4Character` and `setFeeFraction4Note`.*


## Functions

### setDefaultFeeFraction

Changes the default fee percentage of specific receiver.

*The receiver can be a platform account.*


```solidity
function setDefaultFeeFraction(address receiver, uint256 fraction) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|The fee receiver address.|
|`fraction`|`uint256`|The percentage measured in basis points. Each basis point represents 0.01%.|


### setFeeFraction4Character

Changes the fee percentage of specific <receiver, character>.

*If feeFraction4Character is set, it will override the default fee fraction.*


```solidity
function setFeeFraction4Character(address receiver, uint256 characterId, uint256 fraction) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|The fee receiver address.|
|`characterId`|`uint256`|The character ID.|
|`fraction`|`uint256`|The percentage measured in basis points. Each basis point represents 0.01%.|


### setFeeFraction4Note

Changes the fee percentage of specific <receiver, note>.

*If feeFraction4Note is set, it will override feeFraction4Character and the default fee fraction.*


```solidity
function setFeeFraction4Note(address receiver, uint256 characterId, uint256 noteId, uint256 fraction)
    external
    override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|The fee receiver address.|
|`characterId`|`uint256`|The character ID .|
|`noteId`|`uint256`|The note ID .|
|`fraction`|`uint256`|The percentage measured in basis points. Each basis point represents 0.01%.|


### tokensReceived

*Called by an {IERC777} token contract whenever tokens are being
moved or created into a registered account `to` (this contract). <br>
The userData/operatorData should be an abi encoded bytes of `fromCharacterId`, `toCharacter`
and `toNoteId`(optional) and `receiver`(platform account), so the length of data is 84 or 116.*


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


```solidity
function getWeb3Entry() external view override returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of web3Entry contract.|


### getToken

Returns the address of mira token contract.


```solidity
function getToken() external view override returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of mira token contract.|


### getFeeFraction

Returns the fee percentage of specific <receiver, note>.

*It will return the first non-zero value by priority feeFraction4Note,
feeFraction4Character and defaultFeeFraction.*


```solidity
function getFeeFraction(address receiver, uint256 characterId, uint256 noteId)
    external
    view
    override
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|The fee receiver address.|
|`characterId`|`uint256`|The character ID .|
|`noteId`|`uint256`|The note ID .|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|fraction The percentage measured in basis points. Each basis point represents 0.01%.|


### getFeeAmount

Returns how much the fee is owed by <feeFraction, tipAmount>.


```solidity
function getFeeAmount(address receiver, uint256 characterId, uint256 noteId, uint256 tipAmount)
    external
    view
    override
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|The fee receiver address.|
|`characterId`|`uint256`|The character ID .|
|`noteId`|`uint256`|The note ID .|
|`tipAmount`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The fee amount.|


### _tipCharacter

Tips a character by transferring `amount` tokens
from the `fromCharacterId` account to `toCharacterId` account. <br>
Emits the `TipCharacter` event. <br>
User should call `send` erc777 token to the Tips contract, with `fromCharacterId`
and `toCharacterId` encoded in the `data`. <br>
`send` interface is
[IERC777-send](https://docs.openzeppelin.com/contracts/2.x/api/token/erc777#IERC777-send-address-uint256-bytes-),
and parameters encode refers
[AbiCoder-encode](https://docs.ethers.org/v5/api/utils/abi/coder/#AbiCoder-encode).<br>
<b> Requirements: </b>
- The `from` account must be the character owner of `fromCharacterId.


```solidity
function _tipCharacter(
    address from,
    uint256 fromCharacterId,
    uint256 toCharacterId,
    address token,
    uint256 amount,
    address feeReceiver
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|The caller's account who sends token.|
|`fromCharacterId`|`uint256`|The token ID of character that calls this contract.|
|`toCharacterId`|`uint256`|The token ID of character that will receive the token.|
|`token`|`address`|Address of token.|
|`amount`|`uint256`|Amount of token.|
|`feeReceiver`|`address`|Fee receiver address.|


### _tipCharacterForNote

Tips a character's note by transferring `amount` tokens
from the `fromCharacterId` account to `toCharacterId` account. <br>
Emits the `TipCharacterForNote` event. <br>
User should call `send` erc777 token to the Tips contract, with `fromCharacterId`,
`toCharacterId` and `toNoteId` encoded in the `data`. <br>
<b> Requirements: </b>
- The `from` account must be the character owner of `fromCharacterId.


```solidity
function _tipCharacterForNote(
    address from,
    uint256 fromCharacterId,
    uint256 toCharacterId,
    uint256 toNoteId,
    address token,
    uint256 amount,
    address feeReceiver
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
|`feeReceiver`|`address`|Fee receiver address.|


### _sendToken


```solidity
function _sendToken(
    address from,
    uint256 fromCharacterId,
    uint256 toCharacterId,
    address token,
    uint256 amount,
    uint256 feeAmount,
    address feeReceiver
) internal;
```

### _getFeeFraction


```solidity
function _getFeeFraction(address receiver, uint256 characterId, uint256 noteId) internal view returns (uint256);
```

### _getFeeAmount


```solidity
function _getFeeAmount(address receiver, uint256 characterId, uint256 noteId, uint256 tipAmount)
    internal
    view
    returns (uint256);
```

### _feeDenominator

*Defaults to 10000 so fees are expressed in basis points.*


```solidity
function _feeDenominator() internal pure virtual returns (uint96);
```

## Events
### TipCharacter
*Emitted when the assets are rewarded to a character.*


```solidity
event TipCharacter(
    uint256 indexed fromCharacterId,
    uint256 indexed toCharacterId,
    address token,
    uint256 amount,
    uint256 fee,
    address feeReceiver
);
```

### TipCharacterForNote
*Emitted when the assets are rewarded to a note.*


```solidity
event TipCharacterForNote(
    uint256 indexed fromCharacterId,
    uint256 indexed toCharacterId,
    uint256 indexed toNoteId,
    address token,
    uint256 amount,
    uint256 fee,
    address feeReceiver
);
```

## Errors
### ErrCallerNotCharacterOwner

```solidity
error ErrCallerNotCharacterOwner();
```

### ErrCallerNotOwner

```solidity
error ErrCallerNotOwner();
```

### ErrOutOfRange

```solidity
error ErrOutOfRange();
```

