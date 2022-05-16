// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../interfaces/IWeb3Entry.sol";

contract Periphery {
    IWeb3Entry public web3Entry;

    constructor(IWeb3Entry _web3Entry) {
        web3Entry = _web3Entry;
    }

    function linkProfilesInBatch(
        uint256 fromProfileId,
        address[] calldata tos,
        bytes32 linkType
    ) external {
        for (uint256 i = 0; i < tos.length; i++) {
            address to = tos[i];
            uint256 primaryProfileId = web3Entry.getPrimaryProfileId(to);
            if (primaryProfileId == 0) {
                web3Entry.createThenLinkProfile(fromProfileId, to, linkType);
            } else {
                web3Entry.linkProfile(fromProfileId, primaryProfileId, linkType);
            }
        }
    }
}
