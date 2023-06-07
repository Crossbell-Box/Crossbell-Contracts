// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import {DataTypes} from "../libraries/DataTypes.sol";

interface ITipsWithFee {
    /**
     * @notice Initializes the TipsWithFee.
     * @param web3Entry_ Address of web3Entry.
     * @param token_ Address of token.
     */
    function initialize(address web3Entry_, address token_) external;

    /**
     * @notice Changes the default fee percentage of specific receiver.
     * @dev The receiver can be a platform account.
     * @param receiver The fee receiver address.
     * @param fraction The percentage measured in basis points. Each basis point represents 0.01%.
     */
    function setDefaultFeeFraction(address receiver, uint256 fraction) external;

    /**
     * @notice Changes the fee percentage of specific <receiver, character>.
     * @dev If feeFraction4Character is set, it will override the default fee fraction.
     * @param receiver The fee receiver address.
     * @param characterId The character ID.
     * @param fraction The percentage measured in basis points. Each basis point represents 0.01%.
     */
    function setFeeFraction4Character(
        address receiver,
        uint256 characterId,
        uint256 fraction
    ) external;

    /**
     * @notice Changes the fee percentage of specific <receiver, note>.
     * @dev If feeFraction4Note is set, it will override feeFraction4Character and the default fee fraction.
     * @param receiver The fee receiver address.
     * @param characterId The character ID .
     * @param noteId The note ID .
     * @param fraction The percentage measured in basis points. Each basis point represents 0.01%.
     */
    function setFeeFraction4Note(
        address receiver,
        uint256 characterId,
        uint256 noteId,
        uint256 fraction
    ) external;

    /**
     * @notice Returns the fee percentage of specific <receiver, note>.
     * @dev It will return the first non-zero value by priority feeFraction4Note,
     * feeFraction4Character and defaultFeeFraction.
     * @param receiver The fee receiver address.
     * @param characterId The character ID .
     * @param noteId The note ID .
     * @return fraction The percentage measured in basis points. Each basis point represents 0.01%.
     */
    function getFeeFraction(
        address receiver,
        uint256 characterId,
        uint256 noteId
    ) external view returns (uint256);

    /**
     * @notice Returns how much the fee is owed by <feeFraction, tipAmount>.
     * @param receiver The fee receiver address.
     * @param characterId The character ID .
     * @param noteId The note ID .
     * @return The fee amount.
     */
    function getFeeAmount(
        address receiver,
        uint256 characterId,
        uint256 noteId,
        uint256 tipAmount
    ) external view returns (uint256);

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
