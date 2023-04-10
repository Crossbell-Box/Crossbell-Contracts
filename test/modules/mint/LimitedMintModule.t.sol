// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {
    ErrExceedMaxSupply,
    ErrExceedApproval,
    ErrCallerNotWeb3Entry,
    ErrNotCharacterOwner
} from "../../../contracts/libraries/Error.sol";
import {CommonTest} from "../../helpers/CommonTest.sol";
import {DataTypes} from "../../../contracts/libraries/DataTypes.sol";
import {Events} from "../../../contracts/libraries/Events.sol";
import {IMintModule4Note} from "../../../contracts/interfaces/IMintModule4Note.sol";
import {IMintNFT} from "../../../contracts/interfaces/IMintNFT.sol";
import {LimitedMintModule} from "../../../contracts/modules/mint/LimitedMintModule.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract LimitedMintModuleTest is CommonTest {
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testSetupState() public {
        assertEq(limitedMintModule.web3Entry(), address(web3Entry));
    }

    function testInitializeMintModule(uint256 maxSupply, uint256 approvedAmount) public {
        // initialize the mint module
        vm.prank(address(web3Entry));
        bytes memory result = IMintModule4Note(address(limitedMintModule)).initializeMintModule(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            abi.encode(maxSupply, approvedAmount)
        );

        // check return value
        assertEq(result, abi.encode(maxSupply, approvedAmount));

        // check mint info
        _checkLimitedMintInfo(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            bob,
            maxSupply,
            0,
            approvedAmount,
            0
        );
    }

    function testInitializeMintModuleFail() public {
        // caller is not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        IMintModule4Note(address(limitedMintModule)).initializeMintModule(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            ""
        );
    }

    function testProcessMintWithInitializeMintModule(
        uint256 maxSupply,
        uint256 approvedAmount
    ) public {
        vm.assume(approvedAmount > 0 && approvedAmount < 10);
        vm.assume(maxSupply > approvedAmount);

        // initialize the mint module
        vm.prank(address(web3Entry));
        IMintModule4Note(address(limitedMintModule)).initializeMintModule(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            abi.encode(maxSupply, approvedAmount)
        );

        // processMint
        vm.prank(address(web3Entry));
        limitedMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");

        // check mint info
        _checkLimitedMintInfo(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            bob,
            maxSupply,
            1,
            approvedAmount,
            1
        );
    }

    function testProcessMintMultiple(uint256 maxSupply, uint256 approvedAmount) public {
        vm.assume(approvedAmount > 0 && approvedAmount < 10);
        vm.assume(maxSupply > approvedAmount);

        // initialize the mint module
        vm.startPrank(address(web3Entry));
        IMintModule4Note(address(limitedMintModule)).initializeMintModule(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            abi.encode(maxSupply, approvedAmount)
        );

        // processMint
        for (uint256 i = 1; i < approvedAmount; i++) {
            limitedMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");

            // check state: approvedAmount decreases by 1 after every processMint
            _checkLimitedMintInfo(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                bob,
                maxSupply,
                i,
                approvedAmount,
                i
            );
        }
        vm.stopPrank();
    }

    function testProcessMintFailNoApprovedAmount() public {
        // initialize the mint module
        vm.startPrank(address(web3Entry));
        IMintModule4Note(address(limitedMintModule)).initializeMintModule(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            abi.encode(100, 0)
        );

        vm.expectRevert(abi.encodeWithSelector(ErrExceedApproval.selector));
        limitedMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
        vm.stopPrank();
    }

    function testProcessMintFailUnAuthorized() public {
        // only web3Entry can call processMint
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        limitedMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
    }

    function testProcessMintFailExceedMaxSupply(uint256 maxSupply) public {
        vm.assume(maxSupply < 20);

        // initialize the mint module
        vm.startPrank(address(web3Entry));
        IMintModule4Note(address(limitedMintModule)).initializeMintModule(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            abi.encode(maxSupply, maxSupply)
        );

        for (uint256 i = 0; i < maxSupply; i++) {
            limitedMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
        }

        vm.expectRevert(abi.encodeWithSelector(ErrExceedMaxSupply.selector));
        limitedMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
    }

    function testMintNoteWithMintModule() public {
        // alice post a note with approvalMintModule
        vm.prank(alice);
        _postNoteWithMintModule(
            FIRST_CHARACTER_ID,
            NOTE_URI,
            address(limitedMintModule),
            abi.encode(100, 1)
        );

        _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, "");
        // check mint info
        _checkLimitedMintInfo(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, 100, 1, 1, 1);

        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        address nftAddress = note.mintNFT;
        assertEq(IERC721Metadata(nftAddress).name(), "Note-1-1");
        assertEq(IERC721Metadata(nftAddress).symbol(), "Note-1-1");
        // check total supply
        assertEq(IERC721Enumerable(nftAddress).totalSupply(), 1);
        //check token URI
        assertEq(IERC721Metadata(nftAddress).tokenURI(1), NOTE_URI);
    }

    function _checkLimitedMintInfo(
        uint256 characterId,
        uint256 noteId,
        address account,
        uint256 expectedMaxSupply,
        uint256 expectedCurrentSupply,
        uint256 expectedApprovedAmount,
        uint256 expectedMintedAmount
    ) internal {
        // check approved amount of `account`
        (
            uint256 maxSupply,
            uint256 currentSupply,
            uint256 approvedAmount,
            uint256 mintedAmount
        ) = limitedMintModule.getLimitedMintInfo(characterId, noteId, account);

        assertEq(maxSupply, expectedMaxSupply);
        assertEq(currentSupply, expectedCurrentSupply);
        assertEq(approvedAmount, expectedApprovedAmount);
        assertEq(mintedAmount, expectedMintedAmount);
    }
}
