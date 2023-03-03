// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";
import "../contracts/libraries/OP.sol";
import "../contracts/Web3Entry.sol";
import "../contracts/libraries/DataTypes.sol";

contract PeripheryTest is Test, SetUp, Utils {
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE3, carol));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE4, dick));
    }

    function testLinkCharactersInBatch() public {
        uint256[] memory characterIds = new uint256[](3);
        characterIds[0] = Const.SECOND_CHARACTER_ID;
        characterIds[1] = Const.THIRD_CHARACTER_ID;
        characterIds[2] = Const.FOURTH_CHARACTER_ID;

        // grant `LINK_CHARACTER` to bob
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP
        );

        vm.prank(bob, bob);
        periphery.linkCharactersInBatch(
            DataTypes.linkCharactersInBatchData(
                Const.FIRST_CHARACTER_ID,
                characterIds,
                new bytes[](3),
                new address[](0),
                bytes32(0x666f6c6c6f770000000000000000000000000000000000000000000000000000)
            )
        );
    }

    function testLinkCharactersInBatchFail() public {
        uint256[] memory characterIds = new uint256[](3);
        characterIds[0] = Const.SECOND_CHARACTER_ID;
        characterIds[1] = Const.THIRD_CHARACTER_ID;
        characterIds[2] = Const.FOURTH_CHARACTER_ID;

        // ErrNotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob, bob);
        periphery.linkCharactersInBatch(
            DataTypes.linkCharactersInBatchData(
                Const.FIRST_CHARACTER_ID,
                characterIds,
                new bytes[](3),
                new address[](0),
                bytes32(0x666f6c6c6f770000000000000000000000000000000000000000000000000000)
            )
        );

        // ArrayLengthMismatch
        vm.expectRevert(abi.encodeWithSelector(ErrArrayLengthMismatch.selector));
        vm.prank(bob, bob);
        periphery.linkCharactersInBatch(
            DataTypes.linkCharactersInBatchData(
                Const.FIRST_CHARACTER_ID,
                characterIds,
                new bytes[](2),
                new address[](0),
                bytes32(0x666f6c6c6f770000000000000000000000000000000000000000000000000000)
            )
        );
    }
}
