// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Vm} from "forge-std/Vm.sol";
import {Test} from "forge-std/Test.sol";
import {Const} from "./Const.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";

contract Utils is Test, Const {
    uint8 public constant CheckTopic1 = 0x1;
    uint8 public constant CheckTopic2 = 0x2;
    uint8 public constant CheckTopic3 = 0x4;
    uint8 public constant CheckData = 0x8;
    uint8 public constant CheckAll = 0xf;

    /* solhint-disable comprehensive-interface */
    function expectEmit() public {
        expectEmit(CheckAll);
    }

    function expectEmit(uint8 checks) public {
        require(checks < 16, "Invalid options");

        uint8 mask = 0x1; //0001
        bool checkTopic1 = (checks & mask) > 0;
        bool checkTopic2 = (checks & (mask << 1)) > 0;
        bool checkTopic3 = (checks & (mask << 2)) > 0;
        bool checkData = (checks & (mask << 3)) > 0;

        vm.expectEmit(checkTopic1, checkTopic2, checkTopic3, checkData);
    }

    function assertBytesEq(bytes memory a, bytes memory b) public {
        if (keccak256(a) != keccak256(b)) {
            emit log("Error: a == b not satisfied [bytes]");
            emit log_named_bytes("  Expected", b);
            emit log_named_bytes("    Actual", a);
            fail();
        }
    }

    function assertUintArrayEq(uint256[] memory a, uint256[] memory b) public {
        require(a.length == b.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < a.length; i++) {
            assertEq(a[i], b[i]);
        }
    }

    function min3(uint256 a, uint256 b, uint256 c) public pure returns (uint256) {
        return a > b ? (b > c ? c : b) : (a > c ? c : a);
    }

    function min2(uint256 a, uint256 b) public pure returns (uint256) {
        return a > b ? b : a;
    }

    function array(uint256 a) public pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](1);
        arr[0] = a;
        return arr;
    }

    function array(address a) public pure returns (address[] memory) {
        address[] memory arr = new address[](1);
        arr[0] = a;
        return arr;
    }

    function array(bytes32 a) public pure returns (bytes32[] memory) {
        bytes32[] memory arr = new bytes32[](1);
        arr[0] = a;
        return arr;
    }

    function array(bool a) public pure returns (bool[] memory) {
        bool[] memory arr = new bool[](1);
        arr[0] = a;
        return arr;
    }

    function array(uint256 a, uint256 b) public pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](2);
        arr[0] = a;
        arr[1] = b;
        return arr;
    }

    function array(address a, address b) public pure returns (address[] memory) {
        address[] memory arr = new address[](2);
        arr[0] = a;
        arr[1] = b;
        return arr;
    }

    function array(bytes32 a, bytes32 b) public pure returns (bytes32[] memory) {
        bytes32[] memory arr = new bytes32[](2);
        arr[0] = a;
        arr[1] = b;
        return arr;
    }

    function array(bool a, bool b) public pure returns (bool[] memory) {
        bool[] memory arr = new bool[](2);
        arr[0] = a;
        arr[1] = b;
        return arr;
    }

    function array(uint256 a, uint256 b, uint256 c) public pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](3);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        return arr;
    }

    function array(address a, address b, address c) public pure returns (address[] memory) {
        address[] memory arr = new address[](3);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        return arr;
    }

    function array(bytes32 a, bytes32 b, bytes32 c) public pure returns (bytes32[] memory) {
        bytes32[] memory arr = new bytes32[](3);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        return arr;
    }

    function array(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d
    ) public pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](4);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        return arr;
    }

    function array(
        address a,
        address b,
        address c,
        address d
    ) public pure returns (address[] memory) {
        address[] memory arr = new address[](4);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        return arr;
    }

    function array(
        bytes32 a,
        bytes32 b,
        bytes32 c,
        bytes32 d
    ) public pure returns (bytes32[] memory) {
        bytes32[] memory arr = new bytes32[](4);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        arr[3] = d;
        return arr;
    }

    function makeCharacterData(
        string memory handle,
        address to
    ) public pure returns (DataTypes.CreateCharacterData memory) {
        return DataTypes.CreateCharacterData(to, handle, CHARACTER_URI, address(0), "");
    }

    function makePostNoteData(
        uint256 characterId
    ) public pure returns (DataTypes.PostNoteData memory) {
        return DataTypes.PostNoteData(characterId, NOTE_URI, address(0), "", address(0), "", false);
    }

    function _matchNote(
        DataTypes.Note memory note,
        bytes32 linkItemType,
        bytes32 linkKey,
        string memory contentUri,
        address linkModule,
        address mintNFT,
        address mintModule,
        bool deleted,
        bool locked
    ) internal {
        assertEq(note.linkItemType, linkItemType);
        assertEq(note.linkKey, linkKey);
        assertEq(note.contentUri, contentUri);
        assertEq(note.linkModule, linkModule);
        assertEq(note.mintNFT, mintNFT);
        assertEq(note.mintModule, mintModule);
        assertEq(note.locked, locked);
        assertEq(note.deleted, deleted);
    }

    function _matchCharacter(
        DataTypes.Character memory character,
        uint256 characterId,
        string memory handle,
        string memory uri,
        uint256 noteCount,
        address socialToken,
        address linkModule
    ) internal {
        assertEq(character.characterId, characterId);
        assertEq(character.handle, handle);
        assertEq(character.uri, uri);
        assertEq(character.noteCount, noteCount);
        assertEq(character.socialToken, socialToken);
        assertEq(character.linkModule, linkModule);
    }
}
