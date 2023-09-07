// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {NFTBase} from "./base/NFTBase.sol";
import {IMintNFT} from "./interfaces/IMintNFT.sol";
import {IWeb3Entry} from "./interfaces/IWeb3Entry.sol";
import {ErrCallerNotWeb3Entry, ErrNotCharacterOwner} from "./libraries/Error.sol";
import {Events} from "./libraries/Events.sol";
import {ERC721Enumerable} from "./base/ERC721Enumerable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract MintNFT is NFTBase, IMintNFT, ERC2981, Initializable {
    uint256 internal _characterId;
    uint256 internal _noteId;
    address internal _web3Entry;
    uint256 internal _tokenCounter;
    mapping(uint256 => address) internal _originalReceiver;

    modifier onlyWeb3Entry() {
        if (msg.sender != _web3Entry) revert ErrCallerNotWeb3Entry();
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != IERC721(_web3Entry).ownerOf(_characterId)) revert ErrNotCharacterOwner();
        _;
    }

    /// @inheritdoc IMintNFT
    function initialize(
        uint256 characterId_,
        uint256 noteId_,
        address web3Entry_,
        string calldata name_,
        string calldata symbol_
    ) external override initializer {
        super._initialize(name_, symbol_);
        _characterId = characterId_;
        _noteId = noteId_;
        _web3Entry = web3Entry_;

        emit Events.MintNFTInitialized(characterId_, noteId_, block.timestamp);
    }

    /// @inheritdoc IMintNFT
    function mint(address to) external override onlyWeb3Entry returns (uint256 tokenId) {
        unchecked {
            tokenId = ++_tokenCounter;
        }
        _originalReceiver[tokenId] = to;
        _mint(to, tokenId);
    }

    /// @inheritdoc IMintNFT
    function setTokenRoyalty(
        uint256 tokenId,
        address recipient,
        uint96 fraction
    ) external override onlyOwner {
        _setTokenRoyalty(tokenId, recipient, fraction);
    }

    /// @inheritdoc IMintNFT
    function setDefaultRoyalty(address recipient, uint96 fraction) external override onlyOwner {
        _setDefaultRoyalty(recipient, fraction);
    }

    /// @inheritdoc IMintNFT
    function deleteDefaultRoyalty() external override onlyOwner {
        _deleteDefaultRoyalty();
    }

    /// @inheritdoc IMintNFT
    function originalReceiver(uint256 tokenId) external view override returns (address) {
        return _originalReceiver[tokenId];
    }

    /// @inheritdoc IMintNFT
    function getSourceNotePointer()
        external
        view
        override
        returns (uint256 characterId, uint256 noteId)
    {
        return (_characterId, _noteId);
    }

    /// @inheritdoc IERC165
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC2981, ERC721Enumerable) returns (bool) {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IERC721Enumerable
    function totalSupply() public view override returns (uint256) {
        return _tokenCounter;
    }

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 tokenId) public view override returns (string memory uri) {
        if (_exists(tokenId)) {
            uri = IWeb3Entry(_web3Entry).getNote(_characterId, _noteId).contentUri;
        }
    }
}
