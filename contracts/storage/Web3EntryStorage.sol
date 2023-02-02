// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/DataTypes.sol";

contract Web3EntryStorage {
    // characterId => Character
    mapping(uint256 => DataTypes.Character) internal _characterById;
    // handleHash => characterId
    mapping(bytes32 => uint256) internal _characterIdByHandleHash;
    // address => characterId
    mapping(address => uint256) internal _primaryCharacterByAddress;

    // characterId =>  (linkType => linklistId)
    mapping(uint256 => mapping(bytes32 => uint256)) internal _attachedLinklists;

    // characterId => noteId => Note
    mapping(uint256 => mapping(uint256 => DataTypes.Note)) internal _noteByIdByCharacter; // slot 14

    /////////////////////////////////
    // link modules
    /////////////////////////////////

    // tokenId => linkModule4Linklist
    mapping(uint256 => address) internal _linkModules4Linklist;

    // tokenAddress => tokenId => linkModule4ERC721
    mapping(address => mapping(uint256 => address)) internal _linkModules4ERC721;

    // address => linkModule4Address
    mapping(address => address) internal _linkModules4Address;

    uint256 internal _characterCounter;
    // LinkList NFT token contract
    address internal _linklist;
    // solhint-disable-next-line private-vars-leading-underscore, var-name-mixedcase
    address internal MINT_NFT_IMPL;
}
