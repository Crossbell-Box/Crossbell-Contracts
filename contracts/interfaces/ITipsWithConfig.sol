// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {DataTypes} from "../libraries/DataTypes.sol";

/**
 * @title ITipsWithConfig
 * @notice This is the interface for the TipsWithConfig contract.
 */

interface ITipsWithConfig {
    /**
     * @notice Initializes the ITipsWithConfig.
     * @param web3Entry_ Address of web3Entry.
     * @param token_ Address of token.
     * @param tips_ Address of tips.
     */
    function initialize(address web3Entry_, address token_, address tips_) external;

    /**
     * @notice Set the tips config for character.
     * @param fromCharacterId The from character ID.
     * @param toCharacterId The to character ID.
     * @param token The tip token address.
     * @param amount The amount of token.
     * @param interval The interval of tips with periodical config.
     * @param expiration The expiration of tips with periodical config.
     */
    function setTipsConfig4Character(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount,
        uint256 interval,
        uint256 expiration
    ) external;

    /**
     * @notice Anyone can call this function to trigger a specific tip with periodical config.
     * @dev It will transfer all unredeemed token from the fromCharacter to the toCharacter.
     * @param tipConfigId The tip config ID.
     */
    function triggerTips4Character(uint256 tipConfigId) external;

    /**
     * @notice Return the tips config.
     * @return fromCharacterId The from character ID.
     * @return toCharacterId The to character ID.
     * @return token The tip token address.
     * @return amount The amount of token.
     * @return interval The interval of tips with periodical config.
     * @return expiration The expiration of tips with periodical config.
     */
    function getTipsConfig(
        uint256 tipConfigId
    )
        external
        view
        returns (
            uint256 fromCharacterId,
            uint256 toCharacterId,
            address token,
            uint256 amount,
            uint256 interval,
            uint256 expiration
        );

    /**
     * @notice Returns the authorized amount of a user to the tipWithConfig contract.
     * @return The authorized amount.
     */
    function getAuthorizedAmount() external view returns (uint256);

    /**
     * @notice Returns the address of web3Entry contract.
     * @return The address of web3Entry contract.
     */
    function getWeb3Entry() external view returns (address);

    /**
     * @notice Returns the address of mira token contract.
     * @return The address of mira token contract.
     */
    function getToken() external view returns (address);
}
