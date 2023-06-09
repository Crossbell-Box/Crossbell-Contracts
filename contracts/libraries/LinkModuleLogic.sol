// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.18;

import {Events} from "./Events.sol";
import {DataTypes} from "./DataTypes.sol";
import {IMintModule4Note} from "../interfaces/IMintModule4Note.sol";
import {ILinkModule4Note} from "../interfaces/ILinkModule4Note.sol";
import {ILinkModule4ERC721} from "../interfaces/ILinkModule4ERC721.sol";
import {ILinkModule4Linklist} from "../interfaces/ILinkModule4Linklist.sol";
import {ILinkModule4Address} from "../interfaces/ILinkModule4Address.sol";

library LinkModuleLogic {
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

    /**
     * @notice  Sets link module for a given address.
     * @param   account  The address to set link module for.
     * @param   linkModule  The link module to set.
     * @param   linkModuleInitData  The data to pass to the link module for initialization, if any.
     */
    function setLinkModule4Address(
        address account,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(address => address) storage _linkModules4Address
    ) external {
        if (linkModule != address(0)) {
            _linkModules4Address[account] = linkModule;
            bytes memory returnData = ILinkModule4Address(linkModule).initializeLinkModule(
                account,
                linkModuleInitData
            );

            emit Events.SetLinkModule4Address(account, linkModule, linkModuleInitData, returnData);
        }
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

    /**
     * @notice  Sets link module for a given linklist.
     * @param   linklistId  The linklist ID to set link module for.
     * @param   linkModule  The link module to set.
     * @param   linkModuleInitData  The data to pass to the link module for initialization, if any.
     */
    function setLinkModule4Linklist(
        uint256 linklistId,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(uint256 => address) storage _linkModules4Linklist
    ) external {
        if (linkModule != address(0)) {
            _linkModules4Linklist[linklistId] = linkModule;
            bytes memory linkModuleReturnData = ILinkModule4Linklist(linkModule)
                .initializeLinkModule(linklistId, linkModuleInitData);

            emit Events.SetLinkModule4Linklist(
                linklistId,
                linkModule,
                linkModuleInitData,
                linkModuleReturnData
            );
        }
    }

    /**
     * @notice  Sets link module for a given ERC721 token.
     * @param   tokenAddress  The token address of erc721 to set link module for.
     * @param   tokenId  The token ID of erc721 to set link module for.
     * @param   linkModule  The link module to set.
     * @param   linkModuleInitData  The data to pass to the link module for initialization, if any.
     */
    function setLinkModule4ERC721(
        address tokenAddress,
        uint256 tokenId,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(address => mapping(uint256 => address)) storage _linkModules4ERC721
    ) external {
        if (linkModule != address(0)) {
            _linkModules4ERC721[tokenAddress][tokenId] = linkModule;
            bytes memory linkModuleReturnData = ILinkModule4ERC721(linkModule).initializeLinkModule(
                tokenAddress,
                tokenId,
                linkModuleInitData
            );

            emit Events.SetLinkModule4ERC721(
                tokenAddress,
                tokenId,
                linkModule,
                linkModuleInitData,
                linkModuleReturnData
            );
        }
    }
}
