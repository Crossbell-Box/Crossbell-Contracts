// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.16;

import {DataTypes} from "./DataTypes.sol";
import {Events} from "./Events.sol";
import {ILinkModule4Note} from "../interfaces/ILinkModule4Note.sol";
import {IMintModule4Note} from "../interfaces/IMintModule4Note.sol";
import {IMintNFT} from "../interfaces/IMintNFT.sol";
import {IMintCBT} from "../interfaces/IMintCBT.sol";
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
                linkModuleReturnData,
                block.timestamp
            );
        }

        // init mint module
        if (vars.mintModule != address(0)) {
            note.mintModule = vars.mintModule;
            note.nftType = vars.nftType;

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
        uint256 toCharacterId,
        bytes calldata mintModuleData,
        address[] calldata nftImplAddresses,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) external returns (uint256 tokenId) {
        DataTypes.Note storage note = _noteByIdByCharacter[characterId][noteId]; // todo: pass note directly

        // if this note has no mintNFT address yet, deploy one first
        uint8 nftType = note.nftType;
        address mintNFT;
        if (note.mintNFT == address(0)) {
            mintNFT = _deployMintNFT(characterId, noteId, nftImplAddresses[nftType]);
            note.mintNFT = mintNFT;
        }

        // mint NFT
        address mintModule = note.mintModule;
        if (nftType == 0 || nftType == 1) {
            // this is a normal nft or SBT, so it should be minted to address
            tokenId = IMintNFT(mintNFT).mint(to);
            // process mint to address
            address mintModule = note.mintModule;
            if (mintModule != address(0)) {
                IMintModule4Note(mintModule).processMint(to, 0, characterId, noteId, mintModuleData);
            }
        } else if (nftType == 2) {
            tokenId = IMintCBT(mintNFT).mint(to, toCharacterId);
            // process mint to character
            address mintModule = note.mintModule;
            if (mintModule != address(0)) {
                IMintModule4Note(mintModule).processMint(
                    address(0),
                    toCharacterId,
                    characterId,
                    noteId,
                    mintModuleData
                );
            }
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
