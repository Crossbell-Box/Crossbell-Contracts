// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/OP.sol";

interface IOperatorPermission {
    function checkPermissionByPermissionID(
        uint256 characterId,
        address operator,
        uint256 permissionId
    ) external returns (bool);
}
