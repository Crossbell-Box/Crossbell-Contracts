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
        DataTypes.unlinkCharacterData calldata vars,
        address linklist,
        uint256 linklistId
    ) external {
        address linker = IERC721Enumerable(address(this)).ownerOf(vars.fromCharacterId);
        // remove from link list
        ILinklist(linklist).removeLinkingCharacterId(linklistId, vars.toCharacterId);

        emit Events.UnlinkCharacter(
            linker,
            vars.fromCharacterId,
            vars.toCharacterId,
            vars.linkType
        );
    }

    function linkNote(
        DataTypes.linkNoteData calldata vars,
        address linklist,
        address linkModule,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        address linker = IERC721Enumerable(address(this)).ownerOf(vars.fromCharacterId);
        uint256 linklistId = _mintLinklist(
            vars.fromCharacterId,
            vars.linkType,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingNote(linklistId, vars.toCharacterId, vars.toNoteId);

        // process link
        if (linkModule != address(0)) {
            try
                ILinkModule4Note(linkModule).processLink(
                    linker,
                    vars.toCharacterId,
                    vars.toNoteId,
                    vars.data
                )
            {} catch {} // solhint-disable-line no-empty-blocks
        }

        emit Events.LinkNote(
            vars.fromCharacterId,
            vars.toCharacterId,
            vars.toNoteId,
            vars.linkType,
            linklistId
        );
    }

    function unlinkNote(
        DataTypes.unlinkNoteData calldata vars,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        // do note check note
        // _validateNoteExists(vars.toCharacterId, vars.toNoteId);

        uint256 linklistId = _attachedLinklists[vars.fromCharacterId][vars.linkType];

        // remove from link list
        ILinklist(linklist).removeLinkingNote(linklistId, vars.toCharacterId, vars.toNoteId);

        emit Events.UnlinkNote(
            vars.fromCharacterId,
            vars.toCharacterId,
            vars.toNoteId,
            vars.linkType,
            linklistId
        );
    }

    function linkCharacterLink(
        uint256 fromCharacterId,
        DataTypes.CharacterLinkStruct calldata linkData,
        bytes32 linkType,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(fromCharacterId, linkType, linklist, _attachedLinklists);

        // add to link list
        ILinklist(linklist).addLinkingCharacterLink(linklistId, linkData);

        // event
        emit Events.LinkCharacterLink(
            fromCharacterId,
            linkType,
            linkData.fromCharacterId,
            linkData.toCharacterId,
            linkData.linkType
        );
    }

    function unlinkCharacterLink(
        uint256 fromCharacterId,
        DataTypes.CharacterLinkStruct calldata linkData,
        bytes32 linkType,
        address linklist,
        uint256 linklistId
    ) external {
        // remove from link list
        ILinklist(linklist).removeLinkingCharacterLink(linklistId, linkData);

        // event
        emit Events.UnlinkCharacterLink(
            fromCharacterId,
            linkType,
            linkData.fromCharacterId,
            linkData.toCharacterId,
            linkData.linkType
        );
    }

    function linkLinklist(
        DataTypes.linkLinklistData calldata vars,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(
            vars.fromCharacterId,
            vars.linkType,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingLinklistId(linklistId, vars.toLinkListId);

        emit Events.LinkLinklist(
            vars.fromCharacterId,
            vars.toLinkListId,
            vars.linkType,
            linklistId
        );
    }

    function unlinkLinklist(
        DataTypes.unlinkLinklistData calldata vars,
        address linklist,
        uint256 linklistId
    ) external {
        // add to link list
        ILinklist(linklist).removeLinkingLinklistId(linklistId, vars.toLinkListId);

        emit Events.UnlinkLinklist(
            vars.fromCharacterId,
            vars.toLinkListId,
            vars.linkType,
            linklistId
        );
    }

    function linkERC721(
        DataTypes.linkERC721Data calldata vars,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(
            vars.fromCharacterId,
            vars.linkType,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingERC721(linklistId, vars.tokenAddress, vars.tokenId);

        emit Events.LinkERC721(
            vars.fromCharacterId,
            vars.tokenAddress,
            vars.tokenId,
            vars.linkType,
            linklistId
        );
    }

    function unlinkERC721(
        DataTypes.unlinkERC721Data calldata vars,
        address linklist,
        uint256 linklistId
    ) external {
        // remove from link list
        ILinklist(linklist).removeLinkingERC721(linklistId, vars.tokenAddress, vars.tokenId);

        emit Events.UnlinkERC721(
            vars.fromCharacterId,
            vars.tokenAddress,
            vars.tokenId,
            vars.linkType,
            linklistId
        );
    }

    function linkAddress(
        DataTypes.linkAddressData calldata vars,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(
            vars.fromCharacterId,
            vars.linkType,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingAddress(linklistId, vars.ethAddress);

        emit Events.LinkAddress(vars.fromCharacterId, vars.ethAddress, vars.linkType, linklistId);
    }

    function unlinkAddress(
        DataTypes.unlinkAddressData calldata vars,
        address linklist,
        uint256 linklistId
    ) external {
        // remove from link list
        ILinklist(linklist).removeLinkingAddress(linklistId, vars.ethAddress);

        emit Events.UnlinkAddress(vars.fromCharacterId, vars.ethAddress, vars.linkType);
    }

    function linkAnyUri(
        DataTypes.linkAnyUriData calldata vars,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(
            vars.fromCharacterId,
            vars.linkType,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingAnyUri(linklistId, vars.toUri);

        emit Events.LinkAnyUri(vars.fromCharacterId, vars.toUri, vars.linkType, linklistId);
    }

    function unlinkAnyUri(
        DataTypes.unlinkAnyUriData calldata vars,
        address linklist,
        uint256 linklistId
    ) external {
        // remove from link list
        ILinklist(linklist).removeLinkingAnyUri(linklistId, vars.toUri);

        emit Events.UnlinkAnyUri(vars.fromCharacterId, vars.toUri, vars.linkType);
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
