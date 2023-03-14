// SPDX-License-Identifier: MIT
// slither-disable-start naming-convention
pragma solidity 0.8.16;

import {NFTBase} from "./base/NFTBase.sol";
import {IMintNFT} from "./interfaces/IMintNFT.sol";
import {IWeb3Entry} from "./interfaces/IWeb3Entry.sol";
import {ErrCallerNotWeb3Entry} from "./libraries/Error.sol";
import {Events} from "./libraries/Events.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract MintNFT is NFTBase, IMintNFT, Initializable {
    uint256 internal _characterId;
    uint256 internal _noteId;
    address internal _web3Entry;
    uint256 internal _tokenCounter;
    mapping(uint256 => address) internal _originalReceiver;

    modifier onlyWeb3Entry() {
        if (msg.sender != _web3Entry) revert ErrCallerNotWeb3Entry();
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
        tokenId = ++_tokenCounter;
        _originalReceiver[tokenId] = to;
        _mint(to, tokenId);
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
// slither-disable-end naming-convention
