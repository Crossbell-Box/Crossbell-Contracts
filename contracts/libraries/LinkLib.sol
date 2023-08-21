// SPDX-License-Identifier: MIT
// solhint-disable  private-vars-leading-underscore
pragma solidity 0.8.18;

import {Events} from "./Events.sol";
import {StorageLib} from "./StorageLib.sol";
import {ILinklist} from "../interfaces/ILinklist.sol";
import {ILinkModule4Character} from "../interfaces/ILinkModule4Character.sol";
import {ILinkModule4Note} from "../interfaces/ILinkModule4Note.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library LinkLib {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /**
     * @notice  Links any characterId.
     * @param   fromCharacterId  The character ID to sponsor a link action.
     * @param   toCharacterId  The character ID to be linked.
     * @param   linkType  linkType, like “follow”.
     * @param   data  The data to pass to the link module, if any.
     * @param   linklist  The linklist contract address.
     * @param   linkModule  The linkModule address of the character to link.
     */
    function linkCharacter(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        bytes32 linkType,
        bytes memory data,
        address linklist,
        address linkModule
    ) external {
        address linker = IERC721(address(this)).ownerOf(fromCharacterId);
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist);

        // add to link list
        ILinklist(linklist).addLinkingCharacterId(linklistId, toCharacterId);

        // process link module
        if (linkModule != address(0)) {
            try
                ILinkModule4Character(linkModule).processLink(linker, toCharacterId, data)
            {} catch {} // solhint-disable-line no-empty-blocks
        }

        emit Events.LinkCharacter(linker, fromCharacterId, toCharacterId, linkType, linklistId);
    }

    /**
     * @notice  Unlinks a given character.
     * @param   fromCharacterId  The character ID to sponsor a unlink action.
     * @param   toCharacterId  The character ID to be unlinked.
     * @param   linkType  linkType, like “follow”.
     * @param   linklist  The linklist contract address.
     */
    function unlinkCharacter(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        bytes32 linkType,
        address linklist
    ) external {
        uint256 linklistId = StorageLib.getAttachedLinklistId(fromCharacterId, linkType);
        // remove from link list
        ILinklist(linklist).removeLinkingCharacterId(linklistId, toCharacterId);

        address linker = IERC721(address(this)).ownerOf(fromCharacterId);
        emit Events.UnlinkCharacter(linker, fromCharacterId, toCharacterId, linkType);
    }

    /**
     * @notice  Links a given note.
     * @param   fromCharacterId  The character ID to sponsor a link action.
     * @param   toCharacterId  The owner characterId of the note to link.
     * @param   toNoteId  The id of the note to link.
     * @param   linkType  The linkType, like “follow”.
     * @param   data  The data to pass to the link module, if any.
     * @param   linklist  The linklist contract address.
     * @param   linkModule  The linkModule address of the note to link
     */
    function linkNote(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        uint256 toNoteId,
        bytes32 linkType,
        bytes calldata data,
        address linklist,
        address linkModule
    ) external {
        address linker = IERC721(address(this)).ownerOf(fromCharacterId);
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist);

        // add to link list
        ILinklist(linklist).addLinkingNote(linklistId, toCharacterId, toNoteId);

        // process link
        if (linkModule != address(0)) {
            try
                ILinkModule4Note(linkModule).processLink(linker, toCharacterId, toNoteId, data)
            {} catch {} // solhint-disable-line no-empty-blocks
        }

        emit Events.LinkNote(fromCharacterId, toCharacterId, toNoteId, linkType, linklistId);
    }

    /**
     * @notice  Unlinks a given note.
     * @param   fromCharacterId  The character ID to sponsor an unlink action.
     * @param   toCharacterId  The character ID of note to unlink.
     * @param   toNoteId  The id of note to unlink.
     * @param   linkType  LinkType, like “follow”.
     * @param   linklist  The linklist contract address.
     */
    function unlinkNote(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        uint256 toNoteId,
        bytes32 linkType,
        address linklist
    ) external {
        // do note check note
        // _validateNoteExists(vars.toCharacterId, vars.toNoteId);
        uint256 linklistId = StorageLib.getAttachedLinklistId(fromCharacterId, linkType);
        // remove from link list
        ILinklist(linklist).removeLinkingNote(linklistId, toCharacterId, toNoteId);

        emit Events.UnlinkNote(fromCharacterId, toCharacterId, toNoteId, linkType, linklistId);
    }

    /**
     * @notice  Links a linklist.
     * @param   fromCharacterId  The character ID to sponsor an link action.
     * @param   toLinkListId  The linklist if to link.
     * @param   linkType  LinkType, like “follow”.
     * @param   linklist  The linklist contract address.
     */
    function linkLinklist(
        uint256 fromCharacterId,
        uint256 toLinkListId,
        bytes32 linkType,
        address linklist
    ) external {
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist);

        // add to link list
        ILinklist(linklist).addLinkingLinklistId(linklistId, toLinkListId);

        emit Events.LinkLinklist(fromCharacterId, toLinkListId, linkType, linklistId);
    }

    /**
     * @notice  Unlinks a linklist.
     * @param   fromCharacterId  The character ID to sponsor an unlink action.
     * @param   toLinkListId  The linklist if to unlink.
     * @param   linkType  LinkType, like “follow”.
     * @param   linklist  The linklist contract address.
     */
    function unlinkLinklist(
        uint256 fromCharacterId,
        uint256 toLinkListId,
        bytes32 linkType,
        address linklist
    ) external {
        uint256 linklistId = StorageLib.getAttachedLinklistId(fromCharacterId, linkType);
        // remove `toLinkListId` from linklist
        ILinklist(linklist).removeLinkingLinklistId(linklistId, toLinkListId);

        emit Events.UnlinkLinklist(fromCharacterId, toLinkListId, linkType, linklistId);
    }

    /**
     * @notice  Links an ERC721 token.
     * @param   fromCharacterId  The character ID to sponsor an link action.
     * @param   tokenAddress  The token address of ERC721 to link.
     * @param   tokenId  The token ID of ERC721 to link.
     * @param   linkType  linkType, like “follow”.
     * @param   linklist  The linklist contract address.
     */
    function linkERC721(
        uint256 fromCharacterId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType,
        address linklist
    ) external {
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist);

        // add to link list
        ILinklist(linklist).addLinkingERC721(linklistId, tokenAddress, tokenId);

        emit Events.LinkERC721(fromCharacterId, tokenAddress, tokenId, linkType, linklistId);
    }

    /**
     * @notice  Unlinks an ERC721 token.
     * @param   fromCharacterId  The character ID to sponsor an unlink action.
     * @param   tokenAddress  The token address of ERC721 to unlink.
     * @param   tokenId  The token ID of ERC721 to unlink.
     * @param   linkType  LinkType, like “follow”.
     * @param   linklist  The linklist contract address.
     */
    function unlinkERC721(
        uint256 fromCharacterId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType,
        address linklist
    ) external {
        uint256 linklistId = StorageLib.getAttachedLinklistId(fromCharacterId, linkType);

        // remove from linklist
        ILinklist(linklist).removeLinkingERC721(linklistId, tokenAddress, tokenId);

        emit Events.UnlinkERC721(fromCharacterId, tokenAddress, tokenId, linkType, linklistId);
    }

    /**
     * @notice  Creates a link to a given address.
     * @param   fromCharacterId  The character ID to init the link.
     * @param   ethAddress  The address to link.
     * @param   linkType  LinkType, like “follow”.
     * @param   linklist  The linklist contract address.
     */
    function linkAddress(
        uint256 fromCharacterId,
        address ethAddress,
        bytes32 linkType,
        address linklist
    ) external {
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist);

        // add to link list
        ILinklist(linklist).addLinkingAddress(linklistId, ethAddress);

        emit Events.LinkAddress(fromCharacterId, ethAddress, linkType, linklistId);
    }

    /**
     * @notice  Unlinks a given address.
     * @param   fromCharacterId  The character ID to init the unlink.
     * @param   ethAddress  The address to unlink.
     * @param   linkType  LinkType, like “follow”.
     * @param   linklist  The linklist contract address.
     */
    function unlinkAddress(
        uint256 fromCharacterId,
        address ethAddress,
        bytes32 linkType,
        address linklist
    ) external {
        uint256 linklistId = StorageLib.getAttachedLinklistId(fromCharacterId, linkType);
        // remove from linklist
        ILinklist(linklist).removeLinkingAddress(linklistId, ethAddress);

        emit Events.UnlinkAddress(fromCharacterId, ethAddress, linkType);
    }

    /**
     * @notice  Links any uri.
     * @param   fromCharacterId  The character ID to sponsor an link action.
     * @param   toUri  The uri to link.
     * @param   linkType  LinkType, like “follow”.
     * @param   linklist  The linklist contract address.
     */
    function linkAnyUri(
        uint256 fromCharacterId,
        string calldata toUri,
        bytes32 linkType,
        address linklist
    ) external {
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist);

        // add to link list
        ILinklist(linklist).addLinkingAnyUri(linklistId, toUri);

        emit Events.LinkAnyUri(fromCharacterId, toUri, linkType, linklistId);
    }

    /**
     * @notice  Unlinks any uri.
     * @param   fromCharacterId  The character ID to sponsor an unlink action.
     * @param   toUri  The uri to unlink.
     * @param   linkType  LinkType, like “follow”.
     * @param   linklist  The linklist contract address.
     */
    function unlinkAnyUri(
        uint256 fromCharacterId,
        string calldata toUri,
        bytes32 linkType,
        address linklist
    ) external {
        uint256 linklistId = StorageLib.getAttachedLinklistId(fromCharacterId, linkType);
        // remove from linklist
        ILinklist(linklist).removeLinkingAnyUri(linklistId, toUri);

        emit Events.UnlinkAnyUri(fromCharacterId, toUri, linkType);
    }

    /**
     * @notice  Returns the linklistId if the linklist already exists, Otherwise, creates a new 
        linklist and return its ID.
     */
    function _mintLinklist(
        uint256 fromCharacterId,
        bytes32 linkType,
        address linklist
    ) internal returns (uint256 linklistId) {
        linklistId = StorageLib.getAttachedLinklistId(fromCharacterId, linkType);
        if (linklistId == 0) {
            // mint linkList nft
            linklistId = ILinklist(linklist).mint(fromCharacterId, linkType);

            // attach linkList
            StorageLib.setAttachedLinklistId(fromCharacterId, linkType, linklistId);
            emit Events.AttachLinklist(linklistId, fromCharacterId, linkType);
        }
    }
}
