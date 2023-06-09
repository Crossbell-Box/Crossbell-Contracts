// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {IERC20Mintable} from "../interfaces/IERC20Mintable.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC777} from "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

contract MiraToken is AccessControlEnumerable, IERC20Mintable, ERC777 {
    bytes32 public constant BLOCK_ROLE = keccak256("BLOCK_ROLE");

    constructor(
        string memory name_,
        string memory symbol_,
        address admin
    ) ERC777(name_, symbol_, new address[](0)) {
        // Grants `DEFAULT_ADMIN_ROLE` to the account that deploys the contract
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     * Requirements:
     * - the caller must have the `DEFAULT_ADMIN_ROLE`.
     */
    function mint(address to, uint256 amount) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(to, amount, "", "");
    }

    /**
     * @dev Revokes `role` from the calling account.
     * Requirements:
     * - the caller must have the `DEFAULT_ADMIN_ROLE`.
     */
    function renounceRole(
        bytes32 role,
        address account
    ) public override(AccessControl, IAccessControl) onlyRole(DEFAULT_ADMIN_ROLE) {
        super.renounceRole(role, account);
    }

    /**
     * @dev Blocks send tokens from account `from` who has the `BLOCK_ROLE`.
     */
    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal override {
        require(!hasRole(BLOCK_ROLE, from), "transfer is blocked");
        super._send(from, to, amount, userData, operatorData, requireReceptionAck);
    }

    /**
     * @dev Disables burn
     */
    function _burn(address, uint256, bytes memory, bytes memory) internal pure override {
        revert("burn is not allowed");
    }
}
