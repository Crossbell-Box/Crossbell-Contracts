// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.18;

import {DataTypes} from "./DataTypes.sol";
import {Events} from "./Events.sol";
import {ILinkModule4Note} from "../interfaces/ILinkModule4Note.sol";
import {IMintModule4Note} from "../interfaces/IMintModule4Note.sol";
import {IMintNFT} from "../interfaces/IMintNFT.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

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
        DataTypes.Note storage note = _noteByIdByCharacter[characterId][noteId];

        // save note
        note.contentUri = vars.contentUri;
        if (linkItemType != bytes32(0)) {
            note.linkItemType = linkItemType;
            note.linkKey = linkKey;
        }

        // init link module
        if (vars.linkModule != address(0)) {
            note.linkModule = vars.linkModule;

            bytes memory linkModuleReturnData = ILinkModule4Note(vars.linkModule)
                .initializeLinkModule(characterId, noteId, vars.linkModuleInitData);

            emit Events.SetLinkModule4Note(
                characterId,
                noteId,
                vars.linkModule,
                vars.linkModuleInitData,
                linkModuleReturnData
            );
        }

        // init mint module
        if (vars.mintModule != address(0)) {
            note.mintModule = vars.mintModule;

            bytes memory mintModuleReturnData = IMintModule4Note(vars.mintModule)
                .initializeMintModule(characterId, noteId, vars.mintModuleInitData);

            emit Events.SetMintModule4Note(
                characterId,
                noteId,
                vars.mintModule,
                vars.mintModuleInitData,
                mintModuleReturnData
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
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) external returns (uint256 tokenId) {
        DataTypes.Note storage note = _noteByIdByCharacter[characterId][noteId];
        address mintNFT = note.mintNFT;
        if (mintNFT == address(0)) {
            mintNFT = _deployMintNFT(characterId, noteId, mintNFTImpl);
            note.mintNFT = mintNFT;
        }

        // mint nft
        tokenId = IMintNFT(mintNFT).mint(to);

        address mintModule = note.mintModule;
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
        address mintNFTImpl
    ) internal returns (address mintNFT) {
        string memory symbol = string.concat(
            "Note-",
            characterId.toString(),
            "-",
            noteId.toString()
        );

        // deploy nft contract
        mintNFT = Clones.clone(mintNFTImpl);
        // initialize nft
        IMintNFT(mintNFT).initialize(characterId, noteId, address(this), symbol, symbol);
    }
}
