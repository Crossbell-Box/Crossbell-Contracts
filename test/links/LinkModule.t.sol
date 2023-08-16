// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

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
                characterId,
                address(approvalLinkModule4Character),
                abi.encode(array(bob, carol))
            )
        );

        // check linkModule
        DataTypes.Character memory character = web3Entry.getCharacter(characterId);
        assertEq(character.linkModule, address(approvalLinkModule4Character), "linkModule not set");
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
        DataTypes.Note memory note = web3Entry.getNote(characterId, 1);
        assertEq(note.linkModule, address(approvalLinkModule4Note), "linkModule not set");

        // case 2: set linkModule by setLinkModule4Note
        _postNote(characterId, NOTE_URI);
        // set linkModule for note
        web3Entry.setLinkModule4Note(
            DataTypes.setLinkModule4NoteData(
                characterId,
                2,
                address(approvalLinkModule4Note),
                abi.encode(array(bob, carol))
            )
        );
        // check linkModule
        note = web3Entry.getNote(characterId, 2);
        assertEq(note.linkModule, address(approvalLinkModule4Note), "linkModule not set");
        vm.stopPrank();
    }

    function testLinkCharacterWithLinkModule() public {
        address[] memory allowlist = array(bob, carol);
        // create character with linkModule module
        uint256 aliceCharacterId = web3Entry.createCharacter(
            DataTypes.CreateCharacterData(
                alice,
                CHARACTER_HANDLE2,
                CHARACTER_URI,
                address(approvalLinkModule4Character),
                abi.encode(allowlist)
            )
        );

        // User in approval list linkModule a character
        uint256 bobCharacterId = _createCharacter("bob", bob);
        vm.prank(bob);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                bobCharacterId,
                aliceCharacterId,
                LikeLinkType,
                new bytes(1)
            )
        );

        // User not in approval list should not fail to linkModule a character
        uint256 dickCharacterId = _createCharacter("dick", dick);
        vm.prank(dick);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                dickCharacterId,
                aliceCharacterId,
                LikeLinkType,
                new bytes(1)
            )
        );
    }

    function testLinkNoteWithLinkModule() public {
        uint256 aliceCharacterId = _createCharacter("alice", alice);
        // alice posts a note
        vm.prank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                aliceCharacterId,
                NOTE_URI,
                address(approvalLinkModule4Note),
                abi.encode(array(bob, carol)),
                address(0),
                "",
                false
            )
        );

        // User in approval list linkModule a note
        uint256 bobCharacterId = _createCharacter("bob", bob);
        vm.prank(bob);
        web3Entry.linkNote(
            DataTypes.linkNoteData(bobCharacterId, aliceCharacterId, 1, LikeLinkType, new bytes(1))
        );

        // User not in approval list should not fail to linkModule a note
        uint256 dickCharacterId = _createCharacter("dick", dick);
        vm.prank(dick);
        web3Entry.linkNote(
            DataTypes.linkNoteData(dickCharacterId, aliceCharacterId, 1, LikeLinkType, new bytes(1))
        );
    }
}
