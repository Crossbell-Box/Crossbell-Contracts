# Solidity API

## OP

Permissions are laid out in a increasing order of power.
so the bitmap looks like this:

|   opSync   |   opSign   |   future   |  owner   |
|------------|------------|------------|----------|
|255------236|235------176|175-------21|20-------0|
every uint8 stands for a single method in Web3Entry.sol.

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

### SET_CHARACTER_URI

```solidity
uint8 SET_CHARACTER_URI
```

### SET_LINK_LIST_URI

```solidity
uint8 SET_LINK_LIST_URI
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

### LINK_ANY_URI

```solidity
uint8 LINK_ANY_URI
```

### UNLINK_ANY_URI

```solidity
uint8 UNLINK_ANY_URI
```

### LINK_LINK_LIST

```solidity
uint8 LINK_LINK_LIST
```

### UNLINK_LINK_LIST

```solidity
uint8 UNLINK_LINK_LIST
```

### SET_LINK_MODULE_FOR_CHARACTER

```solidity
uint8 SET_LINK_MODULE_FOR_CHARACTER
```

### SET_LINK_MODULE_FOR_NOTE

```solidity
uint8 SET_LINK_MODULE_FOR_NOTE
```

### SET_LINK_MODULE_FOR_LINK_LIST

```solidity
uint8 SET_LINK_MODULE_FOR_LINK_LIST
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

### POST_NOTE_FOR_LINK_LIST

```solidity
uint8 POST_NOTE_FOR_LINK_LIST
```

### POST_NOTE_FOR_NOTE

```solidity
uint8 POST_NOTE_FOR_NOTE
```

### POST_NOTE_FOR_ERC721

```solidity
uint8 POST_NOTE_FOR_ERC721
```

### POST_NOTE_FOR_ANY_URI

```solidity
uint8 POST_NOTE_FOR_ANY_URI
```

### OPERATOR_SIGN_PERMISSION_BITMAP

```solidity
uint256 OPERATOR_SIGN_PERMISSION_BITMAP
```

### POST_NOTE

```solidity
uint8 POST_NOTE
```

### OPERATOR_SYNC_PERMISSION_BITMAP

```solidity
uint256 OPERATOR_SYNC_PERMISSION_BITMAP
```

### NOTE_SET_LINK_MODULE_FOR_NOTE

```solidity
uint8 NOTE_SET_LINK_MODULE_FOR_NOTE
```

### NOTE_SET_MINT_MODULE_FOR_NOTE

```solidity
uint8 NOTE_SET_MINT_MODULE_FOR_NOTE
```

### NOTE_SET_NOTE_URI

```solidity
uint8 NOTE_SET_NOTE_URI
```

### NOTE_LOCK_NOTE

```solidity
uint8 NOTE_LOCK_NOTE
```

### NOTE_DELETE_NOTE

```solidity
uint8 NOTE_DELETE_NOTE
```

