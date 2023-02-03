// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import "../interfaces/IWeb3Entry.sol";
import "../interfaces/ILinklist.sol";
import "../libraries/DataTypes.sol";
import "../libraries/Error.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract Periphery is Initializable {
    address public web3Entry;

    bool private _linklistInitialized; // obsoleted slot
    address public linklist;

    function initialize(address web3Entry_, address linklist_) external initializer {
        web3Entry = web3Entry_;
        linklist = linklist_;
    }

    function linkCharactersInBatch(DataTypes.linkCharactersInBatchData calldata vars) external {
        if (vars.toCharacterIds.length != vars.data.length) revert ErrArrayLengthMismatch();

        for (uint256 i = 0; i < vars.toCharacterIds.length; i++) {
            IWeb3Entry(web3Entry).linkCharacter(
                DataTypes.linkCharacterData({
                    fromCharacterId: vars.fromCharacterId,
                    toCharacterId: vars.toCharacterIds[i],
                    linkType: vars.linkType,
                    data: vars.data[i]
                })
            );
        }

        for (uint256 i = 0; i < vars.toAddresses.length; i++) {
            IWeb3Entry(web3Entry).createThenLinkCharacter(
                DataTypes.createThenLinkCharacterData({
                    fromCharacterId: vars.fromCharacterId,
                    to: vars.toAddresses[i],
                    linkType: vars.linkType
                })
            );
        }
    }

    function sync(
        address account,
        string calldata handle,
        string calldata uri,
        address[] calldata toAddresses,
        bytes32 linkType
    ) external {
        _migrate(account, handle, uri, toAddresses, linkType);
    }

    function migrate(DataTypes.MigrateData calldata vars) external {
        _migrate(vars.account, vars.handle, vars.uri, vars.toAddresses, vars.linkType);
    }

    function getNotesByCharacterId(
        uint256 characterId,
        uint256 offset,
        uint256 limit
    ) external view returns (DataTypes.Note[] memory results) {
        uint256 count = IWeb3Entry(web3Entry).getCharacter(characterId).noteCount;
        limit = Math.min(limit, count - offset);

        results = new DataTypes.Note[](limit);
        if (offset >= count) return results;

        for (uint256 i = offset; i < offset + limit; i++) {
            results[i - offset] = IWeb3Entry(web3Entry).getNote(characterId, i);
        }
    }

    function getLinkingCharacterIds(uint256 fromCharacterId, bytes32 linkType)
        external
        view
        returns (uint256[] memory results)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromCharacterId, linkType);
        uint256[] memory linkingCharacterIds = ILinklist(linklist).getLinkingCharacterIds(
            linklistId
        );

        uint256 len = linkingCharacterIds.length;

        uint256 count;
        for (uint256 i = 0; i < len; i++) {
            if (_exists(linkingCharacterIds[i])) {
                count++;
            }
        }

        results = new uint256[](count);
        uint256 j;
        for (uint256 i = 0; i < len; i++) {
            if (_exists(linkingCharacterIds[i])) {
                results[j] = linkingCharacterIds[i];
                j++;
            }
        }
    }

    function getLinkingNotes(uint256 fromCharacterId, bytes32 linkType)
        external
        view
        returns (DataTypes.Note[] memory results)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromCharacterId, linkType);
        DataTypes.NoteStruct[] memory notes = ILinklist(linklist).getLinkingNotes(linklistId);
        results = new DataTypes.Note[](notes.length);
        for (uint256 i = 0; i < notes.length; i++) {
            results[i] = IWeb3Entry(web3Entry).getNote(notes[i].characterId, notes[i].noteId);
        }
    }

    function getLinkingNote(bytes32 linkKey) external view returns (DataTypes.NoteStruct memory) {
        return ILinklist(linklist).getLinkingNote(linkKey);
    }

    function getLinkingERC721s(uint256 fromCharacterId, bytes32 linkType)
        external
        view
        returns (DataTypes.ERC721Struct[] memory results)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromCharacterId, linkType);
        return ILinklist(linklist).getLinkingERC721s(linklistId);
    }

    function getLinkingERC721(bytes32 linkKey)
        external
        view
        returns (DataTypes.ERC721Struct memory)
    {
        return ILinklist(linklist).getLinkingERC721(linkKey);
    }

    function getLinkingAnyUris(uint256 fromCharacterId, bytes32 linkType)
        external
        view
        returns (string[] memory results)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromCharacterId, linkType);
        return ILinklist(linklist).getLinkingAnyUris(linklistId);
    }

    function getLinkingAnyUri(bytes32 linkKey) external view returns (string memory) {
        return ILinklist(linklist).getLinkingAnyUri(linkKey);
    }

    function getLinkingAddresses(uint256 fromCharacterId, bytes32 linkType)
        external
        view
        returns (address[] memory)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromCharacterId, linkType);
        return ILinklist(linklist).getLinkingAddresses(linklistId);
    }

    function getLinkingLinklistIds(uint256 fromCharacterId, bytes32 linkType)
        external
        view
        returns (uint256[] memory linklistIds)
    {
        uint256 linklistId = IWeb3Entry(web3Entry).getLinklistId(fromCharacterId, linkType);
        return ILinklist(linklist).getLinkingLinklistIds(linklistId);
    }

    function getLinkingLinklistId(bytes32 linkKey) external pure returns (uint256 linklistId) {
        linklistId = uint256(linkKey);
    }

    function getLinkingAddress(bytes32 linkKey) external pure returns (address) {
        return address(uint160(uint256(linkKey)));
    }

    function getLinkingCharacterId(bytes32 linkKey) external pure returns (uint256 characterId) {
        characterId = uint256(linkKey);
    }

    /**
     * @dev _migrate will not update handle if the target character already exists
     */
    // solhint-disable-next-line function-max-lines
    function _migrate(
        address account,
        string memory handle,
        string memory uri,
        address[] memory toAddresses,
        bytes32 linkType
    ) internal {
        uint256 fromProfileId = IWeb3Entry(web3Entry).getPrimaryCharacterId(account);
        if (fromProfileId == 0) {
            // create character first
            IWeb3Entry(web3Entry).createCharacter(
                DataTypes.CreateCharacterData({
                    to: account,
                    handle: handle,
                    uri: uri,
                    linkModule: address(0),
                    linkModuleInitData: ""
                })
            );
            // get primary character id
            fromProfileId = IWeb3Entry(web3Entry).getPrimaryCharacterId(account);
        } else {
            if (bytes(uri).length > 0) {
                // set character uri
                IWeb3Entry(web3Entry).setCharacterUri(fromProfileId, uri);
            }
        }

        // link
        for (uint256 i = 0; i < toAddresses.length; i++) {
            uint256 toProfileId = IWeb3Entry(web3Entry).getPrimaryCharacterId(toAddresses[i]);
            if (toProfileId == 0) {
                IWeb3Entry(web3Entry).createThenLinkCharacter(
                    DataTypes.createThenLinkCharacterData({
                        fromCharacterId: fromProfileId,
                        to: toAddresses[i],
                        linkType: linkType
                    })
                );
            } else {
                IWeb3Entry(web3Entry).linkCharacter(
                    DataTypes.linkCharacterData({
                        fromCharacterId: fromProfileId,
                        toCharacterId: toProfileId,
                        linkType: linkType,
                        data: ""
                    })
                );
            }
        }
    }

    function _exists(uint256 characterId) internal view returns (bool) {
        return IWeb3Entry(web3Entry).getCharacter(characterId).characterId != 0;
    }
}
