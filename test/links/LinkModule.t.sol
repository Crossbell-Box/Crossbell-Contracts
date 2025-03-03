// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {OP} from "../../contracts/libraries/OP.sol";
import {CommonTest} from "../helpers/CommonTest.sol";
import {ErrNotEnoughPermission} from "../../contracts/libraries/Error.sol";

contract LinkModuleTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
    }

    function testSetLinkModule4Character() public {
        uint256 characterId = _createCharacter("alice", alice);
        vm.prank(alice);
        web3Entry.setLinkModule4Character(
            DataTypes.setLinkModule4CharacterData(
                characterId, address(approvalLinkModule4Character), abi.encode(array(bob, carol))
            )
        );

        // check linkModule
        assertEq(
            web3Entry.getCharacter(characterId).linkModule, address(approvalLinkModule4Character), "linkModule not set"
        );
    }

    function testSetLinkModule4CharacterWithOperator() public {
        uint256 characterId = _createCharacter("alice", alice);
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(characterId, bob, 1 << OP.SET_LINK_MODULE_FOR_CHARACTER);

        vm.prank(bob);
        web3Entry.setLinkModule4Character(
            DataTypes.setLinkModule4CharacterData(
                characterId, address(approvalLinkModule4Character), abi.encode(array(bob, carol))
            )
        );

        // check linkModule
        assertEq(
            web3Entry.getCharacter(characterId).linkModule, address(approvalLinkModule4Character), "linkModule not set"
        );
    }

    function testSetLinkModule4CharacterFail() public {
        uint256 characterId = _createCharacter("alice", alice);

        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setLinkModule4Character(
            DataTypes.setLinkModule4CharacterData(
                characterId, address(approvalLinkModule4Character), abi.encode(array(bob, carol))
            )
        );
    }

    function testSetLinkModule4CharacterFailWithOperator() public {
        uint256 characterId = _createCharacter("alice", alice);

        vm.prank(alice);
        web3Entry.grantOperatorPermissions(characterId, bob, UINT256_MAX ^ (1 << OP.SET_LINK_MODULE_FOR_CHARACTER));

        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setLinkModule4Character(
            DataTypes.setLinkModule4CharacterData(
                characterId, address(approvalLinkModule4Character), abi.encode(array(bob, carol))
            )
        );
    }

    function testSetLinkModule4Note() public {
        // case 1: set linkModule when posting a note
        uint256 characterId = _createCharacter("alice", alice);
        vm.startPrank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                characterId,
                NOTE_URI,
                address(approvalLinkModule4Note),
                abi.encode(array(bob, carol)), // allowlist
                address(0),
                "",
                false
            )
        );
        // check linkModule
        assertEq(web3Entry.getNote(characterId, 1).linkModule, address(approvalLinkModule4Note), "linkModule not set");

        // case 2: set linkModule by setLinkModule4Note
        uint256 noteId = _postNote(characterId, NOTE_URI);
        // set linkModule for note
        web3Entry.setLinkModule4Note(
            DataTypes.setLinkModule4NoteData(
                characterId, noteId, address(approvalLinkModule4Note), abi.encode(array(bob, carol))
            )
        );
        // check linkModule
        assertEq(
            web3Entry.getNote(characterId, noteId).linkModule, address(approvalLinkModule4Note), "linkModule not set"
        );
        vm.stopPrank();
    }

    function testSetLinkModule4NoteWithOperator() public {
        uint256 characterId = _createCharacter("alice", alice);
        vm.prank(alice);
        uint256 noteId = _postNote(characterId, NOTE_URI);

        vm.prank(alice);
        web3Entry.grantOperatorPermissions(characterId, bob, 1 << OP.SET_LINK_MODULE_FOR_NOTE);

        // set linkModule for note
        vm.prank(bob);
        web3Entry.setLinkModule4Note(
            DataTypes.setLinkModule4NoteData(
                characterId, noteId, address(approvalLinkModule4Note), abi.encode(array(bob, carol))
            )
        );
        // check linkModule
        assertEq(
            web3Entry.getNote(characterId, noteId).linkModule, address(approvalLinkModule4Note), "linkModule not set"
        );
    }

    function testSetLinkModule4NoteFail() public {
        uint256 characterId = _createCharacter("alice", alice);
        vm.prank(alice);
        uint256 noteId = _postNote(characterId, NOTE_URI);

        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setLinkModule4Note(
            DataTypes.setLinkModule4NoteData(
                characterId, noteId, address(approvalLinkModule4Note), abi.encode(array(bob, carol))
            )
        );
    }

    function testSetLinkModule4NoteFailWithOperator() public {
        uint256 characterId = _createCharacter("alice", alice);
        vm.prank(alice);
        uint256 noteId = _postNote(characterId, NOTE_URI);

        vm.prank(alice);
        web3Entry.grantOperatorPermissions(characterId, bob, UINT256_MAX ^ (1 << OP.SET_LINK_MODULE_FOR_NOTE));

        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setLinkModule4Note(
            DataTypes.setLinkModule4NoteData(
                characterId, noteId, address(approvalLinkModule4Note), abi.encode(array(bob, carol))
            )
        );
    }

    function testLinkCharacterWithLinkModule() public {
        address[] memory allowlist = array(bob, carol);
        // create character with linkModule module
        uint256 aliceCharacterId = web3Entry.createCharacter(
            DataTypes.CreateCharacterData(
                alice, CHARACTER_HANDLE2, CHARACTER_URI, address(approvalLinkModule4Character), abi.encode(allowlist)
            )
        );

        // User in approval list linkModule a character
        uint256 bobCharacterId = _createCharacter("bob", bob);
        vm.prank(bob);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(bobCharacterId, aliceCharacterId, LikeLinkType, ""));

        // User not in approval list should not fail to linkModule a character
        uint256 dickCharacterId = _createCharacter("dick", dick);
        vm.prank(dick);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(dickCharacterId, aliceCharacterId, LikeLinkType, ""));
    }

    function testLinkNoteWithLinkModule() public {
        uint256 aliceCharacterId = _createCharacter("alice", alice);
        // alice posts a note
        vm.prank(alice);
        _postNoteWithLinkModule(
            aliceCharacterId, NOTE_URI, address(approvalLinkModule4Note), abi.encode(array(bob, carol))
        );

        // User in approval list linkModule a note
        uint256 bobCharacterId = _createCharacter("bob", bob);
        vm.prank(bob);
        web3Entry.linkNote(DataTypes.linkNoteData(bobCharacterId, aliceCharacterId, 1, LikeLinkType, new bytes(1)));

        // User not in approval list should not fail to linkModule a note
        uint256 dickCharacterId = _createCharacter("dick", dick);
        vm.prank(dick);
        web3Entry.linkNote(DataTypes.linkNoteData(dickCharacterId, aliceCharacterId, 1, LikeLinkType, new bytes(1)));
    }
}
