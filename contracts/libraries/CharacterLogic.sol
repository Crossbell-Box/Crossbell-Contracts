// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "hardhat/console.sol";
import "./DataTypes.sol";
import "./Events.sol";
import "./Constants.sol";
import "../interfaces/ILinkModule4Character.sol";
import "../interfaces/ILinklist.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library CharacterLogic {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    function createCharacter(
        DataTypes.CreateCharacterData calldata vars,
        bool validateHandle,
        uint256 characterId,
        mapping(bytes32 => uint256) storage _characterIdByHandleHash,
        mapping(uint256 => DataTypes.Character) storage _characterById
    ) external {
        if (validateHandle) {
            _validateHandle(vars.handle);
        }

        bytes32 handleHash = keccak256(bytes(vars.handle));
        require(_characterIdByHandleHash[handleHash] == 0, "HandleExists");

        _characterIdByHandleHash[handleHash] = characterId;

        _characterById[characterId].characterId = characterId;
        _characterById[characterId].handle = vars.handle;
        _characterById[characterId].uri = vars.uri;

        // init link module
        if (vars.linkModule != address(0)) {
            _characterById[characterId].linkModule = vars.linkModule;

            ILinkModule4Character(vars.linkModule).initializeLinkModule(
                characterId,
                vars.linkModuleInitData
            );
        }

        emit Events.CharacterCreated(
            characterId,
            msg.sender,
            vars.to,
            vars.handle,
            block.timestamp
        );
    }

    function setSocialToken(
        uint256 characterId,
        address tokenAddress,
        mapping(uint256 => DataTypes.Character) storage _characterById
    ) external {
        require(_characterById[characterId].socialToken == address(0), "SocialTokenExists");

        _characterById[characterId].socialToken = tokenAddress;

        emit Events.SetSocialToken(msg.sender, characterId, tokenAddress);
    }

    function setCharacterLinkModule(
        uint256 characterId,
        address linkModule,
        bytes calldata linkModuleInitData,
        DataTypes.Character storage _character
    ) external {
        _character.linkModule = linkModule;

        bytes memory returnData;
        if (linkModule != address(0)) {
            returnData = ILinkModule4Character(linkModule).initializeLinkModule(
                characterId,
                linkModuleInitData
            );
        }
        emit Events.SetLinkModule4Character(characterId, linkModule, returnData, block.timestamp);
    }

    function setHandle(
        uint256 characterId,
        string calldata newHandle,
        mapping(bytes32 => uint256) storage _characterIdByHandleHash,
        mapping(uint256 => DataTypes.Character) storage _characterById
    ) external {
        _validateHandle(newHandle);

        // set new handle
        bytes32 handleHash = keccak256(bytes(newHandle));
        require(_characterIdByHandleHash[handleHash] == 0, "HandleExists");

        // remove old handle
        string memory oldHandle = _characterById[characterId].handle;
        bytes32 oldHandleHash = keccak256(bytes(oldHandle));
        delete _characterIdByHandleHash[oldHandleHash];

        _characterIdByHandleHash[handleHash] = characterId;

        _characterById[characterId].handle = newHandle;

        emit Events.SetHandle(msg.sender, characterId, newHandle);
    }

    function _validateHandle(string calldata handle) private pure {
        bytes memory byteHandle = bytes(handle);
        require(
            byteHandle.length >= Constants.MIN_HANDLE_LENGTH &&
                byteHandle.length <= Constants.MAX_HANDLE_LENGTH,
            "HandleLengthInvalid"
        );

        uint256 byteHandleLength = byteHandle.length;
        for (uint256 i = 0; i < byteHandleLength; ++i) {
            require(
                (byteHandle[i] <= "9" && byteHandle[i] >= "0") ||
                    (byteHandle[i] <= "z" && byteHandle[i] >= "a") ||
                    byteHandle[i] == "-" ||
                    byteHandle[i] == "_",
                "HandleContainsInvalidCharacters"
            );
        }
    }
}
