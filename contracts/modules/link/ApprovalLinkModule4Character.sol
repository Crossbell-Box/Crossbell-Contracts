// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "../../interfaces/ILinkModule4Character.sol";
import "../ModuleBase.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title ApprovalLinkModule4Character
 * @notice This is a simple LinkModule implementation, inheriting from the ILinkModule4Character interface.
 */
contract ApprovalLinkModule4Character is ILinkModule4Character, ModuleBase {
    mapping(address => mapping(uint256 => mapping(address => bool)))
        internal _approvedByCharacterByOwner;

    // solhint-disable-next-line no-empty-blocks
    constructor(address web3Entry) ModuleBase(web3Entry) {}

    function initializeLinkModule(
        uint256 characterId,
        bytes calldata data
    ) external override returns (bytes memory) {
        address owner = IERC721(web3Entry).ownerOf(characterId);

        if (data.length > 0) {
            address[] memory addresses = abi.decode(data, (address[]));

            uint256 addressesLength = addresses.length;
            for (uint256 i = 0; i < addressesLength; ) {
                _approvedByCharacterByOwner[owner][characterId][addresses[i]] = true;
                unchecked {
                    ++i;
                }
            }
        }
        return data;
    }

    /**
     * @notice A custom function that allows character owners to customize approved addresses.
     *
     * @param characterId The character ID to approve/disapprove.
     * @param addresses The addresses to approve/disapprove for linking the character.
     * @param toApprove Whether to approve or disapprove the addresses for linking the character.
     */
    // solhint-disable-next-line comprehensive-interface
    function approve(
        uint256 characterId,
        address[] calldata addresses,
        bool[] calldata toApprove
    ) external {
        require(addresses.length == toApprove.length, "InitParamsInvalid");
        address owner = IERC721(web3Entry).ownerOf(characterId);
        require(msg.sender == owner, "NotCharacterOwner");

        uint256 addressesLength = addresses.length;
        for (uint256 i = 0; i < addressesLength; ) {
            _approvedByCharacterByOwner[owner][characterId][addresses[i]] = toApprove[i];
            unchecked {
                ++i;
            }
        }
    }

    function processLink(
        address caller,
        uint256 characterId,
        bytes calldata
    ) external view override onlyWeb3Entry {
        address owner = IERC721(web3Entry).ownerOf(characterId);

        require(
            _approvedByCharacterByOwner[owner][characterId][caller],
            "ApprovalLinkModule: NotApproved"
        );
    }

    // solhint-disable-next-line comprehensive-interface
    function isApproved(
        address characterOwner,
        uint256 characterId,
        address toCheck
    ) external view returns (bool) {
        return _approvedByCharacterByOwner[characterOwner][characterId][toCheck];
    }
}
