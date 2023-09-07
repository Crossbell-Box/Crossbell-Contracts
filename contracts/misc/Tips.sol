// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC777} from "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import {IERC777Recipient} from "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import {IERC1820Registry} from "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @title Tips
 * @dev Logic to handle rewards that user can send to character and note.
 */
contract Tips is Initializable, IERC777Recipient {
    IERC1820Registry public constant ERC1820_REGISTRY =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 public constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    // address of web3Entry
    address internal _web3Entry;
    address internal _token; // mira token, erc777 standard

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

    // custom errors
    error ErrCallerNotCharacterOwner();

    /**
     * @notice Initialize the contract, setting web3Entry address and token address.
     * @param web3Entry_ Address of web3Entry.
     * @param token_ Address of token.
     */
    function initialize(address web3Entry_, address token_) external initializer {
        _web3Entry = web3Entry_;
        _token = token_;

        // register interfaces
        ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }

    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account `to` (this contract). <br>
     *
     * The userData/operatorData should be an abi encoded bytes of `fromCharacterId`, `toCharacter`
     * and `toNoteId`(optional),  which are all uint256 type, so the length of data is 64 or 96.
     */
    /// @inheritdoc IERC777Recipient
    function tokensReceived(
        address,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override(IERC777Recipient) {
        require(msg.sender == _token, "Tips: invalid token");
        require(address(this) == to, "Tips: invalid receiver");

        bytes memory data = userData.length > 0 ? userData : operatorData;
        // abi encoded bytes of (fromCharacterId, toCharacter)
        if (data.length == 64) {
            // tip character
            (uint256 fromCharacterId, uint256 toCharacterId) = abi.decode(data, (uint256, uint256));
            _tipCharacter(from, fromCharacterId, toCharacterId, _token, amount);
            // abi encoded bytes of (fromCharacterId, toCharacter, noteId)
        } else if (data.length == 96) {
            // tip character for note
            (uint256 fromCharacterId, uint256 toCharacterId, uint256 toNoteId) = abi.decode(
                data,
                (uint256, uint256, uint256)
            );
            _tipCharacterForNote(from, fromCharacterId, toCharacterId, toNoteId, _token, amount);
        } else {
            revert("Tips: unknown receiving");
        }
    }

    /**
     * @notice Returns the address of web3Entry contract.
     * @return The address of web3Entry contract.
     */
    function getWeb3Entry() external view returns (address) {
        return _web3Entry;
    }

    /**
     * @notice Returns the address of mira token contract.
     * @return The address of mira token contract.
     */
    function getToken() external view returns (address) {
        return _token;
    }

    /**
     * @notice Tips a character by transferring `amount` tokens
     * from the `fromCharacterId` account to `toCharacterId` account. <br>
     *
     * Emits the `TipCharacter` event. <br>
     *
     * User should call `send` erc777 token to the Tips contract, with `fromCharacterId`
     * and `toCharacterId` encoded in the `data`. <br>
     * `send` interface is
     * [IERC777-send](https://docs.openzeppelin.com/contracts/2.x/api/token/erc777#IERC777-send-address-uint256-bytes-),
     * and parameters encode refers
     * [AbiCoder-encode](https://docs.ethers.org/v5/api/utils/abi/coder/#AbiCoder-encode).<br>
     *
     * <b> Requirements: </b>
     * - The `from` account must be the character owner of `fromCharacterId.
     * @param from The caller's account who sends token.
     * @param fromCharacterId The token ID of character that calls this contract.
     * @param toCharacterId The token ID of character that will receive the token.
     * @param token Address of token.
     * @param amount Amount of token.
     */
    function _tipCharacter(
        address from,
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount
    ) internal {
        // check and send token
        _sendToken(from, fromCharacterId, toCharacterId, token, amount);

        // emit event
        emit TipCharacter(fromCharacterId, toCharacterId, _token, amount);
    }

    /**
     * @notice Tips a character's note by transferring `amount` tokens
     * from the `fromCharacterId` account to `toCharacterId` account. <br>
     *
     * Emits the `TipCharacterForNote` event. <br>
     *
     * User should call `send` erc777 token to the Tips contract, with `fromCharacterId`,
     *  `toCharacterId` and `toNoteId` encoded in the `data`. <br>
     *
     * <b> Requirements: </b>
     * - The `from` account must be the character owner of `fromCharacterId.
     * @param from The caller's account who sends token.
     * @param fromCharacterId The token ID of character that calls this contract.
     * @param toCharacterId The token ID of character that will receive the token.
     * @param toNoteId The note ID.
     * @param token Address of token.
     * @param amount Amount of token.
     */
    function _tipCharacterForNote(
        address from,
        uint256 fromCharacterId,
        uint256 toCharacterId,
        uint256 toNoteId,
        address token,
        uint256 amount
    ) internal {
        // check and send token
        _sendToken(from, fromCharacterId, toCharacterId, token, amount);

        // emit event
        emit TipCharacterForNote(fromCharacterId, toCharacterId, toNoteId, token, amount);
    }

    function _sendToken(
        address from,
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount
    ) internal {
        // `from` must be the owner of fromCharacterId
        if (from != IERC721(_web3Entry).ownerOf(fromCharacterId))
            revert ErrCallerNotCharacterOwner();

        // send token to `toCharacterId` account
        bytes memory userData = abi.encode(fromCharacterId, toCharacterId);
        // solhint-disable-next-line check-send-result
        IERC777(token).send(IERC721(_web3Entry).ownerOf(toCharacterId), amount, userData);
    }
}
