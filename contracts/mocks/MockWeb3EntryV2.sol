// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../base/NFTBase.sol";
import "../libraries/DataTypes.sol";
import "../libraries/Constants.sol";
import "./MockWeb3EntryV2Storage.sol";

contract MockWeb3EntryV2 is NFTBase, MockWeb3EntryV2Storage {
    uint256 internal constant REVISION = 2;

    function setAdditionalValue(uint256 newValue) external {
        _additionalValue = newValue;
    }

    function getAdditionalValue() external view returns (uint256) {
        return _additionalValue;
    }

    function getRevision() external pure returns (uint256) {
        return REVISION;
    }
}
