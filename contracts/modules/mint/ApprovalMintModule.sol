// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {IMintModule4Note} from "../../interfaces/IMintModule4Note.sol";
import {ModuleBase} from "../ModuleBase.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ErrNotCharacterOwner, ErrNotApproved} from "../../libraries/Error.sol";
import {Events} from "../../libraries/Events.sol";

/**
 * @title ApprovalMintModule
 * @notice This is a simple MintModule implementation, inheriting from the IMintModule4Note interface.
 */
contract ApprovalMintModule is IMintModule4Note, ModuleBase {
    // characterId => noteId => address => approvedAmount
    mapping(uint256 => mapping(uint256 => mapping(address => uint256))) internal _approvedAmounts;

    // solhint-disable-next-line no-empty-blocks
    constructor(address web3Entry_) ModuleBase(web3Entry_) {}

    /**
     * @dev The data should an abi encoded bytes, containing (in order): an address array and an uint256
     */
    /// @inheritdoc IMintModule4Note
    function initializeMintModule(
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external override onlyWeb3Entry returns (bytes memory) {
        if (data.length > 0) {
            (address[] memory addresses, uint256 approvedAmount) = abi.decode(
                data,
                (address[], uint256)
            );
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
        // msg.sender should be the character owner
        address owner = IERC721(web3Entry).ownerOf(characterId);
        if (msg.sender != owner) revert ErrNotCharacterOwner();

        _setApprovedAmount(characterId, noteId, addresses, approvedAmount);
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
        uint256 approvedAmount = _approvedAmounts[characterId][noteId][to];
        if (approvedAmount == 0) {
            revert ErrNotApproved();
        } else {
            _approvedAmounts[characterId][noteId][to] = approvedAmount - 1;
        }
    }

    /**
     * @notice Get the allowed amount that an address can mint.
     * @param characterId ID of the character to query.
     * @param noteId  ID of the note to query.
     * @param account The address to query.
     * @return The allowed amount that the address can mint.
     */
    // solhint-disable-next-line comprehensive-interface
    function getApprovedAmount(
        uint256 characterId,
        uint256 noteId,
        address account
    ) external view returns (uint256) {
        return _approvedAmounts[characterId][noteId][account];
    }

    function _setApprovedAmount(
        uint256 characterId,
        uint256 noteId,
        address[] memory addresses,
        uint256 approvedAmount
    ) internal {
        uint256 addressesLength = addresses.length;
        for (uint256 i = 0; i < addressesLength; ) {
            _approvedAmounts[characterId][noteId][addresses[i]] = approvedAmount;
            unchecked {
                ++i;
            }
        }
        emit Events.SetApprovedMintAmount4Addresses(characterId, noteId, approvedAmount, addresses);
    }
}
