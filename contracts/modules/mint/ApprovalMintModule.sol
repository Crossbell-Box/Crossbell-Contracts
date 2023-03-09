// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "../../interfaces/IMintModule4Note.sol";
import "../ModuleBase.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ErrNotCharacterOwner, ErrArrayLengthMismatch, ErrNotApproved} from "../../libraries/Error.sol";

/**
 * @title ApprovalMintModule
 * @notice This is a simple MintModule implementation, inheriting from the IMintModule4Note interface.
 */
contract ApprovalMintModule is IMintModule4Note, ModuleBase {
    // characterId => noteId => address => isApproved
    mapping(uint256 => mapping(uint256 => mapping(address => bool)))
        internal _approvedByCharacterByNoteByOwner;

    // solhint-disable-next-line no-empty-blocks
    constructor(address web3Entry_) ModuleBase(web3Entry_) {}

    /**
     * @notice  Initialize the MintModule for a specific note.
     * @param   characterId  The character ID of the note to initialize.
     * @param   noteId  The note ID to initialize.
     * @param   data  The address list that are approved to mint the note.
     * @return  bytes  The returned data of calling initializeMintModule.
     */
    function initializeMintModule(
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external override onlyWeb3Entry returns (bytes memory) {
        if (data.length > 0) {
            address[] memory addresses = abi.decode(data, (address[]));
            _setApproval(characterId, noteId, addresses, true);
        }
        return data;
    }

    /**
     * @notice The owner of specified note can call this function,
     * to approve accounts to mint specified note.
     * @param characterId The character ID of the note owner.
     * @param noteId The ID of the note.
     * @param addresses The Addresses to set.
     * @param approved True means approval and False means disapproval.
     */
    // solhint-disable-next-line comprehensive-interface
    function setApproval(
        uint256 characterId,
        uint256 noteId,
        address[] calldata addresses,
        bool approved
    ) external {
        // msg.sender should be the character owner
        address owner = IERC721(web3Entry).ownerOf(characterId);
        if (msg.sender != owner) revert ErrNotCharacterOwner();

        _setApproval(characterId, noteId, addresses, approved);
    }

    /**
     * @notice Processes the mint logic.
     * Triggered when the `mintNote` of web3Entry is called, if mint module of note if set.
     */
    // solhint-disable-next-line comprehensive-interface
    function processMint(
        address to,
        uint256 characterId,
        uint256 noteId,
        bytes calldata
    ) external view override onlyWeb3Entry {
        if (!_approvedByCharacterByNoteByOwner[characterId][noteId][to]) revert ErrNotApproved();
    }

    /**
     * @notice Checks whether the `account` is approved to mint specified note .
     * @param characterId ID of character to query.
     * @param noteId  ID of note to query.
     * @param account Address of account to query.
     * @return Returns true if the `account` is approved to mint, otherwise returns false.
     */
    // solhint-disable-next-line comprehensive-interface
    function isApproved(
        uint256 characterId,
        uint256 noteId,
        address account
    ) external view returns (bool) {
        return _approvedByCharacterByNoteByOwner[characterId][noteId][account];
    }

    function _setApproval(
        uint256 characterId,
        uint256 noteId,
        address[] memory addresses,
        bool approved
    ) internal {
        uint256 addressesLength = addresses.length;
        for (uint256 i = 0; i < addressesLength; ) {
            _approvedByCharacterByNoteByOwner[characterId][noteId][addresses[i]] = approved;
            unchecked {
                ++i;
            }
        }
    }
}
