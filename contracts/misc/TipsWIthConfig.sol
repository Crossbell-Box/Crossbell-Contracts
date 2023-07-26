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
        uint256 endTime;
        uint256 interval;
        uint256 tipsTimes;
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
     * @param startTime The start time of tip.
     * @param endTime The end time of tip.
     * @param interval Interval of the tip.
     * @param tipTimes Tip times of the tip.
     */
    event SetTipsConfig4Character(
        uint256 indexed tipConfigId,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 startTime,
        uint256 endTime,
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

    // solhint-disable-next-line function-max-lines
    /// @inheritdoc ITipsWithConfig
    function setTipsConfig4Character(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount,
        uint256 startTime,
        uint256 endTime,
        uint256 interval
    ) external override {
        require(
            msg.sender == IERC721(_web3Entry).ownerOf(fromCharacterId),
            "TipsWithConfig: not character owner"
        );
        require(startTime >= block.timestamp, "TipsWithConfig: invalid startTime");
        require(interval > 0, "TipsWithConfig: interval must be greater than 0");
        require(endTime >= startTime + interval, "TipsWithConfig: invalid endTime");

        uint256 tipConfigId = _getTipsConfigId(fromCharacterId, toCharacterId);
        TipsConfig storage config = _tipsConfigs[tipConfigId];
        if (tipConfigId > 0) {
            // if tipConfigId is not 0, try to trigger tips first
            (, uint256 availableAmount) = _redeemTips4Character(
                tipConfigId,
                config.fromCharacterId,
                config.toCharacterId
            );

            if (availableAmount > 0) {
                emit TriggerTips4Character(
                    config.id,
                    config.fromCharacterId,
                    config.toCharacterId,
                    config.token,
                    config.amount,
                    availableAmount,
                    0,
                    address(0)
                );
            }
        } else {
            tipConfigId = ++_tipsConfigIndex;
            config = _tipsConfigs[tipConfigId];
            _tipsConfigIds[fromCharacterId][toCharacterId] = tipConfigId;
        }

        // update tips config
        config.id = tipConfigId;
        config.fromCharacterId = fromCharacterId;
        config.toCharacterId = toCharacterId;
        config.token = token;
        config.amount = amount;
        config.startTime = startTime;
        config.endTime = endTime;
        config.interval = interval;
        config.redeemedTimes = 0;
        config.tipsTimes = _calculateTipTimes(startTime, endTime, interval);

        emit SetTipsConfig4Character(
            config.id,
            config.fromCharacterId,
            config.toCharacterId,
            config.token,
            config.amount,
            config.startTime,
            config.endTime,
            config.interval,
            config.tipsTimes
        );
    }

    /// @inheritdoc ITipsWithConfig
    function triggerTips4Character(uint256 tipConfigId) external override {
        TipsConfig storage config = _tipsConfigs[tipConfigId];

        require(config.redeemedTimes < config.tipsTimes, "TipsWithConfig: all tips redeemed");

        (uint256 availableTipTimes, uint256 availableAmount) = _redeemTips4Character(
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
            availableAmount,
            0,
            address(0)
        );
    }

    /// @inheritdoc ITipsWithConfig
    function getTipsConfigId(
        uint256 fromCharacterId,
        uint256 toCharacterId
    ) external view returns (uint256) {
        return _getTipsConfigId(fromCharacterId, toCharacterId);
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
    ) internal returns (uint256 availableTipTimes, uint256 availableAmount) {
        address token;
        (token, availableTipTimes, availableAmount) = _calculateAvailableTimesAndAmount(
            tipConfigId
        );

        if (availableAmount > 0) {
            // send token
            address from = IERC721(_web3Entry).ownerOf(fromCharacterId);
            address to = IERC721(_web3Entry).ownerOf(toCharacterId);
            // slither-disable-next-line arbitrary-send-erc20
            IERC20(token).safeTransferFrom(from, to, availableAmount);
        }
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
            config.endTime
        );
    }

    function _getTipsConfigId(
        uint256 fromCharacterId,
        uint256 toCharacterId
    ) internal view returns (uint256) {
        return _tipsConfigIds[fromCharacterId][toCharacterId];
    }

    function _calculateAvailableTimesAndAmount(
        uint256 tipConfigId
    ) internal view returns (address, uint256, uint256) {
        TipsConfig storage config = _tipsConfigs[tipConfigId];
        uint256 availableTipTimes = _calculateTipTimes(
            config.startTime,
            block.timestamp,
            config.interval
        );

        if (availableTipTimes > config.tipsTimes) {
            availableTipTimes = config.tipsTimes;
        }

        uint256 unredeemedTimes = availableTipTimes - config.redeemedTimes;
        return (config.token, availableTipTimes, unredeemedTimes * config.amount);
    }

    function _calculateTipTimes(
        uint256 startTime,
        uint256 endTime,
        uint256 interval
    ) internal view returns (uint256) {
        // why add 1 here: when user tips for a character, instant count once
        return (endTime - startTime) / interval + 1;
    }
}
