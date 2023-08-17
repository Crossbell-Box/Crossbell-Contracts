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
        _setLinkModule4Note(
            characterId,
            noteId,
            vars.linkModule,
            vars.linkModuleInitData,
            _noteByIdByCharacter
        );

        // init mint module
        _setMintModule4Note(
            characterId,
            noteId,
            vars.mintModule,
            vars.mintModuleInitData,
            _noteByIdByCharacter
        );

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

    /**
     * @notice  Sets link module for a given note.
     * @param   characterId  The character ID to set link module for.
     * @param   noteId  The note ID to set link module for.
     * @param   linkModule  The link module to set.
     * @param   linkModuleInitData  The data to pass to the link module for initialization, if any.
     */
    function setLinkModule4Note(
        uint256 characterId,
        uint256 noteId,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) external {
        _setLinkModule4Note(
            characterId,
            noteId,
            linkModule,
            linkModuleInitData,
            _noteByIdByCharacter
        );
    }

    /**
     * @notice  Sets the mint module for a given note.
     * @param   characterId  The character ID of note to set the mint module for.
     * @param   noteId  The note ID of note.
     * @param   mintModule  The mint module to set for note.
     * @param   mintModuleInitData  The data to pass to the mint module.
     */
    function setMintModule4Note(
        uint256 characterId,
        uint256 noteId,
        address mintModule,
        bytes calldata mintModuleInitData,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) external {
        _setMintModule4Note(
            characterId,
            noteId,
            mintModule,
            mintModuleInitData,
            _noteByIdByCharacter
        );
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

    function _setLinkModule4Note(
        uint256 characterId,
        uint256 noteId,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) internal {
        if (linkModule != address(0)) {
            _noteByIdByCharacter[characterId][noteId].linkModule = linkModule;

            bytes memory returnData = ILinkModule4Note(linkModule).initializeLinkModule(
                characterId,
                noteId,
                linkModuleInitData
            );

            emit Events.SetLinkModule4Note(
                characterId,
                noteId,
                linkModule,
                linkModuleInitData,
                returnData
            );
        }
    }

    function _setMintModule4Note(
        uint256 characterId,
        uint256 noteId,
        address mintModule,
        bytes calldata mintModuleInitData,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) internal {
        if (mintModule != address(0)) {
            _noteByIdByCharacter[characterId][noteId].mintModule = mintModule;

            bytes memory returnData = IMintModule4Note(mintModule).initializeMintModule(
                characterId,
                noteId,
                mintModuleInitData
            );

            emit Events.SetMintModule4Note(
                characterId,
                noteId,
                mintModule,
                mintModuleInitData,
                returnData
            );
        }
    }
}
