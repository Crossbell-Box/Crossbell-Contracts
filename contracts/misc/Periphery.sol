// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../interfaces/IWeb3Entry.sol";
import "../interfaces/ILinklist.sol";
import "../libraries/DataTypes.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Periphery is Initializable {
    address public web3Entry;

    bool private linklistInitialized;
    address public linklist;

    function initialize(address _web3Entry, address _linklist) external initializer {
        web3Entry = _web3Entry;
        linklist = _linklist;
    }

    function getLinkingProfileIds(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory results)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromProfileId, linkType);
        uint256[] memory linkingProfileIds = ILinklist(linklist).getLinkingProfileIds(linklistId);

        uint256 len = linkingProfileIds.length;

        uint256 count;
        for (uint256 i = 0; i < len; i++) {
            if (profileExists(linkingProfileIds[i])) {
                count++;
            }
        }

        results = new uint256[](count);
        uint256 j;
        for (uint256 i = 0; i < len; i++) {
            if (profileExists(linkingProfileIds[i])) {
                results[j] = linkingProfileIds[i];
                j++;
            }
        }
    }

    function getLinkingProfileId(bytes32 linkKey) external view returns (uint256 profileId) {
        profileId = uint256(linkKey);
    }

    function getLinkingNotes(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (DataTypes.Note[] memory results)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromProfileId, linkType);
        DataTypes.NoteStruct[] memory notes = ILinklist(linklist).getLinkingNotes(linklistId);
        results = new DataTypes.Note[](notes.length);
        for (uint256 i = 0; i < notes.length; i++) {
            results[i] = IWeb3Entry(web3Entry).getNote(notes[i].profileId, notes[i].noteId);
        }
    }

    function getLinkingNote(bytes32 linkKey) external view returns (DataTypes.NoteStruct memory) {
        return ILinklist(linklist).getLinkingNote(linkKey);
    }

    function getLinkingERC721s(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (DataTypes.ERC721Struct[] memory results)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromProfileId, linkType);
        return ILinklist(linklist).getLinkingERC721s(linklistId);
    }

    function getLinkingERC721(bytes32 linkKey)
        external
        view
        returns (DataTypes.ERC721Struct memory)
    {
        return ILinklist(linklist).getLinkingERC721(linkKey);
    }

    function getLinkingAnyUris(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (string[] memory results)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromProfileId, linkType);
        return ILinklist(linklist).getLinkingAnyUris(linklistId);
    }

    function getLinkingAnyUri(bytes32 linkKey) external view returns (string memory) {
        return ILinklist(linklist).getLinkingAnyUri(linkKey);
    }

    function getLinkingAddresses(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (address[] memory)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromProfileId, linkType);
        return ILinklist(linklist).getLinkingAddresses(linklistId);
    }

    function getLinkingAddress(bytes32 linkKey) external view returns (address) {
        return address(uint160(uint256(linkKey)));
    }

    function getLinkingLinklistIds(uint256 fromProfileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory linklistIds)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromProfileId, linkType);
        return ILinklist(linklist).getLinkingLinklistIds(linklistId);
    }

    function getLinkingLinklistId(bytes32 linkKey) external view returns (uint256 linklistId) {
        linklistId = uint256(linkKey);
    }

    function profileExists(uint256 profileId) internal view returns (bool) {
        return IWeb3Entry(web3Entry).getProfile(profileId).profileId != 0;
    }

    function linkProfilesInBatch(DataTypes.linkProfilesInBatchData calldata vars) external {
        require(vars.toProfileIds.length == vars.data.length, "ArrayLengthMismatch");

        for (uint256 i = 0; i < vars.toProfileIds.length; i++) {
            IWeb3Entry(web3Entry).linkProfile(
                DataTypes.linkProfileData({
                    fromProfileId: vars.fromProfileId,
                    toProfileId: vars.toProfileIds[i],
                    linkType: vars.linkType,
                    data: vars.data[i]
                })
            );
        }

        for (uint256 i = 0; i < vars.toAddresses.length; i++) {
            IWeb3Entry(web3Entry).createThenLinkProfile(
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
        IWeb3Entry(web3Entry).createProfile(
            DataTypes.CreateProfileData({
                to: msg.sender,
                handle: vars.handle,
                uri: vars.uri,
                linkModule: vars.profileLinkModule,
                linkModuleInitData: vars.profileLinkModuleInitData
            })
        );

        // post note
        uint256 primaryProfileId = IWeb3Entry(web3Entry).getPrimaryProfileId(msg.sender);
        IWeb3Entry(web3Entry).postNote(
            DataTypes.PostNoteData({
                profileId: primaryProfileId,
                contentUri: vars.contentUri,
                linkModule: vars.noteLinkModule,
                linkModuleInitData: vars.noteLinkModuleInitData,
                mintModule: vars.mintModule,
                mintModuleInitData: vars.mintModuleInitData,
                locked: vars.locked
            })
        );
    }
}
