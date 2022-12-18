# Solidity API

## OP

_every uint8 stands for a single method in Web3Entry.sol.
For most cases, we recommend simply granting operators the OPERATOR_SIGN_PERMISSION_BITMAP,
which gives operator full permissions aside from owner permissions and future permissions, but for
those who're more aware of access control, the custom permission bitmap is all yours,
and you can find every customizable methods below.

`OPERATOR_SIGN_PERMISSION_BITMAP` have access to all methods in `OPERATOR_SYNC_PERMISSION_BITMAP`
plus more permissions for signing.

Permissions are laid out in a increasing order of power.
so the bitmap looks like this:

|   opSync   |   opSign   |   future   |  owner   |
|------------|------------|------------|----------|
|255------236|235------176|175-------21|20-------0|_

### UINT256_MAX

```solidity
uint256 UINT256_MAX
```

### SET_HANDLE

```solidity
uint8 SET_HANDLE
```

### SET_SOCIAL_TOKEN

```solidity
uint8 SET_SOCIAL_TOKEN
```

### GRANT_OPERATOR_PERMISSIONS

```solidity
uint8 GRANT_OPERATOR_PERMISSIONS
```

### ADD_OPERATORS_FOR_NOTE

```solidity
uint8 ADD_OPERATORS_FOR_NOTE
```

### REMOVE_OPERATORS_FOR_NOTE

```solidity
uint8 REMOVE_OPERATORS_FOR_NOTE
```

### OWNER_PERMISSION_BITMAP

```solidity
uint256 OWNER_PERMISSION_BITMAP
```

### SET_CHARACTER_URI

```solidity
uint8 SET_CHARACTER_URI
```

### SET_LINKLIST_URI

```solidity
uint8 SET_LINKLIST_URI
```

### LINK_CHARACTER

```solidity
uint8 LINK_CHARACTER
```

### UNLINK_CHARACTER

```solidity
uint8 UNLINK_CHARACTER
```

### CREATE_THEN_LINK_CHARACTER

```solidity
uint8 CREATE_THEN_LINK_CHARACTER
```

### LINK_NOTE

```solidity
uint8 LINK_NOTE
```

### UNLINK_NOTE

```solidity
uint8 UNLINK_NOTE
```

### LINK_ERC721

```solidity
uint8 LINK_ERC721
```

### UNLINK_ERC721

```solidity
uint8 UNLINK_ERC721
```

### LINK_ADDRESS

```solidity
uint8 LINK_ADDRESS
```

### UNLINK_ADDRESS

```solidity
uint8 UNLINK_ADDRESS
```

### LINK_ANYURI

```solidity
uint8 LINK_ANYURI
```

### UNLINK_ANYURI

```solidity
uint8 UNLINK_ANYURI
```

### LINK_LINKLIST

```solidity
uint8 LINK_LINKLIST
```

### UNLINK_LINKLIST

```solidity
uint8 UNLINK_LINKLIST
```

### SET_LINK_MODULE_FOR_CHARACTER

```solidity
uint8 SET_LINK_MODULE_FOR_CHARACTER
```

### SET_LINK_MODULE_FOR_NOTE

```solidity
uint8 SET_LINK_MODULE_FOR_NOTE
```

### SET_LINK_MODULE_FOR_LINKLIST

```solidity
uint8 SET_LINK_MODULE_FOR_LINKLIST
```

### SET_MINT_MODULE_FOR_NOTE

```solidity
uint8 SET_MINT_MODULE_FOR_NOTE
```

### SET_NOTE_URI

```solidity
uint8 SET_NOTE_URI
```

### LOCK_NOTE

```solidity
uint8 LOCK_NOTE
```

### DELETE_NOTE

```solidity
uint8 DELETE_NOTE
```

### POST_NOTE_FOR_CHARACTER

```solidity
uint8 POST_NOTE_FOR_CHARACTER
```

### POST_NOTE_FOR_ADDRESS

```solidity
uint8 POST_NOTE_FOR_ADDRESS
```

### POST_NOTE_FOR_LINKLIST

```solidity
uint8 POST_NOTE_FOR_LINKLIST
```

### POST_NOTE_FOR_NOTE

```solidity
uint8 POST_NOTE_FOR_NOTE
```

### POST_NOTE_FOR_ERC721

```solidity
uint8 POST_NOTE_FOR_ERC721
```

### POST_NOTE_FOR_ANYURI

```solidity
uint8 POST_NOTE_FOR_ANYURI
```

### POST_NOTE

```solidity
uint8 POST_NOTE
```

### POST_NOTE_PERMISSION_BITMAP

```solidity
uint256 POST_NOTE_PERMISSION_BITMAP
```

### DEFAULT_PERMISSION_BITMAP

```solidity
uint256 DEFAULT_PERMISSION_BITMAP
```

### ALLOWED_PERMISSION_BITMAP_MASK

```solidity
uint256 ALLOWED_PERMISSION_BITMAP_MASK
```

