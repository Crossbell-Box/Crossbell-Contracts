// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {Events} from "../../contracts/libraries/Events.sol";
import {OP} from "../../contracts/libraries/OP.sol";
import {ErrNotCharacterOwner} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract PrimaryCharacterTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
    }

    function testPrimaryCharacterByDefault() public {
        uint256 characterId = _createCharacter(CHARACTER_HANDLE, alice);

        // check states
        assertEq(web3Entry.getPrimaryCharacterId(alice), characterId);
        assertEq(web3Entry.isPrimaryCharacter(characterId), true);
    }

    function testSetPrimaryCharacter() public {
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, alice);
        // check primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), FIRST_CHARACTER_ID);

        expectEmit(CheckAll);
        emit Events.SetPrimaryCharacterId(alice, SECOND_CHARACTER_ID, FIRST_CHARACTER_ID);
        vm.prank(alice, alice);
        web3Entry.setPrimaryCharacterId(SECOND_CHARACTER_ID);

        // check primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), SECOND_CHARACTER_ID);
    }

    function testSetPrimaryCharacterByPeriphery() public {
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, alice);
        // check primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), FIRST_CHARACTER_ID);

        expectEmit(CheckAll);
        emit Events.SetPrimaryCharacterId(
            address(periphery),
            SECOND_CHARACTER_ID,
            FIRST_CHARACTER_ID
        );
        vm.prank(address(periphery), alice);
        web3Entry.setPrimaryCharacterId(SECOND_CHARACTER_ID);

        // check primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), SECOND_CHARACTER_ID);
    }

    function testSetPrimaryCharacterIdFail() public {
        vm.prank(bob);
        uint256 characterId = web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE, bob));

        // not character owner
        vm.expectRevert(abi.encodeWithSelector(ErrNotCharacterOwner.selector));
        vm.prank(carol, carol);
        web3Entry.setPrimaryCharacterId(characterId);

        // not character owner
        vm.expectRevert(abi.encodeWithSelector(ErrNotCharacterOwner.selector));
        vm.prank(address(periphery), carol);
        web3Entry.setPrimaryCharacterId(characterId);
    }

    function testTransferPrimaryCharacter() public {
        // case: transfer primary character to `bob` account, who has no primary character
        uint256 characterId = _createCharacter(CHARACTER_HANDLE, alice);

        // alice transfers primary character to bob
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, characterId);

        // check states
        // alice has no primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), 0);
        // bob's primary character is FIRST_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(bob), characterId);
        assertEq(web3Entry.isPrimaryCharacter(characterId), true);
    }

    function testTransferPrimaryCharacter2() public {
        // case: transfer primary character to `bob` account, who already has primary character
        // create characters
        uint256 firstCharacter = _createCharacter(CHARACTER_HANDLE, alice);
        uint256 secondCharacter = _createCharacter(CHARACTER_HANDLE2, bob);

        // check states
        assertEq(web3Entry.isPrimaryCharacter(firstCharacter), true);
        assertEq(web3Entry.isPrimaryCharacter(secondCharacter), true);

        // alice transfers primary character to bob
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, firstCharacter);

        // check states
        // alice has no primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), 0);
        assertEq(web3Entry.isPrimaryCharacter(firstCharacter), false);
        // bob's primary character is SECOND_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(bob), secondCharacter);
        assertEq(web3Entry.isPrimaryCharacter(secondCharacter), true);
    }

    function testSetPrimaryCharacterMultiply() public {
        uint256 firstCharacter = _createCharacter(CHARACTER_HANDLE, alice);
        assertEq(web3Entry.getPrimaryCharacterId(alice), firstCharacter);
        assertEq(web3Entry.isPrimaryCharacter(firstCharacter), true);

        // User should set the new primary character
        uint256 secondCharacter = _createCharacter(CHARACTER_HANDLE2, alice);
        vm.prank(alice, alice);
        web3Entry.setPrimaryCharacterId(secondCharacter);
        // check primary character
        assertEq(web3Entry.isPrimaryCharacter(firstCharacter), false);
        assertEq(web3Entry.isPrimaryCharacter(secondCharacter), true);
        assertEq(web3Entry.getPrimaryCharacterId(alice), secondCharacter);

        // User should set the primary character
        vm.prank(alice, alice);
        web3Entry.setPrimaryCharacterId(firstCharacter);
        // check primary character
        assertEq(web3Entry.isPrimaryCharacter(firstCharacter), true);
        assertEq(web3Entry.isPrimaryCharacter(secondCharacter), false);
        assertEq(web3Entry.getPrimaryCharacterId(alice), firstCharacter);
    }

    function testTransferNonPrimaryCharacter() public {
        // create characters
        uint256 firstCharacter = _createCharacter(CHARACTER_HANDLE, alice);
        uint256 secondCharacter = _createCharacter(CHARACTER_HANDLE2, alice);

        // alice transfers non primary character to bob
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, secondCharacter);

        // check states
        // alice's primary character is firstCharacter
        assertEq(web3Entry.getPrimaryCharacterId(alice), firstCharacter);
        assertEq(web3Entry.isPrimaryCharacter(firstCharacter), true);
        // bob's primary character is secondCharacter
        assertEq(web3Entry.getPrimaryCharacterId(bob), secondCharacter);
        assertEq(web3Entry.isPrimaryCharacter(secondCharacter), true);
    }

    function testTransferLinkedCharacter() public {
        // User should transfer the primary character, and the linklist
        vm.startPrank(bob);
        uint256 firstCharacter = _createCharacter(CHARACTER_HANDLE, bob);
        uint256 secondCharacter = _createCharacter(CHARACTER_HANDLE2, bob);
        // link character
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(firstCharacter, secondCharacter, FollowLinkType, "")
        );
        // transfer firstCharacter to alice
        web3Entry.transferFrom(bob, alice, firstCharacter);
        // transfer secondCharacter to carol
        web3Entry.transferFrom(bob, carol, SECOND_CHARACTER_ID);
        vm.stopPrank();

        // check state
        assertEq(web3Entry.ownerOf(firstCharacter), alice);
        assertEq(web3Entry.ownerOf(secondCharacter), carol);
        assertEq(web3Entry.getPrimaryCharacterId(alice), firstCharacter);
        assertEq(web3Entry.getPrimaryCharacterId(carol), secondCharacter);
        assertEq(web3Entry.getPrimaryCharacterId(bob), 0);
        // check linklist
        assertEq(linklist.ownerOf(1), alice);
        assertEq(web3Entry.getLinklistId(1, FollowLinkType), 1);
    }

    function testTransferCharacterWithOperators() public {
        vm.startPrank(alice);
        uint256 characterId = _createCharacter(CHARACTER_HANDLE, alice);
        web3Entry.grantOperatorPermissions(characterId, carol, OP.DEFAULT_PERMISSION_BITMAP);
        web3Entry.grantOperatorPermissions(characterId, dick, OP.DEFAULT_PERMISSION_BITMAP);

        // alice transfers primary character to bob
        web3Entry.transferFrom(alice, bob, characterId);

        // check states
        // alice has no primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), 0);
        // bob's primary character is FIRST_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(bob), characterId);
        assertEq(web3Entry.isPrimaryCharacter(characterId), true);
        // check operators
        assertEq(web3Entry.getOperators(characterId).length, 0);
        assertEq(web3Entry.getOperatorPermissions(characterId, carol), 0);
        assertEq(web3Entry.getOperatorPermissions(characterId, dick), 0);
    }
}
