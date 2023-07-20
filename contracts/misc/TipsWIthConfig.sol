// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {ITipsWithConfig} from "../interfaces/ITipsWithConfig.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC777} from "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import {IERC777Recipient} from "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import {IERC1820Registry} from "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @title TipsWithConfig
 * @notice Logic to handle the periodical tips that user can send to character periodically.
 * @dev User can set config for a specific tip with config, and any one can trigger the tip with config id.
 *
 * For `setTipsConfig4Character`
 * User can set the tips config for a specific tip with config id, from character id, to character id,
 *  token address, amount, interval and expiration. <br>
 *
 * For `triggerTips4Character`
 * Anyone can trigger the tip with config id, and it will transfer all unredeemed token from the from character
 *  to the to character.
 */
contract TipsWithConfig is ITipsWithConfig, Initializable {
    struct TipsConfig {
        uint256 id;
        uint256 fromCharacterId;
        uint256 toCharacterId;
        address token;
        uint256 amount;
        uint256 startTime;
        uint256 expiration;
        uint256 interval;
        uint256 tipTimes;
        uint256 redeemedTimes;
        uint256 totalApprovedAmount;
    }

    IERC1820Registry public constant ERC1820_REGISTRY =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 public constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    // slither-disable-start naming-convention
    // address of web3Entry
    address internal _web3Entry;
    address internal _token; // mira token, erc777 standard
    address internal _tips; // tips contract
    // address => feeFraction
    mapping(address => uint256) internal _feeFractions;
    // address => character => feeFraction
    mapping(address => mapping(uint256 => uint256)) internal _feeFractions4Character;
    // address => character => note => feeFraction
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) internal _feeFractions4Note;
    // slither-disable-end naming-convention

    uint256 public tipsConfigIndex;
    mapping(address => uint256) public authorizedAmount;
    mapping(uint256 => TipsConfig) public tipsConfigs;

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
     * @dev Emitted when a user set a tip with periodical config.
     * @param tipConfigId The tip config id.
     * @param fromCharacterId The token ID of character that initiated a reward.
     * @param toCharacterId The token ID of character that.
     * @param token Address of token to reward.
     * @param amount Amount of token to reward.
     * @param interval Interval of the tip.
     * @param expiration Expiration of the tip.
     */
    event SetTipsConfig4Character(
        uint256 indexed tipConfigId,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 startTime,
        uint256 expiration,
        uint256 interval,
        uint256 tipTimes,
        uint256 redeemedTimes,
        uint256 totalApprovedAmount
    );

    /**
     * @dev Emitted when a user trigger a tip with periodical config.
     * @param tipConfigId The tip config id.
     * @param fromCharacterId The token ID of character that initiated a reward.
     * @param toCharacterId The token ID of character that.
     * @param token Address of token to reward.
     * @param amount Amount of token to reward.
     * @param redeemedAmount Actual amount of token to reward.
     */
    event TriggerTips4Character(
        uint256 indexed tipConfigId,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 redeemedAmount
    );

    /**
     * @notice Initialize the contract, setting web3Entry address and token address.
     * @param web3Entry_ Address of web3Entry.
     * @param token_ Address of token.
     * @param tips_ Address of tips.
     */
    function initialize(
        address web3Entry_,
        address token_,
        address tips_
    ) external override initializer {
        _web3Entry = web3Entry_;
        _token = token_;
        _tips = tips_;

        // register interfaces
        ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }

    /// @inheritdoc ITipsWithConfig
    function setTipsConfig4Character(
        uint256 tipConfigId,
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount,
        uint256 interval,
        uint256 expiration
    ) external override {
        TipsConfig memory config;

        if (tipConfigId == 0) {
            // if tipConfigId is 0, create a new config
            tipsConfigIndex++;
            config.id = tipsConfigIndex;
            config.fromCharacterId = fromCharacterId;
            config.toCharacterId = toCharacterId;
            config.startTime = block.timestamp;
            config.redeemedTimes = 0;
        } else {
            // if tipConfigId is not 0, update the config
            require(
                tipsConfigs[tipConfigId].id == tipConfigId,
                "TipsWithConfig: invalid tip config id"
            );
            config.token = token;
            config.amount = amount;
            config.expiration = expiration;
            config.interval = interval;
        }

        // approve the total tip amount of  token to this contract
        config.tipTimes = _calculateTipTimes(config.startTime, config.expiration, config.interval);
        config.totalApprovedAmount = amount * config.tipTimes;
        _authorizeOperatorWithAmount(config.totalApprovedAmount);

        emit SetTipsConfig4Character(
            config.id,
            config.fromCharacterId,
            config.toCharacterId,
            config.token,
            config.amount,
            config.startTime,
            config.expiration,
            config.interval,
            config.tipTimes,
            config.redeemedTimes,
            config.totalApprovedAmount
        );
    }

    /// @inheritdoc ITipsWithConfig
    function triggerTips4Character(uint256 tipConfigId) external override {
        TipsConfig memory config = tipsConfigs[tipConfigId];

        require(config.redeemedTimes < config.tipTimes, "TipsWithConfig: all tips redeemed");

        // prepare tipCharacter `data` for `Tips` contract's `tokensReceived` callback method
        bytes memory data = abi.encode(config.fromCharacterId, config.toCharacterId);

        (uint256 availableTipTimes, uint256 unRedeemedAmount) = _calculateUnredeemedTimesAndAmount(
            tipConfigId
        );
        (tipConfigId);

        // send token
        IERC777(_token).operatorSend(
            IERC721(_web3Entry).ownerOf(config.fromCharacterId),
            IERC721(_web3Entry).ownerOf(config.toCharacterId),
            unRedeemedAmount,
            data,
            ""
        );

        // update redeemedTimes
        tipsConfigs[tipConfigId].redeemedTimes = availableTipTimes;

        emit TriggerTips4Character(
            config.id,
            config.fromCharacterId,
            config.toCharacterId,
            config.token,
            config.amount,
            unRedeemedAmount
        );
    }

    /// @inheritdoc ITipsWithConfig
    function getTipsConfig(
        uint256 tipConfigId
    )
        external
        view
        override
        returns (
            uint256 fromCharacterId,
            uint256 toCharacterId,
            address token,
            uint256 amount,
            uint256 interval,
            uint256 expiration
        )
    {
        return _getTipsConfig(tipConfigId);
    }

    /// @inheritdoc ITipsWithConfig
    function getAuthorizedAmount() external view returns (uint256) {
        return authorizedAmount[address(this)];
    }

    /// @inheritdoc ITipsWithConfig
    function getWeb3Entry() external view override returns (address) {
        return _web3Entry;
    }

    /// @inheritdoc ITipsWithConfig
    function getToken() external view override returns (address) {
        return _token;
    }

    function _authorizeOperatorWithAmount(uint256 amount) internal {
        IERC777(_token).authorizeOperator(address(this));
        authorizedAmount[address(this)] = amount;
    }

    function _getTipsConfig(
        uint256 tipConfigId
    )
        internal
        view
        returns (
            uint256 fromCharacterId,
            uint256 toCharacterId,
            address token,
            uint256 amount,
            uint256 interval,
            uint256 expiration
        )
    {
        TipsConfig memory config = tipsConfigs[tipConfigId];
        return (
            config.fromCharacterId,
            config.toCharacterId,
            config.token,
            config.amount,
            config.interval,
            config.expiration
        );
    }

    function _calculateUnredeemedTimesAndAmount(
        uint256 tipConfigId
    ) internal view returns (uint256, uint256) {
        TipsConfig memory config = tipsConfigs[tipConfigId];
        uint256 elapsed = block.timestamp - config.startTime;

        uint256 cycles = elapsed / config.interval;

        uint256 availableTipTimes = cycles + 1;

        if (availableTipTimes > config.tipTimes) {
            availableTipTimes = config.tipTimes;
        }

        uint256 unredeemedTimes = availableTipTimes - config.redeemedTimes;
        return (availableTipTimes, unredeemedTimes * config.amount);
    }

    function _calculateTipTimes(
        uint256 startTime,
        uint256 expireTime,
        uint256 interval
    ) internal pure returns (uint256) {
        uint256 totalInterval = expireTime - startTime;

        if (interval == 0) {
            return 0;
        }

        uint256 intervals = totalInterval / interval;

        return intervals + 1;
    }
}
