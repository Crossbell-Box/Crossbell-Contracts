// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "hardhat/console.sol";
import "./DataTypes.sol";
import "./Events.sol";
import "./Constants.sol";
import "../interfaces/ILinkModule4Profile.sol";

library ProfileLogic {
    function createProfile(
        DataTypes.CreateProfileData calldata vars,
        uint256 profileId,
        mapping(bytes32 => uint256) storage _profileIdByHandleHash,
        mapping(uint256 => DataTypes.Profile) storage _profileById
    ) external {
        _validateHandle(vars.handle);

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
        DataTypes.Profile storage _profile
    ) external {
        _profile.linkModule = linkModule;

        if (linkModule != address(0)) {
            bytes memory returnData = ILinkModule4Profile(linkModule).initializeLinkModule(
                profileId,
                linkModuleInitData
            );
            emit Events.SetLinkModule4Profile(profileId, linkModule, returnData, block.timestamp);
        }
    }

    function setHandle(
        uint256 profileId,
        string calldata newHandle,
        mapping(bytes32 => uint256) storage _profileIdByHandleHash,
        mapping(uint256 => DataTypes.Profile) storage _profileById
    ) external {
        _validateHandle(newHandle);

        // set new handle
        bytes32 handleHash = keccak256(bytes(newHandle));
        require(_profileIdByHandleHash[handleHash] == 0, "HandleExists");

        // remove old handle
        string memory oldHandle = _profileById[profileId].handle;
        bytes32 oldHandleHash = keccak256(bytes(oldHandle));
        delete _profileIdByHandleHash[oldHandleHash];

        _profileIdByHandleHash[handleHash] = profileId;

        _profileById[profileId].handle = newHandle;

        emit Events.SetHandle(msg.sender, profileId, newHandle);
    }

    function _validateHandle(string calldata handle) private pure {
        bytes memory byteHandle = bytes(handle);
        require(
            byteHandle.length != 0 && byteHandle.length <= Constants.MAX_HANDLE_LENGTH,
            "HandleLengthInvalid"
        );

        uint256 byteHandleLength = byteHandle.length;
        for (uint256 i = 0; i < byteHandleLength; ++i) {
            require(
                (byteHandle[i] <= "9" && byteHandle[i] >= "0") ||
                    (byteHandle[i] <= "z" && byteHandle[i] >= "a") ||
                    byteHandle[i] == "." ||
                    byteHandle[i] == "-" ||
                    byteHandle[i] == "_",
                "HandleContainsInvalidCharacters"
            );
        }
    }
}
