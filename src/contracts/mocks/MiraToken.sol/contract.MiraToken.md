# MiraToken
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/638047aa8a24788643a179bc4e4bad5b13618581/contracts/mocks/MiraToken.sol)

**Inherits:**
Context, AccessControlEnumerable, [IERC20Mintable](/contracts/interfaces/IERC20Mintable.sol/contract.IERC20Mintable.md), ERC777


## State Variables
### BLOCK_ROLE

```solidity
bytes32 public constant BLOCK_ROLE = keccak256("BLOCK_ROLE");
```


## Functions
### constructor


```solidity
constructor(string memory name_, string memory symbol_, address admin) ERC777(name_, symbol_, new address[](0));
```

### mint

*Creates `amount` new tokens for `to`.
Requirements:
- the caller must have the `DEFAULT_ADMIN_ROLE`.*


```solidity
function mint(address to, uint256 amount) external override onlyRole(DEFAULT_ADMIN_ROLE);
```

### renounceRole

*Revokes `role` from the calling account.
Requirements:
- the caller must have the `DEFAULT_ADMIN_ROLE`.*


```solidity
function renounceRole(bytes32 role, address account)
    public
    override(AccessControl, IAccessControl)
    onlyRole(DEFAULT_ADMIN_ROLE);
```

### _send

*Blocks send tokens from account `from` who has the `BLOCK_ROLE`.*


```solidity
function _send(
    address from,
    address to,
    uint256 amount,
    bytes memory userData,
    bytes memory operatorData,
    bool requireReceptionAck
) internal override;
```

### _burn

*Disables burn*


```solidity
function _burn(address, uint256, bytes memory, bytes memory) internal pure override;
```

