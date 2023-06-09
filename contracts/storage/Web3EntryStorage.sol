// SPDX-License-Identifier: MIT
// slither-disable-start naming-convention
pragma solidity 0.8.18;

import {DataTypes} from "../libraries/DataTypes.sol";

contract Web3EntryStorage {
    // solhint-disable-next-line private-vars-leading-underscore, var-name-mixedcase
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    // solhint-disable-next-line private-vars-leading-underscore, var-name-mixedcase
    bytes32 internal constant GRANT_OPERATOR_PERMISSIONS_WITH_SIG_TYPEHASH =
        keccak256( // solhint-disable-next-line max-line-length
            "grantOperatorPermissions(uint256 characterId,address operator,uint256 permissionBitMap,uint256 nonce,uint256 deadline)"
        );

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
    /// @dev disable `uninitialized-state` check, as linkmodule for erc721 is not enabled currently
    // slither-disable-next-line uninitialized-state
    mapping(address => mapping(uint256 => address)) internal _linkModules4ERC721;

    // address => linkModule4Address
    mapping(address => address) internal _linkModules4Address;

    uint256 internal _characterCounter;
    // LinkList NFT token contract
    address internal _linklist;
    // solhint-disable-next-line private-vars-leading-underscore, var-name-mixedcase
    address internal MINT_NFT_IMPL;
}
// slither-disable-end naming-convention
