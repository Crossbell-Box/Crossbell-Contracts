// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {ITipsWithConfig} from "../interfaces/ITipsWithConfig.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

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
contract TipsWithConfig is ITipsWithConfig, Initializable, ReentrancyGuard {
    using SafeERC20 for IERC20;

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
     * @param totalRound Total round of the tip.
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
        uint256 totalRound
    );

    /**
     * @dev Emitted when a user trigger a tip with periodical config.
     * @param tipConfigId The tip config id.
     * @param fromCharacterId The token ID of character that initiated a reward.
     * @param toCharacterId The token ID of character that.
     * @param token Address of token to reward.
     * @param amount Actual amount of token to reward.
     * @param fee The amount of fee.
     * @param feeReceiver The fee receiver address.
     * @param currentRound The current round of tip.
     */
    event TriggerTips4Character(
        uint256 indexed tipConfigId,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 fee,
        address feeReceiver,
        uint256 currentRound
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
        uint256 startTime,
        uint256 endTime,
        uint256 interval
    ) external override nonReentrant {
        require(
            msg.sender == IERC721(_web3Entry).ownerOf(fromCharacterId),
            "TipsWithConfig: not character owner"
        );
        require(startTime >= block.timestamp, "TipsWithConfig: invalid startTime");
        require(interval > 0, "TipsWithConfig: interval must be greater than 0");
        require(endTime >= startTime + interval, "TipsWithConfig: invalid endTime");

        uint256 tipConfigId = _getTipsConfigId(fromCharacterId, toCharacterId);
        if (tipConfigId > 0) {
            // if tipConfigId is not 0, try to trigger tips first
            _triggerTips4Character(_tipsConfigs[tipConfigId]);
        } else {
            tipConfigId = ++_tipsConfigIndex;
            _tipsConfigIds[fromCharacterId][toCharacterId] = tipConfigId;
        }

        uint256 totalRound = _getTipRound(startTime, endTime, interval);
        // update tips config
        _tipsConfigs[tipConfigId] = TipsConfig({
            id: tipConfigId,
            fromCharacterId: fromCharacterId,
            toCharacterId: toCharacterId,
            token: token,
            amount: amount,
            startTime: startTime,
            endTime: endTime,
            interval: interval,
            currentRound: 0,
            totalRound: totalRound
        });

        emit SetTipsConfig4Character(
            tipConfigId,
            fromCharacterId,
            toCharacterId,
            token,
            amount,
            startTime,
            endTime,
            interval,
            totalRound
        );
    }

    /// @inheritdoc ITipsWithConfig
    function triggerTips4Character(uint256 tipConfigId) external override nonReentrant {
        TipsConfig storage config = _tipsConfigs[tipConfigId];

        require(block.timestamp >= config.startTime, "TipsWithConfig: start time not comes");

        // all the tips have been finished
        if (config.currentRound >= config.totalRound) {
            return;
        }

        // trigger tips
        (uint256 currentRound, ) = _triggerTips4Character(config);

        // update redeemedTimes
        _tipsConfigs[tipConfigId].currentRound = currentRound;
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
    ) external view override returns (TipsConfig memory config) {
        return _tipsConfigs[tipConfigId];
    }

    /// @inheritdoc ITipsWithConfig
    function getWeb3Entry() external view override returns (address) {
        return _web3Entry;
    }

    function _triggerTips4Character(TipsConfig memory config) internal returns (uint256, uint256) {
        (uint256 currentRound, uint256 availableAmount) = _getAvailableRoundAndAmount(config);

        if (availableAmount > 0) {
            // send token
            address from = IERC721(_web3Entry).ownerOf(config.fromCharacterId);
            address to = IERC721(_web3Entry).ownerOf(config.toCharacterId);
            // slither-disable-next-line arbitrary-send-erc20
            IERC20(config.token).safeTransferFrom(from, to, availableAmount);

            emit TriggerTips4Character(
                config.id,
                config.fromCharacterId,
                config.toCharacterId,
                config.token,
                availableAmount,
                0,
                address(0),
                currentRound
            );
        }

        return (currentRound, availableAmount);
    }

    function _getTipsConfigId(
        uint256 fromCharacterId,
        uint256 toCharacterId
    ) internal view returns (uint256) {
        return _tipsConfigIds[fromCharacterId][toCharacterId];
    }

    function _getAvailableRoundAndAmount(
        TipsConfig memory config
    ) internal view returns (uint256, uint256) {
        uint256 currentRound = _getTipRound(config.startTime, block.timestamp, config.interval);

        if (currentRound > config.totalRound) {
            currentRound = config.totalRound;
        }

        return (currentRound, (currentRound - config.currentRound) * config.amount);
    }

    function _getTipRound(
        uint256 startTime,
        uint256 endTime,
        uint256 interval
    ) internal pure returns (uint256) {
        // why add 1 here: when user tips for a character, instant count once
        return (endTime - startTime) / interval + 1;
    }
}
