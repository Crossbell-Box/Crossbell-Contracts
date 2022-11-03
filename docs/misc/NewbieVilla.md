# Solidity API

## NewbieVilla

_Implementation of a contract to keep characters for others. The address with
the ADMIN_ROLE are expected to issue the proof to users. Then users could use the
proof to withdraw the corresponding character._

### ADMIN_ROLE

```solidity
bytes32 ADMIN_ROLE
```

### web3Entry

```solidity
address web3Entry
```

### xsyncOperator

```solidity
address xsyncOperator
```

### _notExpired

```solidity
modifier _notExpired(uint256 expires)
```

### initialize

```solidity
function initialize(address _web3Entry, address _xsyncOperator) external
```

Initialize the Newbie Villa contract.

_msg.sender will be granted both DEFAULT_ADMIN_ROLE and ADMIN_ROLE._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _web3Entry | address | Address of Web3Entry. |
| _xsyncOperator | address | Address of xsyncOperator. |

### splitSignature

```solidity
function splitSignature(bytes sig) internal pure returns (uint8 v, bytes32 r, bytes32 s)
```

### recoverSigner

```solidity
function recoverSigner(bytes32 message, bytes sig) internal pure returns (address)
```

### prefixed

```solidity
function prefixed(bytes32 hash) internal pure returns (bytes32)
```

### withdraw

```solidity
function withdraw(address to, uint256 characterId, uint256 nonce, uint256 expires, bytes proof) external
```

Withdraw character#`characterId` to `to` using the nonce, expires and the proof.

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

