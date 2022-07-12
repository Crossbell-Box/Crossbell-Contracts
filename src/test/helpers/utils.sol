// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "src/libraries/DataTypes.sol";
import "../Const.sol";

contract Utils is Test {
    address public _to = address(0x2222);
    function makeCharacterData(string memory _handle) public returns (DataTypes.CreateCharacterData memory) {
        DataTypes.CreateCharacterData memory characterData = DataTypes.CreateCharacterData(
            _to,
            _handle,
            Const.MOCK_CHARACTER_URI,
            address(0),
            ""
        );
        return characterData;
    }
}