// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Web3EntryBase.sol";
import "./libraries/OP.sol";

contract Web3Entry is Web3EntryBase {
    // characterId => operator => permissionsBitMap
    mapping(uint256 => mapping(address => uint256)) internal operatorsPermissionBitMap;

    function grantOperatorPermissions(
        uint256 characterId,
        address operator,
        uint256 permissionBitMap
    ) external {
        operatorsPermissionBitMap[characterId][operator] = permissionBitMap;
    }

    function checkPermissionAtPosition(
        uint256 characterId,
        address operator,
        uint256 position
    ) external returns (bool) {
        return ((operatorsPermissionBitMap[characterId][operator] >> position) & 1) == 1;
    }

    // migrateOperator migrates operators permissions to operatorsAuthBitMap
    function migrateOperator(uint256[] calldata characterIds) external {
        // set default permissions bitmap
        for (uint256 i = 0; i < characterIds.length; ++i) {
            uint256 characterId = characterIds[i];
            address operator = _operatorByCharacter[characterId];
            if (operator != address(0)) {
                operatorsPermissionBitMap[characterId][operator] = OP.DEFAULT_PERMISSION_BITMAP;
            }

            // address[] memory operators = _operatorsByCharacter[characterId].values();
            // for (uint256 j = 0; j < operators.length; ++j) {
            //     operatorsPermissionBitMap[characterId][operators[j]] = OP.DEFAULT_PERMISSION_BITMAP;
            // }
        }
    }

    function getOperatorPermission(uint256 characterId, address operator)
        external
        view
        returns (uint256)
    {
        return operatorsPermissionBitMap[characterId][operator];
    }

}
