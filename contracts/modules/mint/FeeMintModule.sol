// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {IMintModule4Note} from "../../interfaces/IMintModule4Note.sol";
import {ModuleBase} from "../ModuleBase.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev A struct containing associated data with each note.
 */
struct CharacterNoteData {
    uint256 amount;
    address token;
    address recipient;
}

/**
 * @title FeeMintModule
 * @notice This is a simple MintModule implementation, inheriting from the IMintModule4Note interface.
 */
contract FeeMintModule is IMintModule4Note, ModuleBase {
    using SafeERC20 for IERC20;

    mapping(uint256 => mapping(uint256 => CharacterNoteData)) internal _dataByNoteByCharacter;

    // solhint-disable-next-line no-empty-blocks
    constructor(address web3Entry_) ModuleBase(web3Entry_) {}

    function initializeMintModule(uint256 characterId, uint256 noteId, bytes calldata data)
        external
        override
        onlyWeb3Entry
        returns (bytes memory)
    {
        (uint256 amount, address token, address recipient) = abi.decode(data, (uint256, address, address));
        require(recipient != address(0) && amount > 0, "FeeMintModule: InvalidParams");

        _dataByNoteByCharacter[characterId][noteId].amount = amount;
        _dataByNoteByCharacter[characterId][noteId].token = token;
        _dataByNoteByCharacter[characterId][noteId].recipient = recipient;

        return data;
    }

    /**
     * @notice Processes the mint logic by charging a fee.
     * Triggered when the `mintNote` of web3Entry  is called, if mint module of note if set.
     * @param characterId ID of character.
     * @param noteId ID of note.
     * @param data The mintModuleData passed by user who called the `mintNote` of web3Entry .
     */
    function processMint(address to, uint256 characterId, uint256 noteId, bytes calldata data)
        external
        override
        onlyWeb3Entry
    {
        uint256 amount = _dataByNoteByCharacter[characterId][noteId].amount;
        address token = _dataByNoteByCharacter[characterId][noteId].token;

        (address decodedCurrency, uint256 decodedAmount) = abi.decode(data, (address, uint256));
        require(decodedAmount == amount && decodedCurrency == token, "FeeMintModule: ModuleDataMismatch");

        address recipient = _dataByNoteByCharacter[characterId][noteId].recipient;
        /// @dev onlyWeb3Entry can call `processMint`
        // slither-disable-next-line arbitrary-send-erc20
        IERC20(token).safeTransferFrom(to, recipient, amount);
    }

    /**
     * @notice Returns the associated data for a given note.
     * @param characterId ID of character to query.
     * @param noteId  ID of note to query.
     * @return Returns the associated data for a given  note.
     */
    // solhint-disable-next-line comprehensive-interface
    function getNoteData(uint256 characterId, uint256 noteId) external view returns (CharacterNoteData memory) {
        return _dataByNoteByCharacter[characterId][noteId];
    }
}
