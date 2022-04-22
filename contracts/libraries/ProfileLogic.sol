// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "hardhat/console.sol";
import "../libraries/DataTypes.sol";
import "../libraries/Events.sol";
import "../interfaces/ILinkModule4Profile.sol";

library ProfileLogic {
    function createProfile(
        DataTypes.CreateProfileData calldata vars,
        uint256 profileId,
        mapping(bytes32 => uint256) storage _profileIdByHandleHash,
        mapping(uint256 => DataTypes.Profile) storage _profileById
    ) external {
        bytes32 handleHash = keccak256(bytes(vars.handle));
        require(_profileIdByHandleHash[handleHash] == 0, "HandleExists");

        _profileIdByHandleHash[handleHash] = profileId;

        _profileById[profileId].profileId = profileId;
        _profileById[profileId].handle = vars.handle;
        _profileById[profileId].uri = vars.uri;

        // init link module
        if (vars.linkModule != address(0)) {
            ILinkModule4Profile(vars.linkModule).initializeLinkModule(
                profileId,
                vars.linkModuleInitData
            );
        }

        emit Events.ProfileCreated(profileId, msg.sender, vars.to, vars.handle, block.timestamp);
    }

    function setProfileLinkModule(
        uint256 profileId,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(uint256 => DataTypes.Profile) storage _profileById
    ) external {
        _profileById[profileId].linkModule = linkModule;

        if (linkModule != address(0)) {
            bytes memory returnData = ILinkModule4Profile(linkModule).initializeLinkModule(
                profileId,
                linkModuleInitData
            );
            emit Events.SetLinkModule4Profile(profileId, linkModule, returnData, block.timestamp);
        }
    }
}
