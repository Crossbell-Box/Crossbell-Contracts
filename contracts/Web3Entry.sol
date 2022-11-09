// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Web3EntryBase.sol";

contract Web3Entry is Web3EntryBase {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => EnumerableSet.AddressSet) internal _operatorsByCharacter; //slot 24

    /**
     * @notice Designate addresses as operators of your character so that it can send transactions on behalf
      of your characters(e.g. post notes or follow someone). This a high risk operation, so take special 
      attention and make sure the addresses you input is familiar to you.
     */
    function addOperator(uint256 characterId, address operator) external override {
        _validateCallerIsCharacterOwner(characterId);
        _addOperator(characterId, operator);
    }

    /**
     * @notice Cancel authorization on operators and remove them from operator list.
     */
    function removeOperator(uint256 characterId, address operator) external override {
        _validateCallerIsCharacterOwner(characterId);
        _removeOperator(characterId, operator);
    }

    /**
     * @notice Check if an address is the operator of a character.
     * @dev `isOperator` is compatible with operators set by old `setOperator`, which is deprected and will
      be disabled in later updates. 
     */
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

    /**
     * @notice Get operator addresses of a character.
     * @dev `getOperators` returns operators in _operatorsByCharacter, but doesn't return 
     _operatorByCharacter, which is deprected and will be disabled in later updates.
     */
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

    /**
     * @dev Operator lists will be reset to blank before the characters are transferred in order to grant the
      whole control power to receivers of character transfers.
     */
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
