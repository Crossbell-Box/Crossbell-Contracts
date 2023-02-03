// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./base/NFTBase.sol";
import "./interfaces/IMintNFT.sol";
import "./interfaces/IWeb3Entry.sol";
import {ErrCallerNotWeb3Entry} from "./libraries/Error.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract MintNFT is NFTBase, IMintNFT, Initializable {
    using Counters for Counters.Counter;

    // solhint-disable var-name-mixedcase
    address public Web3Entry;

    uint256 internal _characterId;
    uint256 internal _noteId;
    Counters.Counter internal _tokenIdCounter;

    function initialize(
        uint256 characterId,
        uint256 noteId,
        address web3Entry,
        string calldata name_,
        string calldata symbol_
    ) external override initializer {
        super._initialize(name_, symbol_);
        _characterId = characterId;
        _noteId = noteId;
        Web3Entry = web3Entry;

        emit Events.MintNFTInitialized(characterId, noteId, block.timestamp);
    }

    function mint(address to) external override returns (uint256) {
        if (msg.sender != Web3Entry) revert ErrCallerNotWeb3Entry();

        _tokenIdCounter.increment();
        _mint(to, _tokenIdCounter.current());
        return _tokenIdCounter.current();
    }

    function getSourcePublicationPointer() external view override returns (uint256, uint256) {
        return (_characterId, _noteId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory uri) {
        if (_exists(tokenId)) {
            uri = IWeb3Entry(Web3Entry).getNote(_characterId, _noteId).contentUri;
        }
    }
}
