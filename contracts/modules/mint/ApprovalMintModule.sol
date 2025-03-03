// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {ModuleBase} from "../ModuleBase.sol";
import {ErrNotEnoughPermission, ErrNotApprovedOrExceedApproval} from "../../libraries/Error.sol";
import {Events} from "../../libraries/Events.sol";
import {IMintModule4Note} from "../../interfaces/IMintModule4Note.sol";
import {IWeb3Entry} from "../../interfaces/IWeb3Entry.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title ApprovalMintModule
 * @notice This is a simple MintModule implementation, inheriting from the IMintModule4Note interface.
 * This module works by allowing limited minting for a post, and only for those who are approved.
 */
contract ApprovalMintModule is IMintModule4Note, ModuleBase {
    struct ApprovedInfo {
        uint256 approvedAmount;
        uint256 mintedAmount;
    }
    // characterId => noteId => address => ApprovedInfo

    mapping(uint256 => mapping(uint256 => mapping(address => ApprovedInfo))) internal _approvedInfo;

    // solhint-disable-next-line no-empty-blocks
    constructor(address web3Entry_) ModuleBase(web3Entry_) {}

    /**
     * @dev The data should an abi encoded bytes, containing (in order): an address array and an uint256
     */
    /// @inheritdoc IMintModule4Note
    function initializeMintModule(uint256 characterId, uint256 noteId, bytes calldata data)
        external
        override
        onlyWeb3Entry
        returns (bytes memory)
    {
        if (data.length > 0) {
            (address[] memory addresses, uint256 approvedAmount) = abi.decode(data, (address[], uint256));
            _setApprovedAmount(characterId, noteId, addresses, approvedAmount);
        }
        return data;
    }

    /**
     * @notice Set the approved addresses for minting and the approvedAmount allowed to be minted. <br>
     * The approvedAmount is 0 by default, and you can also revoke the approval for addresses by
     * setting the approvedAmount to 0.
     * @param characterId The character ID of the note owner.
     * @param noteId The ID of the note.
     * @param addresses The Addresses to set.
     * @param approvedAmount The amount of NFTs allowed to be minted.
     */
    // solhint-disable-next-line comprehensive-interface
    function setApprovedAmount(
        uint256 characterId,
        uint256 noteId,
        address[] calldata addresses,
        uint256 approvedAmount
    ) external {
        // msg.sender should be the character owner, or should be an operator of the note.
        address owner = IERC721(web3Entry).ownerOf(characterId);
        if (msg.sender != owner && !IWeb3Entry(web3Entry).isOperatorAllowedForNote(characterId, noteId, msg.sender)) {
            revert ErrNotEnoughPermission();
        }

        _setApprovedAmount(characterId, noteId, addresses, approvedAmount);
    }

    /**
     * @notice  Process minting and check if the caller is eligible.
     */
    /// @inheritdoc IMintModule4Note
    function processMint(address to, uint256 characterId, uint256 noteId, bytes calldata)
        external
        override
        onlyWeb3Entry
    {
        ApprovedInfo storage approval = _approvedInfo[characterId][noteId][to];
        if (approval.approvedAmount <= approval.mintedAmount) {
            revert ErrNotApprovedOrExceedApproval();
        } else {
            ++approval.mintedAmount;
        }
    }

    /**
     * @notice Returns the approved info indicates the approved amount and minted amount of an address.
     * @param characterId ID of the character to query.
     * @param noteId  ID of the note to query.
     * @param account The address to query.
     * @return approvedAmount The approved amount that the address can mint.
     * @return mintedAmount The amount that the address has already minted.
     */
    // solhint-disable-next-line comprehensive-interface
    function getApprovedInfo(uint256 characterId, uint256 noteId, address account)
        external
        view
        returns (uint256 approvedAmount, uint256 mintedAmount)
    {
        approvedAmount = _approvedInfo[characterId][noteId][account].approvedAmount;
        mintedAmount = _approvedInfo[characterId][noteId][account].mintedAmount;
    }

    function _setApprovedAmount(uint256 characterId, uint256 noteId, address[] memory addresses, uint256 approvedAmount)
        internal
    {
        uint256 len = addresses.length;
        for (uint256 i = 0; i < len;) {
            _approvedInfo[characterId][noteId][addresses[i]].approvedAmount = approvedAmount;

            unchecked {
                ++i;
            }
        }
        emit Events.SetApprovedMintAmount4Addresses(characterId, noteId, approvedAmount, addresses);
    }
}
