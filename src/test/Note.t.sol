// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../Web3Entry.sol";
import "../libraries/DataTypes.sol";
import "../Web3Entry.sol";
import "../upgradeability/TransparentUpgradeableProxy.sol";
import "./EmitExpecter.sol";
import "./Const.sol";
import "./helpers/utils.sol";
import "./Const.sol";

contract NoteTest is Test, EmitExpecter, Utils {
    Web3Entry web3Entry;

    address public alice = address(0x1111);
    address public bob = address(0x2222);

    function setUp() public {
        Web3Entry web3EntryImpl = new Web3Entry();
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(web3EntryImpl),
            alice,
            ""
        );
        web3Entry = Web3Entry(address(proxy));

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testPostNoteFail() public {
        vm.expectRevert(abi.encodePacked("NotCharacterOwner"));
        web3Entry.postNote(makePostNoteData(Const.FIRST_NOTE_ID));
    }
}
