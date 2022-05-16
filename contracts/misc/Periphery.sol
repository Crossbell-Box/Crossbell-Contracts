// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../interfaces/IWeb3Entry.sol";
import "../libraries/DataTypes.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Periphery is Initializable {
    IWeb3Entry public web3Entry;

    function initialize(IWeb3Entry _web3Entry) external initializer {
        web3Entry = _web3Entry;
    }

    function linkProfilesInBatch(DataTypes.linkProfilesInBatchData calldata vars) external {
        require(vars.toProfileIds.length == vars.data.length, "ArrayLengthMisMatch");

        for (uint256 i = 0; i < vars.toProfileIds.length; i++) {
            web3Entry.linkProfileV2(
                vars.fromProfileId,
                vars.toProfileIds[i],
                vars.linkType,
                vars.data[i]
            );
        }

        for (uint256 i = 0; i < vars.toAddresses.length; i++) {
            web3Entry.createThenLinkProfile(vars.fromProfileId, vars.toAddresses[i], vars.linkType);
        }
    }
}
