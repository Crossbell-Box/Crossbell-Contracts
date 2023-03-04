# Solidity API

## MiraToken

### BLOCK_ROLE

```solidity
bytes32 BLOCK_ROLE
```

### constructor

```solidity
constructor(string name_, string symbol_, address admin) public
```

### mint

```solidity
function mint(address to, uint256 amount) external
```

_Creates `amount` new tokens for `to`.
Requirements:
- the caller must have the `DEFAULT_ADMIN_ROLE`._

### renounceRole

```solidity
function renounceRole(bytes32 role, address account) public
```

_Revokes `role` from the calling account.
Requirements:
- the caller must have the `DEFAULT_ADMIN_ROLE`._

### _send

```solidity
function _send(address from, address to, uint256 amount, bytes userData, bytes operatorData, bool requireReceptionAck) internal
```

_Blocks send tokens from account `from` who has the `BLOCK_ROLE`._

### _burn

```solidity
function _burn(address, uint256, bytes, bytes) internal pure
```

_Disables burn_

