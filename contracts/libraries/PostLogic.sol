// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./DataTypes.sol";
import "./Events.sol";
import "../interfaces/ILinkModule4Note.sol";
import "../interfaces/IMintModule4Note.sol";

library PostLogic {
    function postNote4Link(
        DataTypes.PostNoteData calldata vars,
        uint256 noteId,
        uint256 linklistId,
        bytes32 linkItemType,
        bytes32 linkKey,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByProfile
    ) external {
        uint256 profileId = vars.profileId;
        // save note
        if (linkItemType != bytes32(0)) {
            _noteByIdByProfile[profileId][noteId].linkItemType = linkItemType;
            _noteByIdByProfile[profileId][noteId].linklistId = linklistId;
            _noteByIdByProfile[profileId][noteId].linkKey = linkKey;
        }
        _noteByIdByProfile[profileId][noteId].contentUri = vars.contentUri;
        _noteByIdByProfile[profileId][noteId].linkModule = vars.linkModule;
        _noteByIdByProfile[profileId][noteId].mintModule = vars.mintModule;

        // init link module
        if (vars.linkModule != address(0)) {
            bytes memory linkModuleReturnData = ILinkModule4Note(vars.linkModule)
                .initializeLinkModule(profileId, noteId, vars.linkModuleInitData);

            emit Events.SetLinkModule4Note(
                profileId,
                noteId,
                vars.linkModule,
                linkModuleReturnData,
                block.timestamp
            );
        }

        // init mint module
        if (vars.mintModule != address(0)) {
            bytes memory mintModuleReturnData = IMintModule4Note(vars.mintModule)
                .initializeMintModule(profileId, noteId, vars.mintModuleInitData);

            emit Events.SetMintModule4Note(
                profileId,
                noteId,
                vars.mintModule,
                mintModuleReturnData,
                block.timestamp
            );
        }

        emit Events.PostNote(
            profileId,
            noteId,
            linkItemType != bytes32(0) ? true : false,
            block.timestamp
        );
    }
}
