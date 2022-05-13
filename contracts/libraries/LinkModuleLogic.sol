// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "hardhat/console.sol";
import "./Events.sol";
import "./DataTypes.sol";
import "../interfaces/IMintModule4Note.sol";
import "../interfaces/ILinkModule4Note.sol";
import "../interfaces/ILinkModule4ERC721.sol";
import "../interfaces/ILinkModule4Linklist.sol";
import "../interfaces/ILinkModule4Address.sol";

library LinkModuleLogic {
    function setLinkModule4Note(
        uint256 profileId,
        uint256 noteId,
        address linkModule,
        bytes calldata linkModuleInitData,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByProfile
    ) external {
        if (linkModule != address(0)) {
            _noteByIdByProfile[profileId][noteId].linkModule = linkModule;

            bytes memory returnData = ILinkModule4Note(linkModule).initializeLinkModule(
                profileId,
                noteId,
                linkModuleInitData
            );

            emit Events.SetLinkModule4Note(
                profileId,
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
        uint256 profileId,
        uint256 noteId,
        address mintModule,
        bytes calldata mintModuleInitData,
        mapping(uint256 => mapping(uint256 => DataTypes.Note)) storage _noteByIdByProfile
    ) external {
        if (mintModule != address(0)) {
            _noteByIdByProfile[profileId][noteId].mintModule = mintModule;

            bytes memory returnData = IMintModule4Note(mintModule).initializeMintModule(
                profileId,
                noteId,
                mintModuleInitData
            );

            emit Events.SetMintModule4Note(
                profileId,
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
