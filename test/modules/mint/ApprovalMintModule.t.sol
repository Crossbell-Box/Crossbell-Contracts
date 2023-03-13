// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {
    ErrNotApproved,
    ErrCallerNotWeb3Entry,
    ErrNotCharacterOwner
} from "../../../contracts/libraries/Error.sol";
import {CommonTest} from "../../helpers/CommonTest.sol";
import {DataTypes} from "../../../contracts/libraries/DataTypes.sol";
import {Events} from "../../../contracts/libraries/Events.sol";
import {IMintModule4Note} from "../../../contracts/interfaces/IMintModule4Note.sol";
import {IMintNFT} from "../../../contracts/interfaces/IMintNFT.sol";
import {ApprovalMintModule} from "../../../contracts/modules/mint/ApprovalMintModule.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ApprovalMintModuleTest is CommonTest {
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testSetupState() public {
        assertEq(approvalMintModule.web3Entry(), address(web3Entry));
    }

    function testInitializeMintModule(uint256 amount) public {
        address[] memory approvedList = array(bob, carol);

        // initialize the mint module
        expectEmit(CheckAll);
        emit Events.SetApprovedMintAmount4Addresses(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            amount,
            approvedList
        );
        vm.prank(address(web3Entry));
        bytes memory result = IMintModule4Note(address(approvalMintModule)).initializeMintModule(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            abi.encode(approvedList, amount)
        );

        // check return value
        assertEq(result, abi.encode(approvedList, amount));

        // check approved amount
        for (uint256 i = 0; i < approvedList.length; i++) {
            _checkApprovedAmount(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList[i], amount);
        }
    }

    function testInitializeMintModuleFail() public {
        // caller is not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        IMintModule4Note(address(approvalMintModule)).initializeMintModule(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            ""
        );
    }

    function testSetApprovedAmount(uint256 amount) public {
        address[] memory approvedList = array(bob, carol);

        // alice set approved amount for bob and carol
        expectEmit(CheckAll);
        emit Events.SetApprovedMintAmount4Addresses(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            amount,
            approvedList
        );
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            approvedList,
            amount
        );

        // check approved amount
        for (uint256 i = 0; i < approvedList.length; i++) {
            _checkApprovedAmount(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList[i], amount);
        }
    }

    function testSetApprovedAmountFail(uint256 amount) public {
        // caller is not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrNotCharacterOwner.selector));
        approvalMintModule.setApprovedAmount(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            array(carol),
            amount
        );
    }

    function testProcessMintWithInitializeMintModule(uint256 approvedAmount) public {
        vm.assume(approvedAmount > 0);

        // initialize the mint module
        vm.prank(address(web3Entry));
        IMintModule4Note(address(approvalMintModule)).initializeMintModule(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            abi.encode(array(bob), approvedAmount)
        );

        // processMint
        vm.prank(address(web3Entry));
        approvalMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");

        // check approvedAmount
        _checkApprovedAmount(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, approvedAmount - 1);
    }

    function testProcessMintWithSetApprovedAmount(uint256 approvedAmount) public {
        vm.assume(approvedAmount > 0);

        // set approved amount
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            array(bob),
            approvedAmount
        );

        // processMint
        vm.prank(address(web3Entry));
        approvalMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");

        // check approvedAmount
        _checkApprovedAmount(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, approvedAmount - 1);
    }

    function testProcessMintMultiple(uint256 approvedAmount) public {
        vm.assume(approvedAmount < 100);
        vm.assume(0 < approvedAmount);

        // set approved amount
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            array(bob),
            approvedAmount
        );

        // processMint
        for (uint256 i = 1; i < approvedAmount; i++) {
            vm.prank(address(web3Entry));
            approvalMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");

            // check state: approvedAmount decreases by 1 after every processMint
            _checkApprovedAmount(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, approvedAmount - i);
        }
    }

    function testProcessMintNoApprovedAmountFail() public {
        // `bob` has no approvedAmount
        vm.prank(address(web3Entry));
        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        approvalMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
    }

    function testProcessMintExceedApprovedAmountFail(uint256 amount) public {
        vm.assume(amount < 100);

        // alice set approved amount
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(FIRST_CHARACTER_ID, FIRST_NOTE_ID, array(bob), amount);

        // processMint
        vm.startPrank(address(web3Entry));
        for (uint256 i = 0; i < amount; i++) {
            approvalMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
        }
        // exceed the approved amount
        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        approvalMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
        vm.stopPrank();
    }

    function testProcessMintUnAuthorizedFail() public {
        // only web3Entry can call processMint
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        approvalMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
    }

    function testMintNoteWithMintModuleInit() public {
        address[] memory approvedList = array(bob, carol);

        // alice post a note with approvalMintModule
        vm.prank(alice);
        _postNoteWithMintModule(
            FIRST_CHARACTER_ID,
            NOTE_URI,
            address(approvalMintModule),
            abi.encode(approvedList, 1)
        );

        // alice and bob in approvedAddrs can mint note
        for (uint256 i = 0; i < approvedList.length; i++) {
            _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList[i], new bytes(0));

            _checkApprovedAmount(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList[i], 0);
        }

        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        address nftAddress = note.mintNFT;
        assertEq(IERC721Metadata(nftAddress).name(), "Note-1-1");
        assertEq(IERC721Metadata(nftAddress).symbol(), "Note-1-1");
        // check total supply
        assertEq(IERC721Enumerable(nftAddress).totalSupply(), 2);
        //check token URI
        assertEq(IERC721Metadata(nftAddress).tokenURI(1), NOTE_URI);
        assertEq(IERC721Metadata(nftAddress).tokenURI(2), NOTE_URI);
    }

    function testMintNoteWithMintModuleSetApprovedAmount() public {
        address[] memory approvedList = array(bob, carol);

        // alice post a note with approvalMintModule
        vm.prank(alice);
        _postNoteWithMintModule(FIRST_CHARACTER_ID, NOTE_URI, address(approvalMintModule), "");

        // alice setApprovedAmount
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList, 1);

        // alice and bob in approvedList can mint note
        for (uint256 i = 0; i < approvedList.length; i++) {
            _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList[i], "");

            _checkApprovedAmount(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList[i], 0);
        }

        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        address nftAddress = note.mintNFT;
        assertEq(IERC721Metadata(nftAddress).name(), "Note-1-1");
        assertEq(IERC721Metadata(nftAddress).symbol(), "Note-1-1");
        // check total supply
        assertEq(IERC721Enumerable(nftAddress).totalSupply(), 2);
        //check token URI
        assertEq(IERC721Metadata(nftAddress).tokenURI(1), NOTE_URI);
        assertEq(IERC721Metadata(nftAddress).tokenURI(2), NOTE_URI);
    }

    function testMintNoteWithApprovalMintModuleInitNoApprovedAmountFail() public {
        address[] memory approvedList = array(carol);

        // alice post a note with approvalMintModule
        vm.prank(alice);
        _postNoteWithMintModule(
            FIRST_CHARACTER_ID,
            NOTE_URI,
            address(approvalMintModule),
            abi.encode(approvedList, 1)
        );

        //  alice with no approved amount can't mint note
        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, alice, "");
    }

    function testMintNoteWithApprovalMintModuleSetApprovedAmountFail() public {
        address[] memory approvedList = array(carol);

        // alice post a note with approvalMintModule
        vm.prank(alice);
        _postNoteWithMintModule(
            FIRST_CHARACTER_ID,
            NOTE_URI,
            address(approvalMintModule),
            abi.encode(approvedList, 1)
        );

        // set approvedAmount as 0
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList, 0);

        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, carol, "");
    }

    function testMintWithMintNoteNFTFail() public {
        address[] memory approvedList = array(carol);

        // alice post a note with approvalMintModule
        vm.prank(alice);
        _postNoteWithMintModule(
            FIRST_CHARACTER_ID,
            NOTE_URI,
            address(approvalMintModule),
            abi.encode(approvedList, 1)
        );

        // carol mint note
        _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, carol, "");

        //  can only mint through web3Entry
        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        address noteNft = note.mintNFT;
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        IMintNFT(address(noteNft)).mint(bob);
    }

    function testInitializeMintNFTFail() public {
        address[] memory approvedList = array(bob, carol);

        vm.prank(alice);
        _postNoteWithMintModule(
            FIRST_CHARACTER_ID,
            NOTE_URI,
            address(approvalMintModule),
            abi.encode(approvedList, 1)
        );

        // approved addresses in init can mint (mintNFT is initialized)
        _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, "");

        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        address noteNft = note.mintNFT;
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        IMintNFT(noteNft).initialize(1, 1, address(web3Entry), "name", "symbol");
    }

    function _checkApprovedAmount(
        uint256 characterId,
        uint256 noteId,
        address account,
        uint256 expectedAmount
    ) internal {
        // check approved amount of `account`
        assertEq(
            approvalMintModule.getApprovedAmount(characterId, noteId, account),
            expectedAmount
        );
    }
}
