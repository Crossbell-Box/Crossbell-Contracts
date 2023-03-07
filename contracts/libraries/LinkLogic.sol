// SPDX-License-Identifier: MIT
// solhint-disable  private-vars-leading-underscore
pragma solidity 0.8.16;

import "./Events.sol";
import "./DataTypes.sol";
import "../interfaces/ILinklist.sol";
import "../interfaces/ILinkModule4Character.sol";
import "../interfaces/ILinkModule4Note.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library LinkLogic {
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
        address linkModule,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        address linker = IERC721Enumerable(address(this)).ownerOf(fromCharacterId);
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist, _attachedLinklists);

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
     * @param   linklistId  The ID of the linklist to unlink.
     */
    function unlinkCharacter(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        bytes32 linkType,
        address linklist,
        uint256 linklistId
    ) external {
        address linker = IERC721Enumerable(address(this)).ownerOf(fromCharacterId);
        // remove from link list
        ILinklist(linklist).removeLinkingCharacterId(linklistId, toCharacterId);

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
        address linkModule,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        address linker = IERC721Enumerable(address(this)).ownerOf(fromCharacterId);
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist, _attachedLinklists);

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
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        // do note check note
        // _validateNoteExists(vars.toCharacterId, vars.toNoteId);

        uint256 linklistId = _attachedLinklists[fromCharacterId][linkType];

        // remove from link list
        ILinklist(linklist).removeLinkingNote(linklistId, toCharacterId, toNoteId);

        emit Events.UnlinkNote(fromCharacterId, toCharacterId, toNoteId, linkType, linklistId);
    }

    /**
     * @notice  Links a characterLink.
     * @param   fromCharacterId  The from character ID of characterLink.
     * @param   toCharacterId  The to character ID of characterLink.
     * @param   linkType  The linkType of characterLink.
     * @param   linklist  The linklist contract address.
     */
    function linkCharacterLink(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        bytes32 linkType,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist, _attachedLinklists);

        // add to link list
        ILinklist(linklist).addLinkingCharacterLink(
            linklistId,
            DataTypes.CharacterLinkStruct(fromCharacterId, toCharacterId, linkType)
        );

        // event
        emit Events.LinkCharacterLink(
            fromCharacterId,
            linkType,
            fromCharacterId,
            toCharacterId,
            linkType
        );
    }

    /**
     * @notice  Unlinks a characterLink.
     * @param   fromCharacterId  The from character ID of characterLink.
     * @param   toCharacterId  The to character ID of characterLink.
     * @param   linkType  The linkType of characterLink.
     * @param   linklist  The linklist contract address.
     * @param   linklistId  The ID of the linklist to unlink.
     */
    function unlinkCharacterLink(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        bytes32 linkType,
        address linklist,
        uint256 linklistId
    ) external {
        // remove from link list
        ILinklist(linklist).removeLinkingCharacterLink(
            linklistId,
            DataTypes.CharacterLinkStruct(fromCharacterId, toCharacterId, linkType)
        );

        // event
        emit Events.UnlinkCharacterLink(
            fromCharacterId,
            linkType,
            fromCharacterId,
            toCharacterId,
            linkType
        );
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
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist, _attachedLinklists);

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
     * @param   linklistId  The ID of the linklist to unlink.
     */
    function unlinkLinklist(
        uint256 fromCharacterId,
        uint256 toLinkListId,
        bytes32 linkType,
        address linklist,
        uint256 linklistId
    ) external {
        // add to link list
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
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist, _attachedLinklists);

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
     * @param   linklistId  The ID of the linklist to unlink.
     */
    function unlinkERC721(
        uint256 fromCharacterId,
        address tokenAddress,
        uint256 tokenId,
        bytes32 linkType,
        address linklist,
        uint256 linklistId
    ) external {
        // remove from link list
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
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist, _attachedLinklists);

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
     * @param   linklistId  The ID of the linklist to unlink.
     */
    function unlinkAddress(
        uint256 fromCharacterId,
        address ethAddress,
        bytes32 linkType,
        address linklist,
        uint256 linklistId
    ) external {
        // remove from link list
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
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist, _attachedLinklists);

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
     * @param   linklistId  The ID of the linklist to unlink.
     */
    function unlinkAnyUri(
        uint256 fromCharacterId,
        string calldata toUri,
        bytes32 linkType,
        address linklist,
        uint256 linklistId
    ) external {
        // remove from link list
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
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) internal returns (uint256 linklistId) {
        linklistId = _attachedLinklists[fromCharacterId][linkType];
        if (linklistId == 0) {
            // mint linkList nft
            linklistId = ILinklist(linklist).mint(fromCharacterId, linkType);

            // attach linkList
            _attachedLinklists[fromCharacterId][linkType] = linklistId;
            emit Events.AttachLinklist(linklistId, fromCharacterId, linkType);
        }
    }
}
