// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Web3EntryV1.sol";

contract Web3Entry is Web3EntryV1 {
    mapping(uint256 => mapping(address => bool)) internal _operatorListByCharacter;

    function addOperator(uint256 characterId, address operator) external {
        _validateCallerIsCharacterOwner(characterId);
        _addOperator(characterId, operator);
    }

    function removeOperator(uint256 characterId, address operator) external {
        _validateCallerIsCharacterOwner(characterId);
        _removeOperator(characterId, operator);
    }

    function _addOperator(uint256 characterId, address operator) internal {
        _operatorListByCharacter[characterId][operator] = true;
        emit Events.AddOperator(characterId, operator, block.timestamp);
    }

    function _validateCallerIsCharacterOwnerOrOperator(uint256 characterId)
        internal
        view
        virtual
        override
    {
        address owner = ownerOf(characterId);

        require(
            _operatorListByCharacter[characterId][msg.sender] ||
                msg.sender == owner ||
                msg.sender == _operatorByCharacter[characterId] ||
                (tx.origin == owner && msg.sender == periphery),
            "NotCharacterOwnerNorOperator"
        );
    }

    function _removeOperator(uint256 characterId, address operator) internal {
        _operatorListByCharacter[characterId][operator] = false;
        _operatorByCharacter[characterId] = address(0x0);
        emit Events.RemoveOperator(characterId, operator, block.timestamp);
    }
}
