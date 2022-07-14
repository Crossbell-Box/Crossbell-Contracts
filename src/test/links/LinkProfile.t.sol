// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../Web3Entry.sol";
import "../../libraries/DataTypes.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract LinkProfileTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    function setUp() public {
        _setUp();
    }

    function testLinkProfile() public {
        // User not in approval list should not fail to link a character
        vm.startPrank(alice);
        web3Entry.createCharacter(makeCharacterData(
            Const.MOCK_CHARACTER_HANDLE,
            alice
        ));
        web3Entry.createCharacter(makeCharacterData(
            "hadle2",
            alice
        ));
        web3Entry.linkCharacter(DataTypes.linkCharacterData(
            1,
            2,
            Const.FollowLinkType,
            new bytes(0)     
        ));
    }
}