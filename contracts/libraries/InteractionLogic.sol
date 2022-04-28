// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "hardhat/console.sol";
import "../interfaces/IMintNFT.sol";
import "./Events.sol";
import "./DataTypes.sol";
import "../interfaces/IMintModule4Note.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library InteractionLogic {
    using Strings for uint256;

    function mintNote(
        uint256 profileId,
        uint256 noteId,
        address to,
        bytes calldata mintModuleData,
        address mintNFTImpl,
        mapping(uint256 => DataTypes.Profile) storage _profileById,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByProfile
    ) external returns (uint256 tokenId) {
        address mintNFT = _noteByIdByProfile[profileId][noteId].mintNFT;
        if (mintNFT == address(0)) {
            mintNFT = _deployMintNFT(
                profileId,
                noteId,
                _profileById[profileId].handle,
                mintNFTImpl
            );
            _noteByIdByProfile[profileId][noteId].mintNFT = mintNFT;
        }

        // mint nft
        tokenId = IMintNFT(mintNFT).mint(to);

        address mintModule = _noteByIdByProfile[profileId][noteId].mintModule;
        if (mintModule != address(0)) {
            IMintModule4Note(mintModule).processMint(to, profileId, noteId, mintModuleData);
        }

        emit Events.MintNote(to, profileId, noteId, tokenId, mintModuleData, block.timestamp);
    }

    function _deployMintNFT(
        uint256 profileId,
        uint256 noteId,
        string memory handle,
        address mintNFTImpl
    ) private returns (address) {
        address mintNFT = Clones.clone(mintNFTImpl);

        bytes4 firstBytes = bytes4(bytes(handle));

        string memory NFTName = string(
            abi.encodePacked(handle, "-Mint-", profileId.toString(), "-", noteId.toString())
        );
        string memory NFTSymbol = string(
            abi.encodePacked(firstBytes, "-Mint-", profileId.toString(), "-", noteId.toString())
        );

        IMintNFT(mintNFT).initialize(profileId, noteId, address(this), NFTName, NFTSymbol);
        return mintNFT;
    }
}
