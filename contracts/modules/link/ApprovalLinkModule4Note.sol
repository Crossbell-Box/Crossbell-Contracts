// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../../interfaces/ILinkModule4Note.sol";
import "../ModuleBase.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ApprovalLinkModule4Note is ILinkModule4Note, ModuleBase {
    mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => bool))))
        internal _approvedByCharacterByNoteByOwner;

    constructor(address web3Entry) ModuleBase(web3Entry) {}

    function initializeLinkModule(
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external returns (bytes memory) {
        address owner = IERC721(web3Entry).ownerOf(characterId);

        if (data.length > 0) {
            address[] memory addresses = abi.decode(data, (address[]));
            uint256 addressesLength = addresses.length;
            for (uint256 i = 0; i < addressesLength; ) {
                _approvedByCharacterByNoteByOwner[owner][characterId][noteId][addresses[i]] = true;
                unchecked {
                    ++i;
                }
            }
        }
        return data;
    }

    function approve(
        uint256 characterId,
        uint256 noteId,
        address[] calldata addresses,
        bool[] calldata toApprove
    ) external {
        require(addresses.length == toApprove.length, "InitParamsInvalid");
        address owner = IERC721(web3Entry).ownerOf(characterId);
        require(msg.sender == owner, "NotCharacterOwner");

        uint256 addressesLength = addresses.length;
        for (uint256 i = 0; i < addressesLength; ) {
            _approvedByCharacterByNoteByOwner[owner][characterId][noteId][addresses[i]] = toApprove[
                i
            ];
            unchecked {
                ++i;
            }
        }
    }

    function processLink(
        address caller,
        uint256 characterId,
        uint256 noteId,
        bytes calldata
    ) external view onlyWeb3Entry {
        address owner = IERC721(web3Entry).ownerOf(characterId);

        require(
            _approvedByCharacterByNoteByOwner[owner][characterId][noteId][caller],
            "ApprovalLinkModule4Note: NotApproved"
        );
    }

    function isApproved(
        address characterOwner,
        uint256 characterId,
        uint256 noteId,
        address toCheck
    ) external view returns (bool) {
        return _approvedByCharacterByNoteByOwner[characterOwner][characterId][noteId][toCheck];
    }
}
