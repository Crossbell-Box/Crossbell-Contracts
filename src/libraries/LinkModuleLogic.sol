// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./Events.sol";
import "./DataTypes.sol";
import "../interfaces/IMintModule4Note.sol";
import "../interfaces/ILinkModule4Note.sol";
import "../interfaces/ILinkModule4ERC721.sol";
import "../interfaces/ILinkModule4Linklist.sol";
import "../interfaces/ILinkModule4Address.sol";

library LinkModuleLogic {
    function setLinkModule4Note(
        uint256 characterId,
        uint256 noteId,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) external {
        require(!_noteByIdByCharacter[characterId][noteId].locked, "NoteLocked");

        if (linkModule != address(0)) {
            _noteByIdByCharacter[characterId][noteId].linkModule = linkModule;

            bytes memory returnData = ILinkModule4Note(linkModule).initializeLinkModule(
                characterId,
                noteId,
                linkModuleInitData
            );

            emit Events.SetLinkModule4Note(
                characterId,
                noteId,
                linkModule,
                returnData,
                block.timestamp
            );
        }
    }

    function setLinkModule4Address(
        address account,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(address => address) storage _linkModules4Address
    ) external {
        require(msg.sender == account, "NotAddressOwner");

        if (linkModule != address(0)) {
            _linkModules4Address[account] = linkModule;
            bytes memory linkModuleReturnData = ILinkModule4Address(linkModule)
                .initializeLinkModule(account, linkModuleInitData);

            emit Events.SetLinkModule4Address(
                account,
                linkModule,
                linkModuleReturnData,
                block.timestamp
            );
        }
    }

    function setMintModule4Note(
        uint256 characterId,
        uint256 noteId,
        address mintModule,
        bytes calldata mintModuleInitData,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByCharacter
    ) external {
        require(!_noteByIdByCharacter[characterId][noteId].locked, "NoteLocked");

        if (mintModule != address(0)) {
            _noteByIdByCharacter[characterId][noteId].mintModule = mintModule;

            bytes memory returnData = IMintModule4Note(mintModule).initializeMintModule(
                characterId,
                noteId,
                mintModuleInitData
            );

            emit Events.SetMintModule4Note(
                characterId,
                noteId,
                mintModule,
                returnData,
                block.timestamp
            );
        }
    }

    function setLinkModule4Linklist(
        uint256 linklistId,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(uint256 => address) storage _linkModules4Linklist
    ) external {
        if (linkModule != address(0)) {
            _linkModules4Linklist[linklistId] = linkModule;
            bytes memory linkModuleReturnData = ILinkModule4Linklist(linkModule)
                .initializeLinkModule(linklistId, linkModuleInitData);

            emit Events.SetLinkModule4Linklist(
                linklistId,
                linkModule,
                linkModuleReturnData,
                block.timestamp
            );
        }
    }

    function setLinkModule4ERC721(
        address tokenAddress,
        uint256 tokenId,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(address => mapping(uint256 => address)) storage _linkModules4ERC721
    ) external {
        if (linkModule != address(0)) {
            _linkModules4ERC721[tokenAddress][tokenId] = linkModule;
            bytes memory linkModuleReturnData = ILinkModule4ERC721(linkModule).initializeLinkModule(
                tokenAddress,
                tokenId,
                linkModuleInitData
            );

            emit Events.SetLinkModule4ERC721(
                tokenAddress,
                tokenId,
                linkModule,
                linkModuleReturnData,
                block.timestamp
            );
        }
    }
}
