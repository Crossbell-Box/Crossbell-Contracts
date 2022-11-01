// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Web3EntryBase.sol";

contract Web3EntryV1 is Web3EntryBase {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => EnumerableSet.AddressSet) internal _operatorListByCharacter;

    function addOperator(uint256 characterId, address operator) external {
        _validateCallerIsCharacterOwner(characterId);
        _addOperator(characterId, operator);
    }

    function removeOperator(uint256 characterId, address operator) external {
        _validateCallerIsCharacterOwner(characterId);
        _removeOperator(characterId, operator);
    }

    function _validateCallerIsCharacterOwnerOrOperator(uint256 characterId)
        internal
        view
        virtual
        override
    {
        address owner = ownerOf(characterId);

        require(
            _operatorListByCharacter[characterId].contains(msg.sender) ||
                msg.sender == owner ||
                msg.sender == _operatorByCharacter[characterId] ||
                (tx.origin == owner && msg.sender == periphery),
            "NotCharacterOwnerNorOperator"
        );
    }

    function _addOperator(uint256 characterId, address operator) internal {
        _operatorListByCharacter[characterId].add(operator);
        emit Events.AddOperator(characterId, operator, block.timestamp);
    }

    function _removeOperator(uint256 characterId, address operator) internal {
        _operatorListByCharacter[characterId].remove(operator);
        _operatorByCharacter[characterId] = address(0x0);
        emit Events.RemoveOperator(characterId, operator, block.timestamp);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        address[] memory _list = _operatorListByCharacter[tokenId].values();

        for (uint256 index = 0; index < _list.length; index++) {
            address _value = _list[index];
            _operatorListByCharacter[tokenId].remove(_value);
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }
}
