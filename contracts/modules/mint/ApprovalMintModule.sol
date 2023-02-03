// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "../../interfaces/IMintModule4Note.sol";
import "../ModuleBase.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ApprovalMintModule is IMintModule4Note, ModuleBase {
    mapping(address => mapping(uint256 => mapping(uint256 => mapping(address => bool))))
        internal _approvedByCharacterByNoteByOwner;

    constructor(address web3Entry) ModuleBase(web3Entry) {}

    function initializeMintModule(
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

    function processMint(
        address to,
        uint256 characterId,
        uint256 noteId,
        bytes calldata
    ) external view onlyWeb3Entry {
        address owner = IERC721(web3Entry).ownerOf(characterId);

        require(
            _approvedByCharacterByNoteByOwner[owner][characterId][noteId][to],
            "ApprovalMintModule: NotApproved"
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
