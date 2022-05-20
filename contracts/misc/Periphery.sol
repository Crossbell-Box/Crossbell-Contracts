// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../interfaces/IWeb3Entry.sol";
import "../libraries/DataTypes.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Periphery is Initializable {
    IWeb3Entry public web3Entry;

    function initialize(IWeb3Entry _web3Entry) external initializer {
        web3Entry = _web3Entry;
    }

    function linkProfilesInBatch(DataTypes.linkProfilesInBatchData calldata vars) external {
        require(vars.toProfileIds.length == vars.data.length, "ArrayLengthMismatch");

        for (uint256 i = 0; i < vars.toProfileIds.length; i++) {
            web3Entry.linkProfile(
                DataTypes.linkProfileData({
                    fromProfileId: vars.fromProfileId,
                    toProfileId: vars.toProfileIds[i],
                    linkType: vars.linkType,
                    data: vars.data[i]
                })
            );
        }

        for (uint256 i = 0; i < vars.toAddresses.length; i++) {
            web3Entry.createThenLinkProfile(
                DataTypes.createThenLinkProfileData({
                    fromProfileId: vars.fromProfileId,
                    to: vars.toAddresses[i],
                    linkType: vars.linkType
                })
            );
        }
    }

    function createProfileThenPostNote(DataTypes.createProfileThenPostNoteData calldata vars)
        external
    {
        // create profile
        web3Entry.createProfile(
            DataTypes.CreateProfileData({
                to: msg.sender,
                handle: vars.handle,
                uri: vars.uri,
                linkModule: vars.profileLinkModule,
                linkModuleInitData: vars.profileLinkModuleInitData
            })
        );

        // post note
        uint256 primaryProfileId = web3Entry.getPrimaryProfileId(msg.sender);
        web3Entry.postNote(
            DataTypes.PostNoteData({
                profileId: primaryProfileId,
                contentUri: vars.contentUri,
                linkModule: vars.noteLinkModule,
                linkModuleInitData: vars.noteLinkModuleInitData,
                mintModule: vars.mintModule,
                mintModuleInitData: vars.mintModuleInitData
            })
        );
    }
}
