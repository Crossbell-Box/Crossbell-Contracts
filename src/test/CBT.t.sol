// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../libraries/DataTypes.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";
import "../misc/CBT1155.sol";

contract CbtTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    uint256 amount = 1;

    function setUp() public {
        _setUp();
    }

    function testCbt() public {
        // alice mint first character
        DataTypes.CreateCharacterData memory characterData = makeCharacterData(
            Const.MOCK_CHARACTER_HANDLE,
            alice
        );
        vm.prank(alice);
        web3Entry.createCharacter(characterData);

        // MINTER_ROLE should mint
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        uint256 balance1Of1 = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CBT_ID
        );
        assertEq(balance1Of1, amount);
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.SECOND_CBT_ID, amount);
        uint256 balance2Of1 = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CBT_ID
        );
        assertEq(balance2Of1, amount);
        // can't mint to the zero characterID
        vm.expectRevert(abi.encodePacked("mint to the zero characterId"));
        cbt.mint(Const.ZERO_CBT_ID, Const.FIRST_CBT_ID, amount);
        // expect correct emit
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.Mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);

        //owner should burn
        uint256 preBalance = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CBT_ID
        );
        vm.prank(alice);
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        uint256 postBalance = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CBT_ID
        );
        assertEq(preBalance - amount, postBalance);
        // caller is not token owner nor approved
        vm.expectRevert(abi.encodePacked("caller is not token owner nor approved"));
        vm.prank(bob);
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        //burn amount exceeds balance
        vm.prank(alice);
        vm.expectRevert(abi.encodePacked("burn amount exceeds balance"));
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, postBalance + 1);
        // expect correct emit
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.Burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        vm.prank(alice);
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
    }
}
