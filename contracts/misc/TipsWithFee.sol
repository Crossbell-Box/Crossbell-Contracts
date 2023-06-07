// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {ITipsWithFee} from "../interfaces/ITipsWithFee.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC777} from "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import {IERC777Recipient} from "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import {IERC1820Registry} from "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @title Tips
 * @dev Logic to handle rewards that user can send to character and note.
 */
contract TipsWithFee is ITipsWithFee, Initializable, IERC777Recipient {
    IERC1820Registry public constant ERC1820_REGISTRY =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 public constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    // slither-disable-start naming-convention
    // address of web3Entry
    address internal _web3Entry;
    address internal _token; // mira token, erc777 standard
    // address => feeFraction
    mapping(address => uint256) internal _feeFractions;
    // address => character => feeFraction
    mapping(address => mapping(uint256 => uint256)) internal _feeFractions4Character;
    // address => character => note => feeFraction
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) internal _feeFractions4Note;
    // slither-disable-end naming-convention

    // events
    /**
     * @dev Emitted when the assets are rewarded to a character.
     * @param fromCharacterId The token ID of character that initiated a reward.
     * @param toCharacterId The token ID of character that.
     * @param token Address of token to reward.
     * @param amount Amount of token to reward.
     * @param fee Amount of fee.
     * @param feeReceiver Fee receiver address.
     */
    event TipCharacter(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 fee,
        address feeReceiver
    );

    /**
     * @dev Emitted when the assets are rewarded to a note.
     * @param fromCharacterId The token ID of character that calls this contract.
     * @param toCharacterId The token ID of character that will receive the token.
     * @param toNoteId The note ID.
     * @param token Address of token.
     * @param amount Amount of token.
     * @param fee Amount of fee.
     * @param feeReceiver Fee receiver address.
     */
    event TipCharacterForNote(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        uint256 indexed toNoteId,
        address token,
        uint256 amount,
        uint256 fee,
        address feeReceiver
    );

    // custom errors
    error ErrCallerNotCharacterOwner();
    error ErrCallerNotOwner();
    error ErrOutOfRange();

    /**
     * @notice Initialize the contract, setting web3Entry address and token address.
     * @param web3Entry_ Address of web3Entry.
     * @param token_ Address of token.
     */
    function initialize(address web3Entry_, address token_) external override initializer {
        _web3Entry = web3Entry_;
        _token = token_;

        // register interfaces
        ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }

    /// @inheritdoc ITipsWithFee
    function setDefaultFeeFraction(address receiver, uint256 fraction) external override {
        if (receiver != msg.sender) revert ErrCallerNotOwner();
        if (fraction > _feeDenominator()) revert ErrOutOfRange();

        _feeFractions[receiver] = fraction;
    }

    /// @inheritdoc ITipsWithFee
    function setFeeFraction4Character(
        address receiver,
        uint256 characterId,
        uint256 fraction
    ) external override {
        if (receiver != msg.sender) revert ErrCallerNotOwner();
        if (fraction > _feeDenominator()) revert ErrOutOfRange();

        _feeFractions4Character[receiver][characterId] = fraction;
    }

    /// @inheritdoc ITipsWithFee
    function setFeeFraction4Note(
        address receiver,
        uint256 characterId,
        uint256 noteId,
        uint256 fraction
    ) external override {
        if (receiver != msg.sender) revert ErrCallerNotOwner();
        if (fraction > _feeDenominator()) revert ErrOutOfRange();

        _feeFractions4Note[receiver][characterId][noteId] = fraction;
    }

    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account `to` (this contract). <br>
     *
     * The userData/operatorData should be an abi encoded bytes of `fromCharacterId`, `toCharacter`
     * and `toNoteId`(optional) and `receiver`(platform account), so the length of data is 84 or 116.
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
        // slither-disable-start uninitialized-local
        // abi encoded bytes of (fromCharacterId, toCharacter, receiver)
        if (data.length == 84) {
            // tip character
            // slither-disable-next-line variable-scope
            (uint256 fromCharacterId, uint256 toCharacterId, address receiver) = abi.decode(
                data,
                (uint256, uint256, address)
            );
            _tipCharacter(from, fromCharacterId, toCharacterId, _token, amount, receiver);
            // abi encoded bytes of (fromCharacterId, toCharacter, noteId, receiver)
        } else if (data.length == 116) {
            // tip character for note
            // slither-disable-next-line variable-scope
            (
                uint256 fromCharacterId,
                uint256 toCharacterId,
                uint256 toNoteId,
                address receiver
            ) = abi.decode(data, (uint256, uint256, uint256, address));
            _tipCharacterForNote(
                from,
                fromCharacterId,
                toCharacterId,
                toNoteId,
                _token,
                amount,
                receiver
            );
        } else {
            revert("Tips: unknown receiving");
        }
        //slither-disable-end uninitialized-local
    }

    /// @inheritdoc ITipsWithFee
    function getWeb3Entry() external view override returns (address) {
        return _web3Entry;
    }

    /// @inheritdoc ITipsWithFee
    function getToken() external view override returns (address) {
        return _token;
    }

    /// @inheritdoc ITipsWithFee
    function getFeeFraction(
        address receiver,
        uint256 characterId,
        uint256 noteId
    ) external view override returns (uint256) {
        return _getFeeFraction(receiver, characterId, noteId);
    }

    /// @inheritdoc ITipsWithFee
    function getFeeAmount(
        address receiver,
        uint256 characterId,
        uint256 noteId,
        uint256 tipAmount
    ) external view override returns (uint256) {
        return _getFeeAmount(receiver, characterId, noteId, tipAmount);
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
     * @param feeReceiver Fee receiver address.
     */
    function _tipCharacter(
        address from,
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount,
        address feeReceiver
    ) internal {
        // check and send token
        uint256 feeAmount = _getFeeAmount(feeReceiver, toCharacterId, 0, amount);
        _sendToken(from, fromCharacterId, toCharacterId, token, amount, feeAmount, feeReceiver);

        // emit event
        emit TipCharacter(fromCharacterId, toCharacterId, _token, amount, feeAmount, feeReceiver);
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
     * @param feeReceiver Fee receiver address.
     */
    function _tipCharacterForNote(
        address from,
        uint256 fromCharacterId,
        uint256 toCharacterId,
        uint256 toNoteId,
        address token,
        uint256 amount,
        address feeReceiver
    ) internal {
        // check and send token
        uint256 feeAmount = _getFeeAmount(feeReceiver, toCharacterId, toNoteId, amount);
        _sendToken(from, fromCharacterId, toCharacterId, token, amount, feeAmount, feeReceiver);

        // emit event
        emit TipCharacterForNote(
            fromCharacterId,
            toCharacterId,
            toNoteId,
            token,
            amount,
            feeAmount,
            feeReceiver
        );
    }

    function _sendToken(
        address from,
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount,
        uint256 feeAmount,
        address feeReceiver
    ) internal {
        // `from` must be the owner of fromCharacterId
        if (from != IERC721(_web3Entry).ownerOf(fromCharacterId))
            revert ErrCallerNotCharacterOwner();

        // send token to `toCharacterId` account
        bytes memory userData = abi.encode(fromCharacterId, toCharacterId);
        // solhint-disable-next-line check-send-result
        IERC777(token).send(
            IERC721(_web3Entry).ownerOf(toCharacterId),
            amount - feeAmount,
            userData
        );
        // solhint-disable-next-line check-send-result
        IERC777(token).send(feeReceiver, feeAmount, userData);
    }

    function _getFeeFraction(
        address receiver,
        uint256 characterId,
        uint256 noteId
    ) internal view returns (uint256) {
        uint256 fraction = _feeFractions4Note[receiver][characterId][noteId];
        fraction = fraction > 0 ? fraction : _feeFractions4Character[receiver][characterId];
        fraction = fraction > 0 ? fraction : _feeFractions[receiver];

        return fraction;
    }

    function _getFeeAmount(
        address receiver,
        uint256 characterId,
        uint256 noteId,
        uint256 tipAmount
    ) internal view returns (uint256) {
        uint256 fraction = _getFeeFraction(receiver, characterId, noteId);
        uint256 feeAmount = (tipAmount * fraction) / _feeDenominator();
        return feeAmount;
    }

    /**
     * @dev Defaults to 10000 so fees are expressed in basis points.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }
}
