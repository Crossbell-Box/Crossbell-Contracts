// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {Test} from "forge-std/Test.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {OP} from "../../contracts/libraries/OP.sol";
import {ErrNotCharacterOwner} from "../../contracts/libraries/Error.sol";
import {Const} from "../helpers/Const.sol";
import {Utils} from "../helpers/Utils.sol";
import {SetUp} from "../helpers/SetUp.sol";

contract PrimaryCharacterTest is Test, Utils, SetUp {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
    }

    function testPrimaryCharacter() public {
        vm.startPrank(bob);
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, bob));

        // User's first character should be the primary character
        uint256 primaryCharacter = web3Entry.getPrimaryCharacterId(bob);
        assertEq(primaryCharacter, Const.FIRST_CHARACTER_ID);

        // User should set the new primary character
        web3Entry.createCharacter(makeCharacterData("handle2", bob));
        web3Entry.setPrimaryCharacterId(2);
        assertEq(web3Entry.getPrimaryCharacterId(bob), 2);

        // User should set the primary character
        web3Entry.setPrimaryCharacterId(1);
        assertEq(web3Entry.getPrimaryCharacterId(bob), 1);

        // User should transfer the primary character, and then their primary character and operator should be unset
        // web3Entry.setOperator(Const.FIRST_CHARACTER_ID, carol);
        web3Entry.grantOperatorPermissions(
            Const.FIRST_CHARACTER_ID,
            carol,
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, carol),
            OP.DEFAULT_PERMISSION_BITMAP
        );
        web3Entry.transferFrom(bob, alice, Const.FIRST_NOTE_ID);
        assertEq(web3Entry.getPrimaryCharacterId(bob), 0);
        assertEq(web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, carol), 0);
        assertEq(web3Entry.getOperators(Const.FIRST_CHARACTER_ID).length, 0);
        vm.stopPrank();
    }

    function testSetPrimaryCharacterIdFail() public {
        vm.prank(bob);
        uint256 characterId = web3Entry.createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, bob)
        );

        // UserTwo should fail to set the primary character as a character owned by user 1
        vm.expectRevert(abi.encodeWithSelector(ErrNotCharacterOwner.selector));
        vm.prank(carol);
        web3Entry.setPrimaryCharacterId(characterId);
    }

    function testTransferPrimaryCharacter() public {
        // case: transfer primary character to `bob` account, who has no primary character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        // check states
        assertEq(web3Entry.getPrimaryCharacterId(alice), Const.FIRST_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(Const.FIRST_CHARACTER_ID), true);

        // alice transfers primary character to bob
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, Const.FIRST_CHARACTER_ID);

        // check states
        // alice has no primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), 0);
        // bob's primary character is Const.FIRST_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(bob), Const.FIRST_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(Const.FIRST_CHARACTER_ID), true);
    }

    function testTransferNonPrimaryCharacter() public {
        // create characters
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, alice));

        // check states
        assertEq(web3Entry.isPrimaryCharacter(Const.SECOND_CHARACTER_ID), false);

        // alice transfers non primary character to bob
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, Const.SECOND_CHARACTER_ID);

        // check states
        // alice's primary character is Const.FIRST_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(alice), Const.FIRST_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(Const.FIRST_CHARACTER_ID), true);
        // bob's primary character is Const.SECOND_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(bob), Const.SECOND_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(Const.SECOND_CHARACTER_ID), true);
    }

    function testTransferPrimaryCharacter2() public {
        // case: transfer primary character to `bob` account, who already has primary character
        // create characters
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));

        // check states
        assertEq(web3Entry.isPrimaryCharacter(Const.FIRST_CHARACTER_ID), true);
        assertEq(web3Entry.isPrimaryCharacter(Const.SECOND_CHARACTER_ID), true);

        // alice transfers primary character to bob
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, Const.FIRST_CHARACTER_ID);

        // check states
        // alice has no primary character
        assertEq(web3Entry.getPrimaryCharacterId(alice), 0);
        assertEq(web3Entry.isPrimaryCharacter(Const.FIRST_CHARACTER_ID), false);
        // bob's primary character is Const.SECOND_CHARACTER_ID
        assertEq(web3Entry.getPrimaryCharacterId(bob), Const.SECOND_CHARACTER_ID);
        assertEq(web3Entry.isPrimaryCharacter(Const.SECOND_CHARACTER_ID), true);
    }

    function testTransferLinkedCharacter() public {
        // User should transfer the primary character, and the linklist
        vm.startPrank(bob);
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, bob));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
        // link character
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        // transfer character 1 to alice
        web3Entry.transferFrom(bob, alice, Const.FIRST_LINKLIST_ID);

        // transfer character 2 to carol
        web3Entry.transferFrom(bob, carol, Const.SECOND_CHARACTER_ID);
        vm.stopPrank();

        // check state
        assertEq(web3Entry.ownerOf(Const.FIRST_CHARACTER_ID), alice);
        assertEq(web3Entry.ownerOf(Const.SECOND_CHARACTER_ID), carol);
        assertEq(linklist.ownerOf(Const.FIRST_LINKLIST_ID), alice);
        assertEq(web3Entry.getLinklistId(1, Const.FollowLinkType), Const.FIRST_LINKLIST_ID);
        assertEq(web3Entry.getPrimaryCharacterId(alice), Const.FIRST_CHARACTER_ID);
        assertEq(web3Entry.getPrimaryCharacterId(carol), Const.SECOND_CHARACTER_ID);
        assertEq(web3Entry.getPrimaryCharacterId(bob), 0);
    }
}
