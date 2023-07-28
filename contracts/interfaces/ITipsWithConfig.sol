// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {DataTypes} from "../libraries/DataTypes.sol";

/**
 * @title ITipsWithConfig
 * @notice This is the interface for the TipsWithConfig contract.
 */

interface ITipsWithConfig {
    struct TipsConfig {
        uint256 id;
        uint256 fromCharacterId;
        uint256 toCharacterId;
        address token;
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 interval;
        address feeReceiver;
        uint256 totalRound;
        uint256 currentRound;
    }

    /**
     * @notice Initialize the contract, setting web3Entry address.
     * @param web3Entry_ Address of web3Entry.
     */
    function initialize(address web3Entry_) external;

    /**
     * @notice Sets the default fee percentage of specific receiver.
     * @dev The feeReceiver can be a platform account.
     * @param feeReceiver The fee receiver address.
     * @param fraction The percentage measured in basis points. Each basis point represents 0.01%.
     */
    function setDefaultFeeFraction(address feeReceiver, uint256 fraction) external;

    /**
     * @notice Sets the fee percentage of specific <receiver, character>.
     * @dev If this is set, it will override the default fee fraction.
     * @param feeReceiver The fee receiver address.
     * @param characterId The character ID.
     * @param fraction The percentage measured in basis points. Each basis point represents 0.01%.
     */
    function setFeeFraction4Character(
        address feeReceiver,
        uint256 characterId,
        uint256 fraction
    ) external;

    /**
     * @notice Set the tips config for character.
     * @param fromCharacterId The token ID of character that initiated a reward.
     * @param toCharacterId The token ID of character that would receive the reward.
     * @param token The tip token address.
     * @param amount The amount of token.
     * @param startTime The start time of tips.
     * @param endTime The end time of tips.
     * @param interval The interval of tips.
     * @param feeReceiver Fee receiver address.
     */
    function setTipsConfig4Character(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount,
        uint256 startTime,
        uint256 endTime,
        uint256 interval,
        address feeReceiver
    ) external;

    /**
     * @notice Anyone can call this function to collect a specific tip with periodical config.
     * @dev It will transfer all unredeemed token from the fromCharacter to the toCharacter.
     * @param tipConfigId The tip config ID.
     */
    function collectTips4Character(uint256 tipConfigId) external;

    /**
     * @notice Returns the fee percentage of specific <receiver, note>.
     * @dev It will return the first non-zero value by priority feeFraction4Character and defaultFeeFraction.
     * @param feeReceiver The fee receiver address.
     * @param characterId The character ID .
     * @return fraction The percentage measured in basis points. Each basis point represents 0.01%.
     */
    function getFeeFraction(
        address feeReceiver,
        uint256 characterId
    ) external view returns (uint256);

    /**
     * @notice Returns how much the fee is owed by <feeFraction, tipAmount>.
     * @param feeReceiver The fee receiver address.
     * @param characterId The character ID .
     * @return The fee amount.
     */
    function getFeeAmount(
        address feeReceiver,
        uint256 characterId,
        uint256 tipAmount
    ) external view returns (uint256);

    /**
     * @notice Return the tips config Id.
     * @param fromCharacterId The token ID of character that initiated a reward.
     * @param toCharacterId The token ID of character that would receive the reward.
     * @return uint256 Returns tips config ID.
     */
    function getTipsConfigId(
        uint256 fromCharacterId,
        uint256 toCharacterId
    ) external view returns (uint256);

    /**
     * @notice Return the tips config.
     * @param tipConfigId The tip config ID.
     */
    function getTipsConfig(uint256 tipConfigId) external view returns (TipsConfig memory config);

    /**
     * @notice Returns the address of web3Entry contract.
     * @return The address of web3Entry contract.
     */
    function getWeb3Entry() external view returns (address);
}
