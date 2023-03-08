// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../../../contracts/MintNFT.sol";
import "../../../contracts/libraries/Error.sol";
import "../../helpers/Const.sol";
import "../../helpers/utils.sol";
import "../../helpers/SetUp.sol";
import "../../../contracts/libraries/Events.sol";

contract ApprovalMintModuleTest is Test, Utils, SetUp {
    address[] public addressList1 = [alice, bob];
    address[] public addressList2 = [carol];

    function setUp() public {
        _setUp();
        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    // solhint-disable-next-line function-max-lines
    function testMintNoteWithMintModule() public {
        // alice post a note with approvalMintModule
        expectEmit(CheckAll);
        emit Events.SetMintModule4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            address(approvalMintModule),
            abi.encode(addressList1),
            block.timestamp
        );
        vm.prank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.MOCK_NOTE_URI,
                address(0x0),
                new bytes(0),
                address(approvalMintModule),
                abi.encode(addressList1),
                false
            )
        );

        // approved addresses in init can mint
        web3Entry.mintNote(
            DataTypes.MintNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                alice,
                new bytes(0)
            )
        );
        web3Entry.mintNote(
            DataTypes.MintNoteData(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, bob, new bytes(0))
        );

        // addresses approved by calling 'approve' can
        // alice approve carol
        bool[] memory boolList = new bool[](1);
        boolList[0] = true;
        vm.prank(alice);
        ApprovalMintModule(address(approvalMintModule)).approve(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            addressList2,
            boolList
        );
        // carol can mint
        web3Entry.mintNote(
            DataTypes.MintNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                carol,
                new bytes(0)
            )
        );
    }

    // solhint-disable-next-line function-max-lines
    function testMintNoteWithMintModuleFail() public {
        // alice post a note with approvalMintModule
        vm.prank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.MOCK_NOTE_URI,
                address(0x0),
                new bytes(0),
                address(approvalMintModule),
                abi.encode(addressList1),
                false
            )
        );

        // addresses without approval can't mint
        vm.expectRevert(abi.encodeWithSelector(ApprovalMintModule.ErrNotApproved.selector));
        web3Entry.mintNote(
            DataTypes.MintNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                carol,
                new bytes(0)
            )
        );
        vm.expectRevert(abi.encodeWithSelector(ApprovalMintModule.ErrNotApproved.selector));
        web3Entry.mintNote(
            DataTypes.MintNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                dick,
                new bytes(0)
            )
        );
    }
}
