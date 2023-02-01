// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Thanks is Initializable {
    using SafeERC20 for IERC20;

    address internal _web3Entry;

    // events
    event ThanksToCharacter(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount
    );
    event ThanksToNote(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        uint256 indexed toNoteId,
        address token,
        uint256 amount
    );

    /**
     * @notice Initialize the contract.
     * @param web3Entry Address of web3Entry.
     */
    function initialize(address web3Entry) external initializer {
        _web3Entry = web3Entry;
    }

    function thanksToCharacter(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        address token,
        uint256 amount
    ) external {
        // check
        address from = IERC721(_web3Entry).ownerOf(fromCharacterId);
        address to = IERC721(_web3Entry).ownerOf(toCharacterId);

        // transfer token
        IERC20(token).safeTransferFrom(from, to, amount);

        // emit event
        emit ThanksToCharacter(fromCharacterId, toCharacterId, token, amount);
    }

    function thanksToNote(
        uint256 fromCharacterId,
        uint256 toCharacterId,
        uint256 toNoteId,
        address token,
        uint256 amount
    ) external {
        // check
        address from = IERC721(_web3Entry).ownerOf(fromCharacterId);
        address to = IERC721(_web3Entry).ownerOf(toCharacterId);

        // transfer token
        IERC20(token).safeTransferFrom(from, to, amount);

        // emit event
        emit ThanksToNote(fromCharacterId, toCharacterId, toNoteId, token, amount);
    }
}
