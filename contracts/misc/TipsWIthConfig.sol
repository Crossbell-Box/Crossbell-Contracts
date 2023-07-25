// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {ITipsWithConfig} from "../interfaces/ITipsWithConfig.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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
    using SafeERC20 for IERC20;

    // structs
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
    }

    // slither-disable-start naming-convention
    // address of web3Entry
    address internal _web3Entry;

    uint256 internal _tipsConfigIndex;
    mapping(uint256 tipsConfigId => TipsConfig tipsConfig) internal _tipsConfigs;
    mapping(uint256 fromCharacterId => mapping(uint256 toCharacterId => uint256 tipsConfigId))
        internal _tipsConfigIds;
    // slither-disable-end naming-convention

    // events
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
        uint256 tipTimes
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
        uint256 redeemedAmount,
        uint256 fee,
        address feeReceiver
    );

    /**
     * @notice Initialize the contract, setting web3Entry address and token address.
     * @param web3Entry_ Address of web3Entry.
     */
    function initialize(address web3Entry_) external override initializer {
        _web3Entry = web3Entry_;
    }

    /// @inheritdoc ITipsWithConfig
    function setTipsConfig4Character(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount,
        uint256 interval,
        uint256 expiration
    ) external override {
        require(interval > 0, "TipsWithConfig: interval must be greater than 0");
        uint256 tipConfigId = _tipsConfigIds[fromCharacterId][toCharacterId];
        TipsConfig storage config = _tipsConfigs[tipConfigId];

        if (tipConfigId == 0) {
            // if tipConfigId is 0, create a new config
            _tipsConfigIndex++;
            config.id = _tipsConfigIndex;
            config.fromCharacterId = fromCharacterId;
            config.toCharacterId = toCharacterId;
            _tipsConfigIds[fromCharacterId][toCharacterId] = config.id;
        } else {
            // if tipConfigId is not 0, update the config
            config.token = token;
            config.amount = amount;
            config.expiration = expiration;
            config.interval = interval;

            if (config.redeemedTimes < config.tipTimes) {
                (, uint256 unRedeemedAmount) = _redeemTips4Character(
                    tipConfigId,
                    config.fromCharacterId,
                    config.toCharacterId
                );

                emit TriggerTips4Character(
                    config.id,
                    config.fromCharacterId,
                    config.toCharacterId,
                    config.token,
                    config.amount,
                    unRedeemedAmount,
                    0,
                    address(0)
                );
            }
        }

        config.startTime = block.timestamp;
        config.redeemedTimes = 0;
        // approve the total tip amount of  token to this contract
        config.tipTimes = _calculateTipTimes(config.startTime, config.expiration, config.interval);

        _tipsConfigs[config.id] = config;

        emit SetTipsConfig4Character(
            config.id,
            config.fromCharacterId,
            config.toCharacterId,
            config.token,
            config.amount,
            config.startTime,
            config.expiration,
            config.interval,
            config.tipTimes
        );
    }

    /// @inheritdoc ITipsWithConfig
    function triggerTips4Character(uint256 tipConfigId) external override {
        TipsConfig storage config = _tipsConfigs[tipConfigId];

        require(config.redeemedTimes < config.tipTimes, "TipsWithConfig: all tips redeemed");

        (uint256 availableTipTimes, uint256 unRedeemedAmount) = _redeemTips4Character(
            tipConfigId,
            config.fromCharacterId,
            config.toCharacterId
        );

        // update redeemedTimes
        _tipsConfigs[tipConfigId].redeemedTimes = availableTipTimes;

        emit TriggerTips4Character(
            config.id,
            config.fromCharacterId,
            config.toCharacterId,
            config.token,
            config.amount,
            unRedeemedAmount,
            0,
            address(0)
        );
    }

    /// @inheritdoc ITipsWithConfig
    function getTipsConfigId(
        uint256 fromCharacterId,
        uint256 toCharacterId
    ) external view returns (uint256 tipConfigId) {
        return _tipsConfigIds[fromCharacterId][toCharacterId];
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
    function getWeb3Entry() external view override returns (address) {
        return _web3Entry;
    }

    function _redeemTips4Character(
        uint256 tipConfigId,
        uint256 fromCharacterId,
        uint256 toCharacterId
    ) internal returns (uint256 availableTipTimes, uint256 unRedeemedAmount) {
        address token;
        (token, availableTipTimes, unRedeemedAmount) = _calculateUnredeemedTimesAndAmount(
            tipConfigId
        );

        // send token
        address from = IERC721(_web3Entry).ownerOf(fromCharacterId);
        address to = IERC721(_web3Entry).ownerOf(toCharacterId);
        IERC20(token).safeTransferFrom(from, to, unRedeemedAmount);

        return (availableTipTimes, unRedeemedAmount);
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
        TipsConfig storage config = _tipsConfigs[tipConfigId];
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
    ) internal view returns (address, uint256, uint256) {
        TipsConfig storage config = _tipsConfigs[tipConfigId];
        uint256 elapsed = block.timestamp - config.startTime;

        uint256 cycles = elapsed / config.interval;

        // When user tip for a character, instant count once
        uint256 availableTipTimes = cycles + 1;

        if (availableTipTimes > config.tipTimes) {
            availableTipTimes = config.tipTimes;
        }

        uint256 unredeemedTimes = availableTipTimes - config.redeemedTimes;
        return (config.token, availableTipTimes, unredeemedTimes * config.amount);
    }

    function _calculateTipTimes(
        uint256 startTime,
        uint256 expireTime,
        uint256 interval
    ) internal pure returns (uint256) {
        uint256 intervals = expireTime - startTime / interval;

        return intervals + 1;
    }
}
