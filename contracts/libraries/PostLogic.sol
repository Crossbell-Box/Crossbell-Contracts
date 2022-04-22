// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./DataTypes.sol";
import "./Events.sol";
import "../interfaces/ILinkModule4Note.sol";
import "../interfaces/IMintModule4Note.sol";

library PostLogic {
    function postNote4Link(
        DataTypes.PostNoteData calldata noteData,
        uint256 noteId,
        uint256 linklistId,
        bytes32 linkItemType,
        bytes32 linkKey,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByProfile
    ) external {
        uint256 profileId = noteData.profileId;
        // save note
        if (linkItemType != bytes32(0)) {
            _noteByIdByProfile[profileId][noteId].linkItemType = linkItemType;
            _noteByIdByProfile[profileId][noteId].linklistId = linklistId;
            _noteByIdByProfile[profileId][noteId].linkKey = linkKey;
        }
        _noteByIdByProfile[profileId][noteId].contentUri = noteData.contentUri;
        _noteByIdByProfile[profileId][noteId].linkModule = noteData.linkModule;
        _noteByIdByProfile[profileId][noteId].mintModule = noteData.mintModule;

        // init link module
        bytes memory linkModuleReturnData = ILinkModule4Note(noteData.linkModule)
            .initializeLinkModule(profileId, noteId, noteData.linkModuleInitData);

        // init mint module
        bytes memory mintModuleReturnData = IMintModule4Note(noteData.mintModule)
            .initializeMintModule(profileId, noteId, noteData.mintModuleInitData);

        emit Events.SetLinkModule4Note(
            profileId,
            noteId,
            noteData.linkModule,
            linkModuleReturnData,
            block.timestamp
        );
        emit Events.SetMintModule4Note(
            profileId,
            noteId,
            noteData.mintModule,
            mintModuleReturnData,
            block.timestamp
        );
    }
}
