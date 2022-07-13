// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "../../libraries/DataTypes.sol";
import "./Const.sol";

contract Utils is Test {
    function makeCharacterData(string memory _handle, address _to) public returns (DataTypes.CreateCharacterData memory) {
        DataTypes.CreateCharacterData memory characterData = DataTypes.CreateCharacterData(
            _to,
            _handle,
            Const.MOCK_CHARACTER_URI,
            address(0),
            ""
        );
        return characterData;
    }

    function makePostNoteData(uint256 characterId) public returns (DataTypes.PostNoteData memory) {
        DataTypes.PostNoteData memory postNoteData = DataTypes.PostNoteData(
            characterId,
            Const.MOCK_NOTE_URI,
            Const.AddressZero,
            new bytes(0),
            Const.AddressZero,
            new bytes(0),
            false
        );
        return postNoteData;
    }
}