// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @title Tips
 * @dev Logic to handle rewards that user can send to character and note.
 */
contract Tips is Initializable {
    using SafeERC20 for IERC20;

    //address of web3Entry
    address public web3Entry;

    // custom errors
    error ErrCallerNotCharacterOwner();

    // events
    /**
     * @dev Emitted when the assets are rewarded to a character.
     * @param fromCharacterId The token ID of character that initiated a reward.
     * @param toCharacterId The token ID of character that.
     * @param token Address of token to reward.
     * @param amount Amount of token to reward.
     */
    event TipCharacter(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount
    );
    /**
     * @dev Emitted when the assets are rewarded to a note.
     * @param fromCharacterId The token ID of character that calls this contract.
     * @param toCharacterId The token ID of character that will receive the token.
     * @param toNoteId The note ID.
     * @param token Address of token.
     * @param amount Amount of token.
     */
    event TipCharacterForNote(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        uint256 indexed toNoteId,
        address token,
        uint256 amount
    );

    /**
     * @notice Initialize the contract.
     * @param web3Entry_ Address of web3Entry.
     */
    function initialize(address web3Entry_) external initializer {
        web3Entry = web3Entry_;
    }

    /**
     * @notice Tips a character by transferring `amount` tokens
     * from the `fromCharacterId` account to `toCharacterId` account.
     * Emits the `ThankCharacter` event.
     *
     * Requirements:
     * - The caller must be the character owner of `fromCharacterId.
     * @param fromCharacterId The token ID of character that calls this contract.
     * @param toCharacterId The token ID of character that will receive the token.
     * @param token Address of token.
     * @param amount Amount of token.
     */
    function tipCharacter(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount
    ) external {
        // check
        address characterOwner = IERC721(web3Entry).ownerOf(fromCharacterId);
        if (msg.sender != characterOwner) revert ErrCallerNotCharacterOwner();

        // transfer token
        address to = IERC721(web3Entry).ownerOf(toCharacterId);
        IERC20(token).safeTransferFrom(msg.sender, to, amount);

        // emit event
        emit TipCharacter(fromCharacterId, toCharacterId, token, amount);
    }

    /**
     * @notice Tips a character's note by transferring `amount` tokens
     * from the `fromCharacterId` account to `toCharacterId` account.
     * Emits the `ThankNote` event.
     *
     * Requirements:
     * - The caller must be the character owner of `fromCharacterId.
     * @param fromCharacterId The token ID of character that calls this contract.
     * @param toCharacterId The token ID of character that will receive the token.
     * @param toNoteId The note ID.
     * @param token Address of token.
     * @param amount Amount of token.
     */
    function tipCharacterForNote(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        uint256 toNoteId,
        address token,
        uint256 amount
    ) external {
        // check
        address characterOwner = IERC721(web3Entry).ownerOf(fromCharacterId);
        if (msg.sender != characterOwner) revert ErrCallerNotCharacterOwner();

        // transfer token
        address to = IERC721(web3Entry).ownerOf(toCharacterId);
        IERC20(token).safeTransferFrom(msg.sender, to, amount);

        // emit event
        emit TipCharacterForNote(fromCharacterId, toCharacterId, toNoteId, token, amount);
    }
}
