// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.18;

import {ILinkModule4Note} from "../interfaces/ILinkModule4Note.sol";
import {IMintModule4Note} from "../interfaces/IMintModule4Note.sol";
import {IMintNFT} from "../interfaces/IMintNFT.sol";
import {StorageLib} from "./StorageLib.sol";
import {ValidationLib} from "./ValidationLib.sol";
import {DataTypes} from "./DataTypes.sol";
import {Events} from "./Events.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library PostLib {
    using Strings for uint256;

    function postNoteWithLink(
        DataTypes.PostNoteData calldata vars,
        uint256 noteId,
        bytes32 linkItemType,
        bytes32 linkKey,
        bytes calldata data
    ) external {
        DataTypes.Note storage _note = StorageLib.getNote(vars.characterId, noteId);

        // save note
        _note.contentUri = vars.contentUri;
        if (linkItemType != bytes32(0)) {
            _note.linkItemType = linkItemType;
            _note.linkKey = linkKey;
        }

        // init link module
        _setLinkModule4Note(
            vars.characterId,
            noteId,
            vars.linkModule,
            vars.linkModuleInitData,
            _note
        );

        // init mint module
        _setMintModule4Note(
            vars.characterId,
            noteId,
            vars.mintModule,
            vars.mintModuleInitData,
            _note
        );

        emit Events.PostNote(vars.characterId, noteId, linkKey, linkItemType, data);
    }

    function mintNote(
        uint256 characterId,
        uint256 noteId,
        address to,
        bytes calldata mintModuleData,
        address mintNFTImpl
    ) external returns (uint256 tokenId) {
        DataTypes.Note storage _note = StorageLib.getNote(characterId, noteId);
        address mintNFT = _note.mintNFT;
        if (mintNFT == address(0)) {
            mintNFT = _deployMintNFT(characterId, noteId, mintNFTImpl);
            _note.mintNFT = mintNFT;
        }

        // mint nft
        tokenId = IMintNFT(mintNFT).mint(to);

        address mintModule = _note.mintModule;
        if (mintModule != address(0)) {
            IMintModule4Note(mintModule).processMint(to, characterId, noteId, mintModuleData);
        }

        emit Events.MintNote(to, characterId, noteId, mintNFT, tokenId);
    }

    function setNoteUri(uint256 characterId, uint256 noteId, string calldata newUri) external {
        DataTypes.Note storage _note = StorageLib.getNote(characterId, noteId);
        _note.contentUri = newUri;

        emit Events.SetNoteUri(characterId, noteId, newUri);
    }

    function lockNote(uint256 characterId, uint256 noteId) external {
        ValidationLib.validateNoteExists(characterId, noteId);

        StorageLib.getNote(characterId, noteId).locked = true;

        emit Events.LockNote(characterId, noteId);
    }

    function deleteNote(uint256 characterId, uint256 noteId) external {
        ValidationLib.validateNoteExists(characterId, noteId);

        StorageLib.getNote(characterId, noteId).deleted = true;

        emit Events.DeleteNote(characterId, noteId);
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
        bytes calldata linkModuleInitData
    ) external {
        ValidationLib.validateNoteExists(characterId, noteId);
        ValidationLib.validateNoteNotLocked(characterId, noteId);

        _setLinkModule4Note(
            characterId,
            noteId,
            linkModule,
            linkModuleInitData,
            StorageLib.getNote(characterId, noteId)
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
        bytes calldata mintModuleInitData
    ) external {
        _setMintModule4Note(
            characterId,
            noteId,
            mintModule,
            mintModuleInitData,
            StorageLib.getNote(characterId, noteId)
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
        DataTypes.Note storage _note
    ) internal {
        if (linkModule != address(0)) {
            _note.linkModule = linkModule;

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
        DataTypes.Note storage _note
    ) internal {
        if (mintModule != address(0)) {
            _note.mintModule = mintModule;

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
