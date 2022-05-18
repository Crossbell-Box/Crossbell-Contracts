// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/DataTypes.sol";
import "../interfaces/IWeb3Entry.sol";
import "../interfaces/ILinklist.sol";

contract UIDataProvider {
    IWeb3Entry immutable entry;
    ILinklist immutable linklist;

    constructor(IWeb3Entry _entry, ILinklist _linklist) {
        entry = _entry;
        linklist = _linklist;
    }

    function getLinkedProfiles(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (DataTypes.Profile[] memory results)
    {
        uint256[] memory listIds = IWeb3Entry(entry).getLinkingProfileIds(fromProfileId, linkType);

        results = new DataTypes.Profile[](listIds.length);
        for (uint256 i = 0; i < listIds.length; i++) {
            uint256 profileId = listIds[i];
            results[i] = IWeb3Entry(entry).getProfile(profileId);
        }
    }

    function getLinkingNotes(bytes32[] calldata linkKeys)
        external
        view
        returns (DataTypes.Note[] memory results)
    {
        DataTypes.NoteStruct[] memory notes = ILinklist(linklist).getLinkingNotes(linkKeys);
        results = new DataTypes.Note[](notes.length);
        for (uint256 i = 0; i < notes.length; i++) {
            results[i] = IWeb3Entry(entry).getNote(notes[i].profileId, notes[i].noteId);
        }
    }
}
