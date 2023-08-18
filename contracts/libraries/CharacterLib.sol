// SPDX-License-Identifier: MIT
// solhint-disable  private-vars-leading-underscore
pragma solidity 0.8.18;

import {DataTypes} from "./DataTypes.sol";
import {Events} from "./Events.sol";
import {StorageLib} from "./StorageLib.sol";
import {ILinkModule4Character} from "../interfaces/ILinkModule4Character.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library CharacterLib {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    /**
     * @notice  Creates a character.
     * @param   to  The address to mint the character to.
     * @param   handle  The handle to set for the new character.
     * @param   uri  The URI to set for the new character’s metadata.
     * @param   linkModule  The link module to set for the new character or the zero address.
     * @param   linkModuleInitData  Arbitrary data to be decoded in the link module for initialization.
     * @param   characterId The ID of the new character.
     */
    function createCharacter(
        address to,
        string memory handle,
        string memory uri,
        address linkModule,
        bytes memory linkModuleInitData,
        uint256 characterId
    ) external {
        bytes32 handleHash = keccak256(bytes(handle));
        StorageLib.characterIdByHandleHash()[handleHash] = characterId;

        // save character
        DataTypes.Character storage _character = StorageLib.getCharacter(characterId);
        _character.characterId = characterId;
        _character.handle = handle;
        _character.uri = uri;

        // init link module
        if (linkModule != address(0)) {
            _character.linkModule = linkModule;

            ILinkModule4Character(linkModule).initializeLinkModule(characterId, linkModuleInitData);
        }

        emit Events.CharacterCreated(characterId, msg.sender, to, handle, block.timestamp);
    }

    /**
     * @notice  Sets a social token for a given character.
     * @param   characterId  	The character ID to set social token for.
     * @param   tokenAddress  Token address to be set.
     */
    function setSocialToken(uint256 characterId, address tokenAddress) external {
        StorageLib.getCharacter(characterId).socialToken = tokenAddress;
        emit Events.SetSocialToken(msg.sender, characterId, tokenAddress);
    }

    /**
     * @notice  Sets link module for a given character.
     * @param   characterId  The character ID to set link module for.
     * @param   linkModule  The link module to set.
     * @param   linkModuleInitData  The data to pass to the link module for initialization, if any.
     */
    function setCharacterLinkModule(
        uint256 characterId,
        address linkModule,
        bytes calldata linkModuleInitData
    ) external {
        StorageLib.getCharacter(characterId).linkModule = linkModule;

        bytes memory returnData = "";
        if (linkModule != address(0)) {
            returnData = ILinkModule4Character(linkModule).initializeLinkModule(
                characterId,
                linkModuleInitData
            );
        }
        emit Events.SetLinkModule4Character(
            characterId,
            linkModule,
            linkModuleInitData,
            returnData
        );
    }

    /**
     * @notice  Sets new handle for a given character.
     * @param   characterId  The character ID to set new handle for.
     * @param   newHandle  New handle to set.
     */
    function setHandle(uint256 characterId, string calldata newHandle) external {
        // remove old handle
        string memory oldHandle = StorageLib.getCharacter(characterId).handle;
        bytes32 oldHandleHash = keccak256(bytes(oldHandle));
        delete StorageLib.characterIdByHandleHash()[oldHandleHash];

        // set new handle
        bytes32 handleHash = keccak256(bytes(newHandle));
        StorageLib.characterIdByHandleHash()[handleHash] = characterId;
        StorageLib.getCharacter(characterId).handle = newHandle;

        emit Events.SetHandle(msg.sender, characterId, newHandle);
    }
}
