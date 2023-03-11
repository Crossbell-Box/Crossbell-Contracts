// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {CommonTest} from "./helpers/CommonTest.sol";
import {OP} from "../contracts/libraries/OP.sol";
import {DataTypes} from "../contracts/libraries/DataTypes.sol";
import {ErrNotEnoughPermission, ErrArrayLengthMismatch} from "../contracts/libraries/Error.sol";

contract PeripheryTest is CommonTest {
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(MOCK_CHARACTER_HANDLE, alice);
        _createCharacter(MOCK_CHARACTER_HANDLE2, bob);
        web3Entry.createCharacter(makeCharacterData(MOCK_CHARACTER_HANDLE3, carol));
        web3Entry.createCharacter(makeCharacterData(MOCK_CHARACTER_HANDLE4, dick));
    }

    function testLinkCharactersInBatch() public {
        uint256[] memory characterIds = new uint256[](3);
        characterIds[0] = SECOND_CHARACTER_ID;
        characterIds[1] = THIRD_CHARACTER_ID;
        characterIds[2] = FOURTH_CHARACTER_ID;

        // grant `LINK_CHARACTER` to bob
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(FIRST_CHARACTER_ID, bob, OP.DEFAULT_PERMISSION_BITMAP);

        vm.prank(bob, bob);
        periphery.linkCharactersInBatch(
            DataTypes.linkCharactersInBatchData(
                FIRST_CHARACTER_ID,
                characterIds,
                new bytes[](3),
                new address[](0),
                bytes32(0x666f6c6c6f770000000000000000000000000000000000000000000000000000)
            )
        );
    }

    function testLinkCharactersInBatchFail() public {
        uint256[] memory characterIds = new uint256[](3);
        characterIds[0] = SECOND_CHARACTER_ID;
        characterIds[1] = THIRD_CHARACTER_ID;
        characterIds[2] = FOURTH_CHARACTER_ID;

        // ErrNotEnoughPermission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob, bob);
        periphery.linkCharactersInBatch(
            DataTypes.linkCharactersInBatchData(
                FIRST_CHARACTER_ID,
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
                FIRST_CHARACTER_ID,
                characterIds,
                new bytes[](2),
                new address[](0),
                bytes32(0x666f6c6c6f770000000000000000000000000000000000000000000000000000)
            )
        );
    }
}
