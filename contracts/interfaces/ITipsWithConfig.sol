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
        uint256 tipsTimes;
        uint256 redeemedTimes;
    }

    /**
     * @notice Initializes the ITipsWithConfig.
     * @param web3Entry_ Address of web3Entry.
     */
    function initialize(address web3Entry_) external;

    /**
     * @notice Set the tips config for character.
     * @param fromCharacterId The from character ID.
     * @param toCharacterId The to character ID.
     * @param token The tip token address.
     * @param amount The amount of token.
     * @param startTime The start time of tips.
     * @param endTime The end time of tips.
     * @param interval The interval of tips.
     */
    function setTipsConfig4Character(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount,
        uint256 startTime,
        uint256 endTime,
        uint256 interval
    ) external;

    /**
     * @notice Anyone can call this function to trigger a specific tip with periodical config.
     * @dev It will transfer all unredeemed token from the fromCharacter to the toCharacter.
     * @param tipConfigId The tip config ID.
     */
    function triggerTips4Character(uint256 tipConfigId) external;

    /**
     * @notice Return the tips configId.
     * @param fromCharacterId The from character ID.
     * @param toCharacterId The to character ID.
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
