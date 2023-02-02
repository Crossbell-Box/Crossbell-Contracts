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
    uint8 public constant CheckAll = 0xf;

    function expectEmit() public {
        expectEmit(CheckAll);
    }

    function expectEmit(uint8 checks) public {
        require(checks < 16, "Invalid emitOptions passed to expectEmit");

        uint8 mask = 0x1; //0001
        bool checkTopic1 = (checks & mask) > 0;
        bool checkTopic2 = (checks & (mask << 1)) > 0;
        bool checkTopic3 = (checks & (mask << 2)) > 0;
        bool checkData = (checks & (mask << 3)) > 0;

        vm.expectEmit(checkTopic1, checkTopic2, checkTopic3, checkData);
    }

    function makeCharacterData(string memory _handle, address _to)
        public
        pure
        returns (DataTypes.CreateCharacterData memory)
    {
        DataTypes.CreateCharacterData memory characterData = DataTypes.CreateCharacterData(
            _to,
            _handle,
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
}
