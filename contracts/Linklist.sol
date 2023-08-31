// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ILinklist} from "./interfaces/ILinklist.sol";
import {LinklistBase} from "./base/LinklistBase.sol";
import {Events} from "./libraries/Events.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {
    ErrCallerNotWeb3Entry,
    ErrCallerNotWeb3EntryOrNotOwner,
    ErrTokenNotExists
} from "./libraries/Error.sol";
import {LinklistStorage} from "./storage/LinklistStorage.sol";
import {LinklistExtendStorage} from "./storage/LinklistExtendStorage.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Linklist is
    ILinklist,
    LinklistBase,
    LinklistStorage,
    Initializable,
    LinklistExtendStorage
{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    event Transfer(address indexed from, uint256 indexed characterId, uint256 indexed tokenId);
    event Burn(uint256 indexed from, uint256 indexed tokenId);
    event UriSet(uint256 indexed tokenId, string uri);
    event LinkTypeSet(uint256 indexed tokenId, bytes32 indexed newlinkType);

    modifier onlyWeb3Entry() {
        if (msg.sender != Web3Entry) revert ErrCallerNotWeb3Entry();
        _;
    }

    modifier onlyExistingToken(uint256 tokenId) {
        if (0 == _linklistOwners[tokenId]) revert ErrTokenNotExists();
        _;
    }

    /// @inheritdoc ILinklist
    function initialize(
        string calldata name_,
        string calldata symbol_,
        address web3Entry_
    ) external override reinitializer(2) {
        Web3Entry = web3Entry_;

        // initialize totalSupply for upgrade
        _totalSupply = _tokenCount;

        super._initialize(name_, symbol_);
        emit Events.LinklistNFTInitialized(block.timestamp);
    }

    /// @inheritdoc ILinklist
    function mint(
        uint256 characterId,
        bytes32 linkType
    ) external override onlyWeb3Entry returns (uint256 tokenId) {
        tokenId = ++_tokenCount;
        _linkTypes[tokenId] = linkType;
        // mint tokenId to characterId
        _linklistOwners[tokenId] = characterId;
        _linklistBalances[characterId]++;
        // update totalSupply
        _totalSupply++;

        emit Transfer(address(0), characterId, tokenId);
    }

    /// @inheritdoc ILinklist
    function burn(uint256 tokenId) external override onlyWeb3Entry {
        uint256 characterId = _linklistOwners[tokenId];
        if (characterId == 0) revert ErrTokenNotExists();

        // Ownership check above ensures no underflow.
        unchecked {
            _linklistBalances[characterId]--;
            _totalSupply--;
        }
        delete _linkTypes[tokenId];
        delete _linklistOwners[tokenId];

        emit Burn(characterId, tokenId);
    }

    /// @inheritdoc ILinklist
    function setUri(
        uint256 tokenId,
        string memory uri
    ) external override onlyExistingToken(tokenId) {
        // caller must be web3Entry or owner
        if (msg.sender != Web3Entry && msg.sender != _ownerOf(tokenId))
            revert ErrCallerNotWeb3EntryOrNotOwner();

        _uris[tokenId] = uri;

        emit UriSet(tokenId, uri);
    }

    /// @inheritdoc ILinklist
    function setLinkType(
        uint256 tokenId,
        bytes32 linkType
    ) external override onlyWeb3Entry onlyExistingToken(tokenId) {
        _linkTypes[tokenId] = linkType;

        emit LinkTypeSet(tokenId, linkType);
    }

    /////////////////////////////////
    // linking Character
    /////////////////////////////////
    /// @inheritdoc ILinklist
    function addLinkingCharacterId(
        uint256 tokenId,
        uint256 toCharacterId
    ) external override onlyWeb3Entry {
        _linkingCharacters[tokenId].add(toCharacterId);
    }

    /// @inheritdoc ILinklist
    function removeLinkingCharacterId(
        uint256 tokenId,
        uint256 toCharacterId
    ) external override onlyWeb3Entry {
        _linkingCharacters[tokenId].remove(toCharacterId);
    }

    /////////////////////////////////
    // linking Note
    /////////////////////////////////
    /// @inheritdoc ILinklist
    function addLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId
    ) external override onlyWeb3Entry returns (bytes32) {
        bytes32 linkKey = keccak256(abi.encodePacked("Note", toCharacterId, toNoteId));
        if (tokenId != 0) {
            _linkNoteKeys[tokenId].add(linkKey);
        }
        _linkNotes[linkKey] = DataTypes.NoteStruct({characterId: toCharacterId, noteId: toNoteId});

        return linkKey;
    }

    /// @inheritdoc ILinklist
    function removeLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId
    ) external override onlyWeb3Entry {
        bytes32 linkKey = keccak256(abi.encodePacked("Note", toCharacterId, toNoteId));
        _linkNoteKeys[tokenId].remove(linkKey);

        // do note delete
        // delete linkNoteList[linkKey];
    }

    /////////////////////////////////
    // linking ERC721
    /////////////////////////////////
    /// @inheritdoc ILinklist
    function addLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external override onlyWeb3Entry returns (bytes32) {
        bytes32 linkKey = keccak256(abi.encodePacked("ERC721", tokenAddress, erc721TokenId));
        if (tokenId != 0) {
            _linkingERC721Keys[tokenId].add(linkKey);
        }
        _linkingERC721s[linkKey] = DataTypes.ERC721Struct({
            tokenAddress: tokenAddress,
            erc721TokenId: erc721TokenId
        });

        return linkKey;
    }

    /// @inheritdoc ILinklist
    function removeLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external override onlyWeb3Entry {
        bytes32 linkKey = keccak256(abi.encodePacked("ERC721", tokenAddress, erc721TokenId));
        _linkingERC721Keys[tokenId].remove(linkKey);

        // do not delete, maybe others link the same token
        // delete linkingERC721List[linkKey];
    }

    /////////////////////////////////
    // linking Address
    /////////////////////////////////
    /// @inheritdoc ILinklist
    function addLinkingAddress(
        uint256 tokenId,
        address ethAddress
    ) external override onlyWeb3Entry {
        _linkingAddresses[tokenId].add(ethAddress);
    }

    /// @inheritdoc ILinklist
    function removeLinkingAddress(
        uint256 tokenId,
        address ethAddress
    ) external override onlyWeb3Entry {
        _linkingAddresses[tokenId].remove(ethAddress);
    }

    /////////////////////////////////
    // linking Any Uri
    /////////////////////////////////
    /// @inheritdoc ILinklist
    function addLinkingAnyUri(
        uint256 tokenId,
        string memory toUri
    ) external override onlyWeb3Entry returns (bytes32) {
        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", toUri));
        if (tokenId != 0) {
            _linkingAnyKeys[tokenId].add(linkKey);
        }
        _linkingAnys[linkKey] = toUri;
        return linkKey;
    }

    /// @inheritdoc ILinklist
    function removeLinkingAnyUri(
        uint256 tokenId,
        string memory toUri
    ) external override onlyWeb3Entry {
        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", toUri));
        _linkingAnyKeys[tokenId].remove(linkKey);

        // do note delete
        // delete linkingAnylist[linkKey];
    }

    /////////////////////////////////
    // linking Linklist
    /////////////////////////////////
    /// @inheritdoc ILinklist
    function addLinkingLinklistId(
        uint256 tokenId,
        uint256 linklistId
    ) external override onlyWeb3Entry {
        _linkingLinklists[tokenId].add(linklistId);
    }

    /// @inheritdoc ILinklist
    function removeLinkingLinklistId(
        uint256 tokenId,
        uint256 linklistId
    ) external override onlyWeb3Entry {
        _linkingLinklists[tokenId].remove(linklistId);
    }

    /// @inheritdoc ILinklist
    function getLinkingCharacterIds(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (uint256[] memory) {
        return _linkingCharacters[tokenId].values();
    }

    /// @inheritdoc ILinklist
    function getLinkingCharacterListLength(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (uint256) {
        return _linkingCharacters[tokenId].length();
    }

    /// @inheritdoc ILinklist
    function getOwnerCharacterId(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (uint256) {
        uint256 characterId = _linklistOwners[tokenId];
        return characterId;
    }

    /// @inheritdoc ILinklist
    function getLinkingNotes(
        uint256 tokenId
    )
        external
        view
        override
        onlyExistingToken(tokenId)
        returns (DataTypes.NoteStruct[] memory results)
    {
        bytes32[] memory linkKeys = _linkNoteKeys[tokenId].values();
        results = new DataTypes.NoteStruct[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = _linkNotes[key];
        }
    }

    /// @inheritdoc ILinklist
    function getLinkingNote(
        bytes32 linkKey
    ) external view override returns (DataTypes.NoteStruct memory) {
        return _linkNotes[linkKey];
    }

    /// @inheritdoc ILinklist
    function getLinkingNoteListLength(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (uint256) {
        return _linkNoteKeys[tokenId].length();
    }

    /// @inheritdoc ILinklist
    function getLinkingERC721s(
        uint256 tokenId
    )
        external
        view
        override
        onlyExistingToken(tokenId)
        returns (DataTypes.ERC721Struct[] memory results)
    {
        bytes32[] memory linkKeys = _linkingERC721Keys[tokenId].values();
        results = new DataTypes.ERC721Struct[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = _linkingERC721s[key];
        }
    }

    /// @inheritdoc ILinklist
    function getLinkingERC721(
        bytes32 linkKey
    ) external view override returns (DataTypes.ERC721Struct memory) {
        return _linkingERC721s[linkKey];
    }

    /// @inheritdoc ILinklist
    function getLinkingERC721ListLength(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (uint256) {
        return _linkingERC721Keys[tokenId].length();
    }

    /// @inheritdoc ILinklist
    function getLinkingAddresses(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (address[] memory) {
        return _linkingAddresses[tokenId].values();
    }

    /// @inheritdoc ILinklist
    function getLinkingAddressListLength(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (uint256) {
        return _linkingAddresses[tokenId].length();
    }

    /// @inheritdoc ILinklist
    function getLinkingAnyUris(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (string[] memory results) {
        bytes32[] memory linkKeys = _linkingAnyKeys[tokenId].values();
        results = new string[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = _linkingAnys[key];
        }
    }

    /// @inheritdoc ILinklist
    function getLinkingAnyUri(bytes32 linkKey) external view override returns (string memory) {
        return _linkingAnys[linkKey];
    }

    /// @inheritdoc ILinklist
    function getLinkingAnyUriKeys(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (bytes32[] memory) {
        return _linkingAnyKeys[tokenId].values();
    }

    /// @inheritdoc ILinklist
    function getLinkingAnyListLength(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (uint256) {
        return _linkingAnyKeys[tokenId].length();
    }

    /// @inheritdoc ILinklist
    function getLinkingLinklistIds(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (uint256[] memory) {
        return _linkingLinklists[tokenId].values();
    }

    /// @inheritdoc ILinklist
    function getLinkingLinklistLength(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (uint256) {
        return _linkingLinklists[tokenId].length();
    }

    /////////////////////////////////
    // common
    /////////////////////////////////
    // solhint-disable-next-line no-empty-blocks
    function getCurrentTakeOver(uint256 tokenId) external view override returns (uint256) {}

    /// @inheritdoc ILinklist
    function getLinkType(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (bytes32) {
        return _linkTypes[tokenId];
    }

    /// @inheritdoc ILinklist
    // solhint-disable func-name-mixedcase
    // slither-disable-next-line naming-convention
    function Uri(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (string memory) {
        return _uris[tokenId];
    }

    /// @inheritdoc ILinklist
    function characterOwnerOf(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (uint256) {
        return _linklistOwners[tokenId];
    }

    /// @inheritdoc ILinklist
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /// @inheritdoc ILinklist
    function balanceOf(uint256 characterId) external view override returns (uint256) {
        return _linklistBalances[characterId];
    }

    /// @inheritdoc ILinklist
    function balanceOf(address account) external view override returns (uint256 balance) {
        uint256 characterCount = IERC721(Web3Entry).balanceOf(account);
        for (uint256 i = 0; i < characterCount; i++) {
            uint256 characterId = IERC721Enumerable(Web3Entry).tokenOfOwnerByIndex(account, i);
            balance += _linklistBalances[characterId];
        }
    }

    /// @inheritdoc ILinklist
    function ownerOf(
        uint256 tokenId
    ) external view override onlyExistingToken(tokenId) returns (address) {
        return _ownerOf(tokenId);
    }

    function _ownerOf(uint256 tokenId) internal view returns (address) {
        uint256 characterId = _linklistOwners[tokenId];
        return IERC721(Web3Entry).ownerOf(characterId);
    }
}
