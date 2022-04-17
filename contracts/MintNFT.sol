// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./base/NFTBase.sol";
import "./interfaces/IMintNFT.sol";
import "./interfaces/IWeb3Entry.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract MintNFT is NFTBase, IMintNFT, Initializable {
    using Counters for Counters.Counter;

    address public _web3Entry;

    uint256 internal _profileId;
    uint256 internal _noteId;
    Counters.Counter internal _tokenIdCounter;

    function initialize(
        uint256 profileId,
        uint256 noteId,
        address web3Entry,
        string calldata name,
        string calldata symbol
    ) external initializer {
        super._initialize(name, symbol);
        _profileId = profileId;
        _noteId = noteId;
        _web3Entry = web3Entry;

        emit Events.MintNFTInitialized(profileId, noteId, block.timestamp);
    }

    function mint(address to) external returns (uint256) {
        require(msg.sender != _web3Entry, "MintNFT: not Web3Entry");

        _tokenIdCounter.increment();
        _mint(to, _tokenIdCounter.current());
        return _tokenIdCounter.current();
    }

    function getSourcePublicationPointer() external view returns (uint256, uint256) {
        return (_profileId, _noteId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "MintNFT: TokenDoesNotExist");
        return IWeb3Entry(_web3Entry).getNoteUri(_profileId, _noteId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {}
}
