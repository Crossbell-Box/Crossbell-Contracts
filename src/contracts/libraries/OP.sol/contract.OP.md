# OP
[Git Source](https://github.com/Crossbell-Box/Crossbell-Contracts/blob/4ba4e225416bca003567c0e6ae31b9c6258df17e/contracts/libraries/OP.sol)

*every uint8 stands for a single method in Web3Entry.sol.
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
|255------236|235------176|175-------21|20-------0|*


## State Variables
### UINT256_MAX

```solidity
uint256 internal constant UINT256_MAX = ~uint256(0);
```


### SET_HANDLE

```solidity
uint8 internal constant SET_HANDLE = 0;
```


### SET_SOCIAL_TOKEN

```solidity
uint8 internal constant SET_SOCIAL_TOKEN = 1;
```


### GRANT_OPERATOR_PERMISSIONS

```solidity
uint8 internal constant GRANT_OPERATOR_PERMISSIONS = 2;
```


### GRANT_OPERATORS_FOR_NOTE

```solidity
uint8 internal constant GRANT_OPERATORS_FOR_NOTE = 3;
```


### OWNER_PERMISSION_BITMAP

```solidity
uint256 internal constant OWNER_PERMISSION_BITMAP = ~(UINT256_MAX << 4);
```


### SET_CHARACTER_URI

```solidity
uint8 internal constant SET_CHARACTER_URI = 176;
```


### SET_LINKLIST_URI

```solidity
uint8 internal constant SET_LINKLIST_URI = 177;
```


### LINK_CHARACTER

```solidity
uint8 internal constant LINK_CHARACTER = 178;
```


### UNLINK_CHARACTER

```solidity
uint8 internal constant UNLINK_CHARACTER = 179;
```


### CREATE_THEN_LINK_CHARACTER

```solidity
uint8 internal constant CREATE_THEN_LINK_CHARACTER = 180;
```


### LINK_NOTE

```solidity
uint8 internal constant LINK_NOTE = 181;
```


### UNLINK_NOTE

```solidity
uint8 internal constant UNLINK_NOTE = 182;
```


### LINK_ERC721

```solidity
uint8 internal constant LINK_ERC721 = 183;
```


### UNLINK_ERC721

```solidity
uint8 internal constant UNLINK_ERC721 = 184;
```


### LINK_ADDRESS

```solidity
uint8 internal constant LINK_ADDRESS = 185;
```


### UNLINK_ADDRESS

```solidity
uint8 internal constant UNLINK_ADDRESS = 186;
```


### LINK_ANYURI

```solidity
uint8 internal constant LINK_ANYURI = 187;
```


### UNLINK_ANYURI

```solidity
uint8 internal constant UNLINK_ANYURI = 188;
```


### LINK_LINKLIST

```solidity
uint8 internal constant LINK_LINKLIST = 189;
```


### UNLINK_LINKLIST

```solidity
uint8 internal constant UNLINK_LINKLIST = 190;
```


### SET_LINK_MODULE_FOR_CHARACTER

```solidity
uint8 internal constant SET_LINK_MODULE_FOR_CHARACTER = 191;
```


### SET_LINK_MODULE_FOR_NOTE

```solidity
uint8 internal constant SET_LINK_MODULE_FOR_NOTE = 192;
```


### SET_LINK_MODULE_FOR_LINKLIST

```solidity
uint8 internal constant SET_LINK_MODULE_FOR_LINKLIST = 193;
```


### SET_MINT_MODULE_FOR_NOTE

```solidity
uint8 internal constant SET_MINT_MODULE_FOR_NOTE = 194;
```


### SET_NOTE_URI

```solidity
uint8 internal constant SET_NOTE_URI = 195;
```


### LOCK_NOTE

```solidity
uint8 internal constant LOCK_NOTE = 196;
```


### DELETE_NOTE

```solidity
uint8 internal constant DELETE_NOTE = 197;
```


### POST_NOTE_FOR_CHARACTER

```solidity
uint8 internal constant POST_NOTE_FOR_CHARACTER = 198;
```


### POST_NOTE_FOR_ADDRESS

```solidity
uint8 internal constant POST_NOTE_FOR_ADDRESS = 199;
```


### POST_NOTE_FOR_LINKLIST

```solidity
uint8 internal constant POST_NOTE_FOR_LINKLIST = 200;
```


### POST_NOTE_FOR_NOTE

```solidity
uint8 internal constant POST_NOTE_FOR_NOTE = 201;
```


### POST_NOTE_FOR_ERC721

```solidity
uint8 internal constant POST_NOTE_FOR_ERC721 = 202;
```


### POST_NOTE_FOR_ANYURI

```solidity
uint8 internal constant POST_NOTE_FOR_ANYURI = 203;
```


### POST_NOTE

```solidity
uint8 internal constant POST_NOTE = 236;
```


### POST_NOTE_PERMISSION_BITMAP

```solidity
uint256 internal constant POST_NOTE_PERMISSION_BITMAP = 1 << POST_NOTE;
```


### POST_NOTE_DEFAULT_PERMISSION_BITMAP

```solidity
uint256 internal constant POST_NOTE_DEFAULT_PERMISSION_BITMAP =
    ((UINT256_MAX << 198) & ~(UINT256_MAX << 204)) | POST_NOTE_PERMISSION_BITMAP;
```


### DEFAULT_PERMISSION_BITMAP

```solidity
uint256 internal constant DEFAULT_PERMISSION_BITMAP =
    ((UINT256_MAX << 176) & ~(UINT256_MAX << 204)) | POST_NOTE_PERMISSION_BITMAP;
```


### ALLOWED_PERMISSION_BITMAP_MASK

```solidity
uint256 internal constant ALLOWED_PERMISSION_BITMAP_MASK = OWNER_PERMISSION_BITMAP | DEFAULT_PERMISSION_BITMAP;
```


