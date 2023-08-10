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
 * @dev User can set config for a specific character, and anyone can collect the tip by config id.
 *
 * For `setTipsConfig4Character`
 * User can set the tips config for a specific character. <br>
 *
 * For `collectTips4Character`
 * Anyone can collect the tip by config id, and it will transfer all available tokens
 * from the `fromCharacterId` account to the `toCharacterId` account.
 */
contract TipsWithConfig is ITipsWithConfig, Initializable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // slither-disable-start naming-convention
    // address of web3Entry contract
    address internal _web3Entry;

    uint256 internal _tipsConfigIndex;
    mapping(uint256 tipsConfigId => TipsConfig tipsConfig) internal _tipsConfigs;
    mapping(uint256 fromCharacterId => mapping(uint256 toCharacterId => uint256 tipsConfigId))
        internal _tipsConfigIds;
    mapping(address feeReceiver => uint256 fraction) internal _feeFractions;
    mapping(address feeReceiver => mapping(uint256 characterId => uint256 fraction))
        internal _feeFractions4Character;
    // slither-disable-end naming-convention

    // events
    /**
     * @dev Emitted when a user set a tip with periodical config.
     * @param tipConfigId The tip config id.
     * @param fromCharacterId The token ID of character that initiated a reward.
     * @param toCharacterId The token ID of character that would receive the reward.
     * @param token Address of token to reward.
     * @param amount The amount of tokens to reward each round.
     * @param startTime The start time of tip.
     * @param endTime The end time of tip.
     * @param interval The interval of tip.
     * @param feeReceiver The fee receiver address.
     * @param totalRound The total round of tip.
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
        address feeReceiver,
        uint256 totalRound
    );

    /**
     * @dev Emitted when a user collect a tip with periodical config.
     * @param tipConfigId The tip config id.
     * @param fromCharacterId The token ID of character that initiated a reward.
     * @param toCharacterId The token ID of character that would receive the reward.
     * @param token Address of token to reward.
     * @param amount Actual amount of tokens to reward.
     * @param fee Actual amount of fee.
     * @param feeReceiver The fee receiver address.
     * @param currentRound The current round of tip.
     */
    event CollectTips4Character(
        uint256 indexed tipConfigId,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 fee,
        address feeReceiver,
        uint256 currentRound
    );

    modifier onlyFeeReceiver(address feeReceiver) {
        require(feeReceiver == msg.sender, "TipsWithConfig: caller is not fee receiver");
        _;
    }

    modifier validateFraction(uint256 fraction) {
        require(fraction <= _feeDenominator(), "TipsWithConfig: fraction out of range");
        _;
    }

    /// @inheritdoc ITipsWithConfig
    function initialize(address web3Entry_) external override initializer {
        _web3Entry = web3Entry_;
    }

    /// @inheritdoc ITipsWithConfig
    function setDefaultFeeFraction(
        address feeReceiver,
        uint256 fraction
    ) external override onlyFeeReceiver(feeReceiver) validateFraction(fraction) {
        _feeFractions[feeReceiver] = fraction;
    }

    /// @inheritdoc ITipsWithConfig
    function setFeeFraction4Character(
        address feeReceiver,
        uint256 characterId,
        uint256 fraction
    ) external override onlyFeeReceiver(feeReceiver) validateFraction(fraction) {
        _feeFractions4Character[feeReceiver][characterId] = fraction;
    }

    /// @inheritdoc ITipsWithConfig
    function setTipsConfig4Character(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount,
        uint256 startTime,
        uint256 endTime,
        uint256 interval,
        address feeReceiver
    ) external override {
        require(
            msg.sender == IERC721(_web3Entry).ownerOf(fromCharacterId),
            "TipsWithConfig: not character owner"
        );
        require(interval > 0, "TipsWithConfig: interval must be greater than 0");
        require(endTime >= startTime + interval, "TipsWithConfig: invalid endTime");

        uint256 tipConfigId = _getTipsConfigId(fromCharacterId, toCharacterId);
        if (tipConfigId > 0) {
            // if tipConfigId is not 0, try to collect tips first
            _collectTips4Character(tipConfigId);
        } else {
            // allocate and save new tipConfigId
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
            feeReceiver: feeReceiver,
            currentRound: 0,
            totalRound: totalRound
        });

        // emit event
        emit SetTipsConfig4Character(
            tipConfigId,
            fromCharacterId,
            toCharacterId,
            token,
            amount,
            startTime,
            endTime,
            interval,
            feeReceiver,
            totalRound
        );
    }

    /// @inheritdoc ITipsWithConfig
    function collectTips4Character(uint256 tipConfigId) external override nonReentrant {
        // collect tips
        _collectTips4Character(tipConfigId);
    }

    /// @inheritdoc ITipsWithConfig
    function getFeeFraction(
        address feeReceiver,
        uint256 characterId
    ) external view override returns (uint256) {
        return _getFeeFraction(feeReceiver, characterId);
    }

    /// @inheritdoc ITipsWithConfig
    function getFeeAmount(
        address feeReceiver,
        uint256 characterId,
        uint256 tipAmount
    ) external view override returns (uint256) {
        return _getFeeAmount(feeReceiver, characterId, tipAmount);
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

    function _collectTips4Character(uint256 tipConfigId) internal {
        TipsConfig storage config = _tipsConfigs[tipConfigId];

        // not started
        if (config.startTime > block.timestamp) {
            return;
        }

        // already ended
        if (config.currentRound >= config.totalRound) {
            return;
        }

        (uint256 currentRound, uint256 availableAmount) = _getAvailableRoundAndAmount(config);
        if (availableAmount > 0) {
            // update currentRound
            config.currentRound = currentRound;

            // collect tips
            address from = IERC721(_web3Entry).ownerOf(config.fromCharacterId);
            address to = IERC721(_web3Entry).ownerOf(config.toCharacterId);
            // fee
            uint256 feeAmount = _getFeeAmount(
                config.feeReceiver,
                config.toCharacterId,
                availableAmount
            );
            // slither-disable-next-line arbitrary-send-erc20
            IERC20(config.token).safeTransferFrom(from, to, availableAmount - feeAmount);
            if (feeAmount > 0) {
                // slither-disable-next-line arbitrary-send-erc20
                IERC20(config.token).safeTransferFrom(from, config.feeReceiver, feeAmount);
            }

            // emit event
            emit CollectTips4Character(
                config.id,
                config.fromCharacterId,
                config.toCharacterId,
                config.token,
                availableAmount,
                feeAmount,
                config.feeReceiver,
                currentRound
            );
        }
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

    function _getFeeFraction(
        address feeReceiver,
        uint256 characterId
    ) internal view returns (uint256) {
        // get character fraction
        uint256 fraction = _feeFractions4Character[feeReceiver][characterId];
        if (fraction > 0) return fraction;
        // get default fraction
        return _feeFractions[feeReceiver];
    }

    function _getFeeAmount(
        address feeReceiver,
        uint256 characterId,
        uint256 tipAmount
    ) internal view returns (uint256) {
        uint256 fraction = _getFeeFraction(feeReceiver, characterId);
        return (tipAmount * fraction) / _feeDenominator();
    }

    function _getTipRound(
        uint256 startTime,
        uint256 endTime,
        uint256 interval
    ) internal pure returns (uint256) {
        // why +1? because the first round is 1
        return (endTime - startTime) / interval + 1;
    }

    /**
     * @dev Defaults to 10000 so fees are expressed in basis points.
     */
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }
}
