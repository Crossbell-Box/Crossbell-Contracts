// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../../interfaces/ILinkModule4Profile.sol";
import "../ModuleBase.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ApprovalLinkModule4Profile is ILinkModule4Profile, ModuleBase {
    mapping(address => mapping(uint256 => mapping(address => bool)))
        internal _approvedByProfileByOwner;

    constructor(address web3Entry) ModuleBase(web3Entry) {}

    function initializeLinkModule(uint256 profileId, bytes calldata data)
        external
        returns (bytes memory)
    {
        address owner = IERC721(Web3Entry).ownerOf(profileId);

        if (data.length > 0) {
            address[] memory addresses = abi.decode(data, (address[]));
            uint256 addressesLength = addresses.length;
            for (uint256 i = 0; i < addressesLength; ) {
                _approvedByProfileByOwner[owner][profileId][addresses[i]] = true;
                unchecked {
                    ++i;
                }
            }
        }
        return data;
    }

    function approve(
        uint256 profileId,
        address[] calldata addresses,
        bool[] calldata toApprove
    ) external {
        require(addresses.length == toApprove.length, "InitParamsInvalid");
        address owner = IERC721(Web3Entry).ownerOf(profileId);
        require(msg.sender == owner, "NotProfileOwner");

        uint256 addressesLength = addresses.length;
        for (uint256 i = 0; i < addressesLength; ) {
            _approvedByProfileByOwner[owner][profileId][addresses[i]] = toApprove[i];
            unchecked {
                ++i;
            }
        }
    }

    function processLink(
        address caller,
        uint256 profileId,
        bytes calldata data
    ) external override onlyWeb3Entry {
        address owner = IERC721(Web3Entry).ownerOf(profileId);

        require(
            _approvedByProfileByOwner[owner][profileId][caller],
            "ApprovalLinkModule: NotApproved"
        );
    }

    function isApproved(
        address profileOwner,
        uint256 profileId,
        address toCheck
    ) external view returns (bool) {
        return _approvedByProfileByOwner[profileOwner][profileId][toCheck];
    }
}
