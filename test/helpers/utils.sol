// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";
import "../../contracts/libraries/DataTypes.sol";
import "./Const.sol";

contract Utils is Test {
    uint8 public constant CheckTopic1 = 0x1;
    uint8 public constant CheckTopic2 = 0x2;
    uint8 public constant CheckTopic3 = 0x4;
    uint8 public constant CheckData = 0x8;

    /* solhint-disable comprehensive-interface */
    function expectEmit() public {
        expectEmit(0);
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

    function makeCharacterData(string memory handle, address to)
        public
        pure
        returns (DataTypes.CreateCharacterData memory)
    {
        DataTypes.CreateCharacterData memory characterData = DataTypes.CreateCharacterData(
            to,
            handle,
            Const.MOCK_CHARACTER_URI,
            address(0),
            ""
        );
        return characterData;
    }

    function makePostNoteData(uint256 characterId)
        public
        pure
        returns (DataTypes.PostNoteData memory)
    {
        DataTypes.PostNoteData memory postNoteData = DataTypes.PostNoteData(
            characterId,
            Const.MOCK_NOTE_URI,
            Const.AddressZero,
            new bytes(0),
            Const.AddressZero,
            new bytes(0),
            false
        );
        return postNoteData;
    }

    function matchNote(
        DataTypes.Note memory note,
        bytes32 linkItemType,
        bytes32 linkKey,
        string memory contentUri,
        address linkModule,
        address mintNFT,
        address mintModule,
        bool deleted,
        bool locked
    ) public {
        assertEq(note.linkItemType, linkItemType);
        assertEq(note.linkKey, linkKey);
        assertEq(note.contentUri, contentUri);
        assertEq(note.linkModule, linkModule);
        assertEq(note.mintNFT, mintNFT);
        assertEq(note.mintModule, mintModule);
        assertEq(note.locked, locked);
        assertEq(note.deleted, deleted);
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

    function array(
        uint256 a,
        uint256 b,
        uint256 c
    ) public pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](3);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        return arr;
    }

    function array(
        address a,
        address b,
        address c
    ) public pure returns (address[] memory) {
        address[] memory arr = new address[](3);
        arr[0] = a;
        arr[1] = b;
        arr[2] = c;
        return arr;
    }

    function array(
        bytes32 a,
        bytes32 b,
        bytes32 c
    ) public pure returns (bytes32[] memory) {
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
}
