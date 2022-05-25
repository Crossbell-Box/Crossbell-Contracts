// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./DataTypes.sol";
import "./Events.sol";
import "../interfaces/ILinkModule4Note.sol";
import "../interfaces/IMintModule4Note.sol";
import "../interfaces/IMintNFT.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library PostLogic {
    using Strings for uint256;

    function postNoteWithLink(
        DataTypes.PostNoteData calldata vars,
        uint256 noteId,
        bytes32 linkItemType,
        bytes32 linkKey,
        bytes calldata data,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByProfile
    ) external {
        uint256 profileId = vars.profileId;
        // save note
        if (linkItemType != bytes32(0)) {
            _noteByIdByProfile[profileId][noteId].linkItemType = linkItemType;
            _noteByIdByProfile[profileId][noteId].linkKey = linkKey;
        }
        _noteByIdByProfile[profileId][noteId].contentUri = vars.contentUri;
        _noteByIdByProfile[profileId][noteId].linkModule = vars.linkModule;
        _noteByIdByProfile[profileId][noteId].mintModule = vars.mintModule;

        // init link module
        if (vars.linkModule != address(0)) {
            bytes memory linkModuleReturnData = ILinkModule4Note(vars.linkModule)
                .initializeLinkModule(profileId, noteId, vars.linkModuleInitData);

            emit Events.SetLinkModule4Note(
                profileId,
                noteId,
                vars.linkModule,
                linkModuleReturnData,
                block.timestamp
            );
        }

        // init mint module
        if (vars.mintModule != address(0)) {
            bytes memory mintModuleReturnData = IMintModule4Note(vars.mintModule)
                .initializeMintModule(profileId, noteId, vars.mintModuleInitData);

            emit Events.SetMintModule4Note(
                profileId,
                noteId,
                vars.mintModule,
                mintModuleReturnData,
                block.timestamp
            );
        }

        emit Events.PostNote(profileId, noteId, linkItemType, data);
    }

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
    ) internal returns (address) {
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
