// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../libraries/DataTypes.sol";
import "../interfaces/IWeb3Entry.sol";

contract UIDataProvider {
    IWeb3Entry immutable entry;

    constructor(IWeb3Entry _entry) {
        entry = _entry;
    }

    function getLinkedProfiles(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (DataTypes.Profile[] memory results)
    {
        uint256[] memory listIds = IWeb3Entry(entry).getLinkedProfileIds(
            fromProfileId,
            linkType
        );

        results = new DataTypes.Profile[](listIds.length);
        for (uint256 i = 0; i < listIds.length; i++) {
            uint256 profileId = listIds[i];
            results[i] = IWeb3Entry(entry).getProfile(profileId);
        }
    }
}
