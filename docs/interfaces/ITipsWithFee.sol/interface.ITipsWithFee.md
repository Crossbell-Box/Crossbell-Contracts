# ITipsWithFee
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/2d08a9f4cef4a2158ae20c73ee9538b7b9038f8e/contracts/interfaces/ITipsWithFee.sol)

This is the interface for the TipsWithFee contract.

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
### initialize

Initializes the TipsWithFee.


```solidity
function initialize(address web3Entry_, address token_) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`web3Entry_`|`address`|Address of web3Entry.|
|`token_`|`address`|Address of token.|


### setDefaultFeeFraction

Changes the default fee percentage of specific receiver.

*The receiver can be a platform account.*


```solidity
function setDefaultFeeFraction(address receiver, uint256 fraction) external;
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
function setFeeFraction4Character(address receiver, uint256 characterId, uint256 fraction) external;
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
function setFeeFraction4Note(address receiver, uint256 characterId, uint256 noteId, uint256 fraction) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|The fee receiver address.|
|`characterId`|`uint256`|The character ID .|
|`noteId`|`uint256`|The note ID .|
|`fraction`|`uint256`|The percentage measured in basis points. Each basis point represents 0.01%.|


### getFeeFraction

Returns the fee percentage of specific <receiver, note>.

*It will return the first non-zero value by priority feeFraction4Note,
feeFraction4Character and defaultFeeFraction.*


```solidity
function getFeeFraction(address receiver, uint256 characterId, uint256 noteId) external view returns (uint256);
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


### getWeb3Entry

Returns the address of web3Entry contract.


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


