// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ModuleBase} from "../ModuleBase.sol";
import {IMintModule4Note} from "../../interfaces/IMintModule4Note.sol";
import {ErrExceedMaxSupply, ErrExceedApproval} from "../../libraries/Error.sol";

/**
 * @title LimitedMintModule
 * @notice This is a simple MintModule implementation, inheriting from the IMintModule4Note interface.
 * This module works by allowing limited minting for a post.
 */
contract LimitedMintModule is IMintModule4Note, ModuleBase {
    struct LimitedMintInfo {
        uint256 maxSupply; // max minted count
        uint256 currentSupply; // current minted amount
        uint256 maxMintPerAddress; // max mint amount per address
    }

    // characterId => noteId => LimitedMintInfo
    mapping(uint256 => mapping(uint256 => LimitedMintInfo)) internal _limitedMintInfo;
    // characterId => noteId => address => mintedAmount
    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) internal _mintedAmount;

    // solhint-disable-next-line no-empty-blocks
    constructor(address web3Entry_) ModuleBase(web3Entry_) {}

    /**
     * @dev The data should an abi encoded bytes of (uint256,uint256)
     */
    /// @inheritdoc IMintModule4Note
    function initializeMintModule(
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external override onlyWeb3Entry returns (bytes memory) {
        if (data.length > 0) {
            (uint256 maxSupply, uint256 maxMintPerAddress) = abi.decode(data, (uint256, uint256));
            _limitedMintInfo[characterId][noteId].maxSupply = maxSupply;
            _limitedMintInfo[characterId][noteId].maxMintPerAddress = maxMintPerAddress;
        }
        return data;
    }

    /**
     * @notice  Process minting and check if the caller is eligible.
     */
    /// @inheritdoc IMintModule4Note
    function processMint(
        address to,
        uint256 characterId,
        uint256 noteId,
        bytes calldata
    ) external override onlyWeb3Entry {
        LimitedMintInfo storage info = _limitedMintInfo[characterId][noteId];
        // check max supply
        if (info.currentSupply >= info.maxSupply) revert ErrExceedMaxSupply();
        // check approved amount
        if (_mintedAmount[characterId][noteId][to] >= info.maxMintPerAddress)
            revert ErrExceedApproval();

        // increase currentSupply and mintedAmount
        ++info.currentSupply;
        ++_mintedAmount[characterId][noteId][to];
    }

    /**
     * @notice Returns the info indicates the limited mint info of an address.
     * @param characterId ID of the character to query.
     * @param noteId  ID of the note to query.
     * @param account The address to query.
     * @return maxSupply The max supply of nft that can be minted.
     * @return currentSupply The current supply of nft that has been minted.
     * @return maxMintPerAddress The amount that each address can mint.
     * @return mintedAmount The amount that the address has already minted.
     */
    // solhint-disable-next-line comprehensive-interface
    function getLimitedMintInfo(
        uint256 characterId,
        uint256 noteId,
        address account
    )
        external
        view
        returns (
            uint256 maxSupply,
            uint256 currentSupply,
            uint256 maxMintPerAddress,
            uint256 mintedAmount
        )
    {
        maxSupply = _limitedMintInfo[characterId][noteId].maxSupply;
        currentSupply = _limitedMintInfo[characterId][noteId].currentSupply;
        maxMintPerAddress = _limitedMintInfo[characterId][noteId].maxMintPerAddress;
        mintedAmount = _mintedAmount[characterId][noteId][account];
    }
}
