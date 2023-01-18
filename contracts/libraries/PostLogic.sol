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
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) external {
        uint256 characterId = vars.characterId;
        // save note
        if (linkItemType != bytes32(0)) {
            _noteByIdByCharacter[characterId][noteId].linkItemType = linkItemType;
            _noteByIdByCharacter[characterId][noteId].linkKey = linkKey;
        }
        _noteByIdByCharacter[characterId][noteId].contentUri = vars.contentUri;
        _noteByIdByCharacter[characterId][noteId].linkModule = vars.linkModule;
        _noteByIdByCharacter[characterId][noteId].mintModule = vars.mintModule;

        // init link module
        if (vars.linkModule != address(0)) {
            bytes memory linkModuleReturnData = ILinkModule4Note(vars.linkModule)
                .initializeLinkModule(characterId, noteId, vars.linkModuleInitData);

            emit Events.SetLinkModule4Note(
                characterId,
                noteId,
                vars.linkModule,
                linkModuleReturnData,
                block.timestamp
            );
        }

        // init mint module
        if (vars.mintModule != address(0)) {
            bytes memory mintModuleReturnData = IMintModule4Note(vars.mintModule)
                .initializeMintModule(characterId, noteId, vars.mintModuleInitData);

            emit Events.SetMintModule4Note(
                characterId,
                noteId,
                vars.mintModule,
                mintModuleReturnData,
                block.timestamp
            );
        }

        emit Events.PostNote(characterId, noteId, linkKey, linkItemType, data);
    }

    function mintNote(
        uint256 characterId,
        uint256 noteId,
        address to,
        bytes calldata mintModuleData,
        address mintNFTImpl,
        mapping(uint256 => DataTypes.Character) storage _characterById,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) external returns (uint256 tokenId) {
        address mintNFT = _noteByIdByCharacter[characterId][noteId].mintNFT;
        if (mintNFT == address(0)) {
            mintNFT = _deployMintNFT(
                characterId,
                noteId,
                _characterById[characterId].handle,
                mintNFTImpl
            );
            _noteByIdByCharacter[characterId][noteId].mintNFT = mintNFT;
        }

        // mint nft
        tokenId = IMintNFT(mintNFT).mint(to);

        address mintModule = _noteByIdByCharacter[characterId][noteId].mintModule;
        if (mintModule != address(0)) {
            IMintModule4Note(mintModule).processMint(to, characterId, noteId, mintModuleData);
        }

        emit Events.MintNote(to, characterId, noteId, mintNFT, tokenId);
    }

    function setNoteUri(
        uint256 characterId,
        uint256 noteId,
        string calldata newUri,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) external {
        _noteByIdByCharacter[characterId][noteId].contentUri = newUri;

        emit Events.SetNoteUri(characterId, noteId, newUri);
    }

    function _deployMintNFT(
        uint256 characterId,
        uint256 noteId,
        string memory handle,
        address mintNFTImpl
    ) internal returns (address) {
        address mintNFT = Clones.clone(mintNFTImpl);

        bytes4 firstBytes = bytes4(bytes(handle));

        string memory NFTName = string(
            abi.encodePacked(handle, "-Note-", characterId.toString(), "-", noteId.toString())
        );
        string memory NFTSymbol = string(
            abi.encodePacked(firstBytes, "-Note-", characterId.toString(), "-", noteId.toString())
        );

        IMintNFT(mintNFT).initialize(characterId, noteId, address(this), NFTName, NFTSymbol);
        return mintNFT;
    }
}
