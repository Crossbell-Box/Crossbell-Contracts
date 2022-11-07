// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Web3EntryBase.sol";

contract Web3Entry is Web3EntryBase {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => EnumerableSet.AddressSet) internal _operatorsByCharacter;

    function addOperator(uint256 characterId, address operator) external override {
        _validateCallerIsCharacterOwner(characterId);
        _addOperator(characterId, operator);
    }

    function removeOperator(uint256 characterId, address operator) external override {
        _validateCallerIsCharacterOwner(characterId);
        _removeOperator(characterId, operator);
    }

    function isOperator(uint256 characterId, address operator)
        external
        view
        override
        returns (bool)
    {
        bool inOperator = _operatorByCharacter[characterId] == operator;
        bool inOpertors = _operatorsByCharacter[characterId].contains(operator);
        return inOperator || inOpertors;
    }

    function getOperators(uint256 characterId) external view override returns (address[] memory) {
        return _operatorsByCharacter[characterId].values();
    }

    function _addOperator(uint256 characterId, address operator) internal {
        _operatorsByCharacter[characterId].add(operator);
        emit Events.AddOperator(characterId, operator, block.timestamp);
    }

    function _removeOperator(uint256 characterId, address operator) internal {
        _operatorsByCharacter[characterId].remove(operator);
        emit Events.RemoveOperator(characterId, operator, block.timestamp);
    }

    function _validateCallerIsCharacterOwnerOrOperator(uint256 characterId)
        internal
        view
        virtual
        override
    {
        address owner = ownerOf(characterId);

        require(
            _operatorsByCharacter[characterId].contains(msg.sender) ||
                msg.sender == owner ||
                msg.sender == _operatorByCharacter[characterId] ||
                (tx.origin == owner && msg.sender == periphery),
            "NotCharacterOwnerNorOperator"
        );
    }

    function _validateCallerIsLinklistOwnerOrOperator(uint256 tokenId)
        internal
        view
        virtual
        override
    {
        // get character id of the owner of this linklist
        uint256 ownerCharacterId = ILinklist(_linklist).getOwnerCharacterId(tokenId);
        // require msg.sender is operator of the owner character or the owner of this linklist
        require(
            msg.sender == IERC721(_linklist).ownerOf(tokenId) ||
                _operatorsByCharacter[ownerCharacterId].contains(msg.sender) ||
                msg.sender == _operatorByCharacter[ownerCharacterId],
            "NotLinkListOwnerNorOperator"
        );
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        address[] memory _list = _operatorsByCharacter[tokenId].values();

        for (uint256 index = 0; index < _list.length; index++) {
            address _value = _list[index];
            _removeOperator(tokenId, _value);
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }
}
