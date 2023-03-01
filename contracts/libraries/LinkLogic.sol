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
