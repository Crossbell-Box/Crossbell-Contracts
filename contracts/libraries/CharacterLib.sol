// SPDX-License-Identifier: MIT
// solhint-disable  private-vars-leading-underscore
pragma solidity 0.8.18;

import {DataTypes} from "./DataTypes.sol";
import {Events} from "./Events.sol";
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
        uint256 characterId,
        mapping(bytes32 => uint256) storage _characterIdByHandleHash,
        mapping(uint256 => DataTypes.Character) storage _characterById
    ) external {
        bytes32 handleHash = keccak256(bytes(handle));
        _characterIdByHandleHash[handleHash] = characterId;

        _characterById[characterId].characterId = characterId;
        _characterById[characterId].handle = handle;
        _characterById[characterId].uri = uri;

        // init link module
        if (linkModule != address(0)) {
            _characterById[characterId].linkModule = linkModule;

            ILinkModule4Character(linkModule).initializeLinkModule(characterId, linkModuleInitData);
        }

        emit Events.CharacterCreated(characterId, msg.sender, to, handle, block.timestamp);
    }

    /**
     * @notice  Sets a social token for a given character.
     * @param   characterId  	The character ID to set social token for.
     * @param   tokenAddress  Token address to be set.
     */
    function setSocialToken(
        uint256 characterId,
        address tokenAddress,
        mapping(uint256 => DataTypes.Character) storage _characterById
    ) external {
        _characterById[characterId].socialToken = tokenAddress;

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
        bytes calldata linkModuleInitData,
        DataTypes.Character storage _character
    ) external {
        _character.linkModule = linkModule;

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
    function setHandle(
        uint256 characterId,
        string calldata newHandle,
        mapping(bytes32 => uint256) storage _characterIdByHandleHash,
        mapping(uint256 => DataTypes.Character) storage _characterById
    ) external {
        // remove old handle
        string memory oldHandle = _characterById[characterId].handle;
        bytes32 oldHandleHash = keccak256(bytes(oldHandle));
        delete _characterIdByHandleHash[oldHandleHash];

        // set new handle
        bytes32 handleHash = keccak256(bytes(newHandle));
        _characterIdByHandleHash[handleHash] = characterId;
        _characterById[characterId].handle = newHandle;

        emit Events.SetHandle(msg.sender, characterId, newHandle);
    }
}
