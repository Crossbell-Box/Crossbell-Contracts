// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Events.sol";
import "./DataTypes.sol";
import "../interfaces/ILinklist.sol";
import "../interfaces/ILinkModule4Profile.sol";
import "../interfaces/ILinkModule4Note.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

library LinkLogic {
    function linkProfile(
        uint256 fromProfileId,
        uint256 toProfileId,
        bytes32 linkType,
        bytes memory data,
        address linker,
        address linklist,
        mapping(uint256 => DataTypes.Profile) storage _profileById,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(
            fromProfileId,
            linkType,
            msg.sender,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingProfileId(linklistId, toProfileId);

        // process link module
        if (_profileById[toProfileId].linkModule != address(0)) {
            ILinkModule4Profile(_profileById[toProfileId].linkModule).processLink(
                linker,
                toProfileId,
                data
            );
        }

        emit Events.LinkProfile(msg.sender, fromProfileId, toProfileId, linkType, linklistId);
    }

    function linkNote(
        DataTypes.linkNoteData calldata vars,
        address linklist,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByProfile,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(
            vars.fromProfileId,
            vars.linkType,
            msg.sender,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingNote(linklistId, vars.toProfileId, vars.toNoteId);

        // process link
        address linkModule = _noteByIdByProfile[vars.toProfileId][vars.toNoteId].linkModule;
        if (linkModule != address(0)) {
            ILinkModule4Note(linkModule).processLink(
                msg.sender,
                vars.toProfileId,
                vars.toNoteId,
                vars.data
            );
        }

        emit Events.LinkNote(
            vars.fromProfileId,
            vars.toProfileId,
            vars.toNoteId,
            vars.linkType,
            linklistId
        );
    }

    function linkProfileLink(
        uint256 fromProfileId,
        DataTypes.ProfileLinkStruct calldata linkData,
        bytes32 linkType,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(
            fromProfileId,
            linkType,
            msg.sender,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingProfileLink(linklistId, linkData);

        // event
        emit Events.LinkProfileLink(
            fromProfileId,
            linkType,
            linkData.fromProfileId,
            linkData.toProfileId,
            linkData.linkType
        );
    }

    function linkLinklist(
        DataTypes.linkLinklistData calldata vars,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(
            vars.fromProfileId,
            vars.linkType,
            msg.sender,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingLinklistId(linklistId, vars.toLinkListId);

        emit Events.LinkLinklist(vars.fromProfileId, vars.toLinkListId, vars.linkType, linklistId);
    }

    function linkERC721(
        DataTypes.linkERC721Data calldata vars,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(
            vars.fromProfileId,
            vars.linkType,
            msg.sender,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingERC721(linklistId, vars.tokenAddress, vars.tokenId);

        emit Events.LinkERC721(
            vars.fromProfileId,
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
            vars.fromProfileId,
            vars.linkType,
            msg.sender,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingAddress(linklistId, vars.ethAddress);

        emit Events.LinkAddress(vars.fromProfileId, vars.ethAddress, vars.linkType, linklistId);
    }

    function linkAny(
        DataTypes.linkAnyData calldata vars,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) external {
        uint256 linklistId = _mintLinklist(
            vars.fromProfileId,
            vars.linkType,
            msg.sender,
            linklist,
            _attachedLinklists
        );

        // add to link list
        ILinklist(linklist).addLinkingAny(linklistId, vars.toUri);

        emit Events.LinkAny(vars.fromProfileId, vars.toUri, vars.linkType, linklistId);
    }

    function _mintLinklist(
        uint256 profileId,
        bytes32 linkType,
        address to,
        address linklist,
        mapping(uint256 => mapping(bytes32 => uint256)) storage _attachedLinklists
    ) internal returns (uint256 linklistId) {
        linklistId = _attachedLinklists[profileId][linkType];
        if (linklistId == 0) {
            linklistId = IERC721Enumerable(linklist).totalSupply() + 1;
            // mint linkList nft
            ILinklist(linklist).mint(to, linkType, linklistId);

            // set primary linkList
            ILinklist(linklist).setTakeOver(linklistId, to, profileId);
            _attachedLinklists[profileId][linkType] = linklistId;
            emit Events.AttachLinklist(linklistId, profileId, linkType);
        }
    }
}
