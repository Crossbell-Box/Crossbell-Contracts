# Solidity API

## ProxyAdmin

_This is an auxiliary contract meant to be assigned as the admin of a {TransparentUpgradeableProxy}. For an
explanation of why you would want to use this see the documentation for {TransparentUpgradeableProxy}._

### getProxyImplementation

```solidity
function getProxyImplementation(contract TransparentUpgradeableProxy proxy) public view virtual returns (address)
```

_Returns the current implementation of `proxy`.

Requirements:

- This contract must be the admin of `proxy`._

### getProxyAdmin

```solidity
function getProxyAdmin(contract TransparentUpgradeableProxy proxy) public view virtual returns (address)
```

_Returns the current admin of `proxy`.

Requirements:

- This contract must be the admin of `proxy`._

### changeProxyAdmin

```solidity
function changeProxyAdmin(contract TransparentUpgradeableProxy proxy, address newAdmin) public virtual
```

_Changes the admin of `proxy` to `newAdmin`.

Requirements:

- This contract must be the current admin of `proxy`._

### upgrade

```solidity
function upgrade(contract TransparentUpgradeableProxy proxy, address implementation) public virtual
```

_Upgrades `proxy` to `implementation`. See {TransparentUpgradeableProxy-upgradeTo}.

Requirements:

- This contract must be the admin of `proxy`._

### upgradeAndCall

```solidity
function upgradeAndCall(contract TransparentUpgradeableProxy proxy, address implementation, bytes data) public payable virtual
```

_Upgrades `proxy` to `implementation` and calls a function on the new implementation. See
{TransparentUpgradeableProxy-upgradeToAndCall}.

Requirements:

- This contract must be the admin of `proxy`._

