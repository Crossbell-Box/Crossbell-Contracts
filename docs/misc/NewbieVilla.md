# Solidity API

## NewbieVilla

_Implementation of a contract to keep characters for others. The address with
the ADMIN_ROLE are expected to issue the proof to users. Then users could use the
proof to withdraw the corresponding character._

### ADMIN_ROLE

```solidity
bytes32 ADMIN_ROLE
```

### ERC1820_REGISTRY

```solidity
contract IERC1820Registry ERC1820_REGISTRY
```

### TOKENS_RECIPIENT_INTERFACE_HASH

```solidity
bytes32 TOKENS_RECIPIENT_INTERFACE_HASH
```

### web3Entry

```solidity
address web3Entry
```

### xsyncOperator

```solidity
address xsyncOperator
```

### _token

```solidity
address _token
```

### _balances

```solidity
mapping(uint256 => uint256) _balances
```

### Withdraw

```solidity
event Withdraw(address to, uint256 characterId, address token, uint256 amount)
```

_Emitted when the web3Entry character nft is withdrawn._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The receiver of web3Entry character nft. |
| characterId | uint256 | The character ID. |
| token | address | Addresses of token withdrawn. |
| amount | uint256 | Amount of token withdrawn. |

### notExpired

```solidity
modifier notExpired(uint256 expires)
```

### initialize

```solidity
function initialize(address web3Entry_, address xsyncOperator_, address token_, address admin_) external
```

Initialize the Newbie Villa contract.

_msg.sender will be granted `DEFAULT_ADMIN_ROLE`._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| web3Entry_ | address | Address of web3Entry contract. |
| xsyncOperator_ | address | Address of xsyncOperator. |
| token_ | address | Address of ERC777 token. |
| admin_ | address | Address of admin. |

### withdraw

```solidity
function withdraw(address to, uint256 characterId, uint256 nonce, uint256 expires, bytes proof) external
```

Withdraw character#`characterId` to `to` using the nonce, expires and the proof.
Emits the `Withdraw` event.

_Proof is the signature from someone with the ADMIN_ROLE. The message to sign is
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
- `proof` is signed by the one with the ADMIN_ROLE_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | Receiver of the withdrawn character. |
| characterId | uint256 | The token id of the character to withdraw. |
| nonce | uint256 | Random nonce used to generate the proof. |
| expires | uint256 | Expire time of the proof, Unix timestamp in seconds. |
| proof | bytes | The proof using to withdraw the character. |

### onERC721Received

```solidity
function onERC721Received(address operator, address, uint256 tokenId, bytes data) external returns (bytes4)
```

_Whenever a character `tokenId` is transferred to this contract via {IERC721-safeTransferFrom}
by `operator` from `from`, this function is called. `data` will be decoded as an address and set as
the operator of the character. If the `data` is empty, the `operator` will be default operator of the
character.

Requirements:

- `msg.sender` must be address of Web3Entry.
- `operator` must has ADMIN_ROLE._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| operator | address |  |
|  | address |  |
| tokenId | uint256 |  |
| data | bytes | bytes encoded from the operator address to set for the incoming character. |

### tokensReceived

```solidity
function tokensReceived(address, address, address to, uint256 amount, bytes userData, bytes operatorData) external
```

_Called by an {IERC777} token contract whenever tokens are being
moved or created into a registered account (`to`). The type of operation
is conveyed by `from` being the zero address or not.

This call occurs _after_ the token contract's state is updated, so
{IERC777-balanceOf}, etc., can be used to query the post-operation state.

This function may revert to prevent the operation from being executed._

### balanceOf

```solidity
function balanceOf(uint256 characterId) external view returns (uint256)
```

_Returns the amount of tokens owned by `characterId`._

### getToken

```solidity
function getToken() external view returns (address)
```

Returns the address of mira token contract.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The address of mira token contract. |

### _splitSignature

```solidity
function _splitSignature(bytes sig) internal pure returns (uint8 v, bytes32 r, bytes32 s)
```

### _recoverSigner

```solidity
function _recoverSigner(bytes32 message, bytes sig) internal pure returns (address)
```

### _prefixed

```solidity
function _prefixed(bytes32 hash) internal pure returns (bytes32)
```

