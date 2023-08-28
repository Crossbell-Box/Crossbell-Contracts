// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {ERC721} from "./ERC721.sol";
import {Events} from "../libraries/Events.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract LinklistBase is ERC165 {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    /**
     * @dev For compatibility with previous ERC721Enumerable, we need to keep the unused slots for upgradeability.
     */
    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(address => mapping(uint256 => uint256)) private _ownedTokens; // unused slot 6
    mapping(uint256 => uint256) private _ownedTokensIndex; // unused slot 7
    uint256[] private _allTokens; // unused slot 8
    mapping(uint256 => uint256) private _allTokensIndex; // unused slot 9

    function _initialize(string calldata name_, string calldata symbol_) internal {
        _name = name_;
        _symbol = symbol_;

        emit Events.BaseInitialized(name_, symbol_, block.timestamp);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }
}
