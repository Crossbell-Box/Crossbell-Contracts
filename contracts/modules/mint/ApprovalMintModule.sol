// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "../../interfaces/IMintModule4Note.sol";
import "../ModuleBase.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title ApprovalMintModule
 * @notice This is a simple MintModule implementation, inheriting from the IMintModule4Note interface.
 */
contract ApprovalMintModule is IMintModule4Note, ModuleBase {
    // characterId => noteId => address => isApproved
    mapping(uint256 => mapping(uint256 => mapping(address => bool)))
        internal _approvedByCharacterByNoteByOwner;
    error ErrNotCharacterOwner();
    error ErrInvalidParams();
    error ErrNotApproved();

    // solhint-disable-next-line no-empty-blocks
    constructor(address web3Entry_) ModuleBase(web3Entry_) {}

    function initializeMintModule(
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external override onlyWeb3Entry returns (bytes memory) {
        // address owner = IERC721(web3Entry).ownerOf(characterId);

        if (data.length > 0) {
            address[] memory addresses = abi.decode(data, (address[]));
            uint256 addressesLength = addresses.length;
            for (uint256 i = 0; i < addressesLength; ) {
                _approvedByCharacterByNoteByOwner[characterId][noteId][addresses[i]] = true;
                unchecked {
                    ++i;
                }
            }
        }
        return data;
    }

    /**
     * @notice The owner of specified note can call this function,
     * to approve accounts to mint specified note.
     * @param characterId ID of character.
     * @param noteId ID of note.
     * @param addresses Address to set.
     * @param toApprove To approve or revoke.
     */
    // solhint-disable-next-line comprehensive-interface
    function approve(
        uint256 characterId,
        uint256 noteId,
        address[] calldata addresses,
        bool[] calldata toApprove
    ) external {
        // msg.sender should be the character owner
        address owner = IERC721(web3Entry).ownerOf(characterId);
        if (msg.sender != owner) revert ErrNotCharacterOwner();

        // check Params
        if (addresses.length != toApprove.length) revert ErrInvalidParams();

        uint256 addressesLength = addresses.length;
        for (uint256 i = 0; i < addressesLength; ) {
            _approvedByCharacterByNoteByOwner[characterId][noteId][addresses[i]] = toApprove[i];
            unchecked {
                ++i;
            }
        }
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
        if (_approvedByCharacterByNoteByOwner[characterId][noteId][to] != true)
            revert ErrNotApproved();
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
}
