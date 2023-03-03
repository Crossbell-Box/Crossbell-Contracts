# NewbieVilla
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/3060ff9b47459c3bc54ac39115cb04b01451f340/contracts/misc/NewbieVilla.sol)

**Inherits:**
Initializable, AccessControlEnumerable, IERC721Receiver, IERC777Recipient

*Implementation of a contract to keep characters for others. The address with
the ADMIN_ROLE are expected to issue the proof to users. Then users could use the
proof to withdraw the corresponding character.*


## State Variables
### ADMIN_ROLE

```solidity
bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
```


### ERC1820_REGISTRY

```solidity
IERC1820Registry public constant ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
```


### TOKENS_RECIPIENT_INTERFACE_HASH

```solidity
bytes32 public constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
```


### web3Entry

```solidity
address public web3Entry;
```


### xsyncOperator

```solidity
address public xsyncOperator;
```


### _token

```solidity
address internal _token;
```


### _balances

```solidity
mapping(uint256 => uint256) internal _balances;
```


## Functions
### notExpired


```solidity
modifier notExpired(uint256 expires);
```

### initialize

Initialize the Newbie Villa contract.

*msg.sender will be granted `DEFAULT_ADMIN_ROLE`.*


```solidity
function initialize(address web3Entry_, address xsyncOperator_, address token_, address admin_)
    external
    reinitializer(2);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`web3Entry_`|`address`|Address of web3Entry contract.|
|`xsyncOperator_`|`address`|Address of xsyncOperator.|
|`token_`|`address`|Address of ERC777 token.|
|`admin_`|`address`|Address of admin.|


### withdraw

Withdraw character#`characterId` to `to` using the nonce, expires and the proof.
Emits the `Withdraw` event.

*Proof is the signature from someone with the ADMIN_ROLE. The message to sign is
the packed data of this contract's address, `characterId`, `nonce` and `expires`.
Here's an example to generate a proof:
```
digest = ethers.utils.arrayify(
ethers.utils.solidityKeccak256(
["address", "uint256", "uint256", "uint256"],
[newbieVilla.address, characterId, nonce, expires]
)
);
proof = await owner.signMessage(digest);
```
Requirements:
- `expires` is greater than the current timestamp
- `proof` is signed by the one with the ADMIN_ROLE*


```solidity
function withdraw(address to, uint256 characterId, uint256 nonce, uint256 expires, bytes calldata proof)
    external
    notExpired(expires);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`| Receiver of the withdrawn character.|
|`characterId`|`uint256`| The token id of the character to withdraw.|
|`nonce`|`uint256`| Random nonce used to generate the proof.|
|`expires`|`uint256`| Expire time of the proof, Unix timestamp in seconds.|
|`proof`|`bytes`| The proof using to withdraw the character.|


### onERC721Received

*Whenever a character `tokenId` is transferred to this contract via {IERC721-safeTransferFrom}
by `operator` from `from`, this function is called. `data` will be decoded as an address and set as
the operator of the character. If the `data` is empty, the `operator` will be default operator of the
character.
Requirements:
- `msg.sender` must be address of Web3Entry.
- `operator` must has ADMIN_ROLE.*


```solidity
function onERC721Received(address operator, address, uint256 tokenId, bytes calldata data)
    external
    override
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`operator`|`address`||
|`<none>`|`address`||
|`tokenId`|`uint256`||
|`data`|`bytes`|bytes encoded from the operator address to set for the incoming character.|


### tokensReceived


```solidity
function tokensReceived(
    address,
    address,
    address to,
    uint256 amount,
    bytes calldata userData,
    bytes calldata operatorData
) external override(IERC777Recipient);
```

### balanceOf

*The userData/operatorData should be an abi encoded bytes of `fromCharacterId` and `toCharacter`,
which are both uint256 type, so the length of data is 64.*

*Returns the amount of tokens owned by `characterId`.*


```solidity
function balanceOf(uint256 characterId) external view returns (uint256);
```

### getToken

Returns the address of mira token contract.


```solidity
function getToken() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of mira token contract.|


## Events
### Withdraw
*Emitted when the web3Entry character nft is withdrawn.*


```solidity
event Withdraw(address to, uint256 characterId, address token, uint256 amount);
```

