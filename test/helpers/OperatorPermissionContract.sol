// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../../contracts/libraries/OP.sol";

contract OperatorPermissionContract {
    address public web3EntryAddr;

    constructor(address _web3EntryAddr) public {
        web3EntryAddr = _web3EntryAddr;
    }

    function setCharacterUri(uint256 characterId, string calldata newUri) public {
        web3EntryAddr.call(
            abi.encodeWithSignature(
                "setCharacterUri(uint256 characterId, string calldata newUri)",
                characterId,
                newUri
            )
        );
    }
}
