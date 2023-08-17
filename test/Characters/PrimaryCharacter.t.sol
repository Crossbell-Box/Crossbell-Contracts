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
        _createCharacter(CHARACTER_HANDLE, alice);
        // check states
        assertEq(web3Entry.getPrimaryCharacterId(alice), FIRST_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(FIRST_CHARACTER_ID), true);

        // alice transfers primary character to bob
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, FIRST_CHARACTER_ID);

        // check states
        // alice has no primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), 0);
        // bob's primary character is FIRST_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(bob), FIRST_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(FIRST_CHARACTER_ID), true);
    }

    function testTransferPrimaryCharacter2() public {
        // case: transfer primary character to `bob` account, who already has primary character
        // create characters
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);

        // check states
        assertEq(web3Entry.isPrimaryCharacter(FIRST_CHARACTER_ID), true);
        assertEq(web3Entry.isPrimaryCharacter(SECOND_CHARACTER_ID), true);

        // alice transfers primary character to bob
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, FIRST_CHARACTER_ID);

        // check states
        // alice has no primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), 0);
        assertEq(web3Entry.isPrimaryCharacter(FIRST_CHARACTER_ID), false);
        // bob's primary character is SECOND_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(bob), SECOND_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(SECOND_CHARACTER_ID), true);
    }

    function testPrimaryCharacter() public {
        _createCharacter(CHARACTER_HANDLE, alice);
        assertEq(web3Entry.getPrimaryCharacterId(alice), FIRST_CHARACTER_ID);

        // User should set the new primary character
        _createCharacter(CHARACTER_HANDLE2, alice);
        vm.prank(alice, alice);
        web3Entry.setPrimaryCharacterId(2);
        // check primary character
        assertEq(web3Entry.isPrimaryCharacter(1), false);
        assertEq(web3Entry.isPrimaryCharacter(2), true);
        assertEq(web3Entry.getPrimaryCharacterId(alice), 2);

        // User should set the primary character
        vm.prank(alice, alice);
        web3Entry.setPrimaryCharacterId(1);
        // check primary character
        assertEq(web3Entry.isPrimaryCharacter(1), true);
        assertEq(web3Entry.isPrimaryCharacter(2), false);
        assertEq(web3Entry.getPrimaryCharacterId(alice), 1);

        // transfer character
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, FIRST_CHARACTER_ID);
        // check primary character
        assertEq(web3Entry.isPrimaryCharacter(1), true);
        assertEq(web3Entry.getPrimaryCharacterId(bob), 1);
        assertEq(web3Entry.getPrimaryCharacterId(alice), 0);
    }

    function testTransferNonPrimaryCharacter() public {
        // create characters
        _createCharacter(CHARACTER_HANDLE, alice);
        web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE2, alice));

        // check states
        assertEq(web3Entry.isPrimaryCharacter(SECOND_CHARACTER_ID), false);

        // alice transfers non primary character to bob
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, SECOND_CHARACTER_ID);

        // check states
        // alice's primary character is FIRST_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(alice), FIRST_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(FIRST_CHARACTER_ID), true);
        // bob's primary character is SECOND_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(bob), SECOND_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(SECOND_CHARACTER_ID), true);
    }

    function testTransferLinkedCharacter() public {
        // User should transfer the primary character, and the linklist
        vm.startPrank(bob);
        web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE, bob));
        _createCharacter(CHARACTER_HANDLE2, bob);
        // link character
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );
        // transfer character 1 to alice
        web3Entry.transferFrom(bob, alice, FIRST_LINKLIST_ID);

        // transfer character 2 to carol
        web3Entry.transferFrom(bob, carol, SECOND_CHARACTER_ID);
        vm.stopPrank();

        // check state
        assertEq(web3Entry.ownerOf(FIRST_CHARACTER_ID), alice);
        assertEq(web3Entry.ownerOf(SECOND_CHARACTER_ID), carol);
        assertEq(linklist.ownerOf(FIRST_LINKLIST_ID), alice);
        assertEq(web3Entry.getLinklistId(1, FollowLinkType), FIRST_LINKLIST_ID);
        assertEq(web3Entry.getPrimaryCharacterId(alice), FIRST_CHARACTER_ID);
        assertEq(web3Entry.getPrimaryCharacterId(carol), SECOND_CHARACTER_ID);
        assertEq(web3Entry.getPrimaryCharacterId(bob), 0);
    }

    function testTransferCharacterWithOperators() public {
        vm.startPrank(alice);
        _createCharacter(CHARACTER_HANDLE, alice);
        web3Entry.grantOperatorPermissions(
            FIRST_CHARACTER_ID,
            carol,
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );

        // alice transfers primary character to bob
        web3Entry.transferFrom(alice, bob, FIRST_CHARACTER_ID);

        // check states
        // alice has no primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), 0);
        // bob's primary character is FIRST_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(bob), FIRST_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(FIRST_CHARACTER_ID), true);
        // check operators
        assertEq(web3Entry.getOperatorPermissions(FIRST_CHARACTER_ID, carol), 0);
    }
}
