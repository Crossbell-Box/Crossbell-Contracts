// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "../../interfaces/IMintModule4Note.sol";
import "../ModuleBase.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

struct ProfileNoteData {
    uint256 amount;
    address currency;
    address recipient;
}

contract FeeMintModule is IMintModule4Note, ModuleBase {
    using SafeERC20 for IERC20;

    mapping(uint256 => mapping(uint256 => ProfileNoteData)) internal _dataByNoteByProfile;

    constructor(address web3Entry) ModuleBase(web3Entry) {}

    function initializeMintModule(
        uint256 profileId,
        uint256 noteId,
        bytes calldata data
    ) external override onlyWeb3Entry returns (bytes memory) {
        (uint256 amount, address currency, address recipient) = abi.decode(
            data,
            (uint256, address, address)
        );
        require(recipient != address(0) && amount > 0, "FeeMintModule: InvalidParams");

        _dataByNoteByProfile[profileId][noteId].amount = amount;
        _dataByNoteByProfile[profileId][noteId].currency = currency;
        _dataByNoteByProfile[profileId][noteId].recipient = recipient;

        return data;
    }

    function processMint(
        address to,
        uint256 profileId,
        uint256 noteId,
        bytes calldata data
    ) external {
        uint256 amount = _dataByNoteByProfile[profileId][noteId].amount;
        address currency = _dataByNoteByProfile[profileId][noteId].currency;

        (address decodedCurrency, uint256 decodedAmount) = abi.decode(data, (address, uint256));
        require(
            decodedAmount == amount && decodedCurrency == currency,
            "FeeMintModule: ModuleDataMismatch"
        );

        address recipient = _dataByNoteByProfile[profileId][noteId].recipient;
        IERC20(currency).safeTransferFrom(to, recipient, amount);
    }

    function getNoteData(uint256 profileId, uint256 noteId)
        external
        view
        returns (ProfileNoteData memory)
    {
        return _dataByNoteByProfile[profileId][noteId];
    }
}
