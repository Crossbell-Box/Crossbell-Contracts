// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {
    ErrNotApprovedOrExceedApproval,
    ErrCallerNotWeb3Entry,
    ErrNotEnoughPermission
} from "../../../contracts/libraries/Error.sol";
import {CommonTest} from "../../helpers/CommonTest.sol";
import {DataTypes} from "../../../contracts/libraries/DataTypes.sol";
import {Events} from "../../../contracts/libraries/Events.sol";
import {IMintModule4Note} from "../../../contracts/interfaces/IMintModule4Note.sol";
import {IMintNFT} from "../../../contracts/interfaces/IMintNFT.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

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

    function testInitializeMintModule(uint256 approvedAmount) public {
        address[] memory approvedList = array(bob, carol);

        // initialize the mint module
        expectEmit(CheckAll);
        emit Events.SetApprovedMintAmount4Addresses(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            approvedAmount,
            approvedList
        );
        vm.prank(address(web3Entry));
        bytes memory result = IMintModule4Note(address(approvalMintModule)).initializeMintModule(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            abi.encode(approvedList, approvedAmount)
        );

        // check return value
        assertEq(result, abi.encode(approvedList, approvedAmount));

        // check approved info
        for (uint256 i = 0; i < approvedList.length; i++) {
            _checkApprovedInfo(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                approvedList[i],
                approvedAmount,
                0
            );
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

    function testSetApprovedAmount(uint256 approvedAmount) public {
        address[] memory approvedList = array(bob, carol);

        // alice set approved amount for bob and carol
        expectEmit(CheckAll);
        emit Events.SetApprovedMintAmount4Addresses(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            approvedAmount,
            approvedList
        );
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            approvedList,
            approvedAmount
        );

        // check approved amount
        for (uint256 i = 0; i < approvedList.length; i++) {
            _checkApprovedInfo(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                approvedList[i],
                approvedAmount,
                0
            );
        }
    }

    function testSetApprovedAmountWithNoteOperator(uint256 approvedAmount) public {
        address[] memory approvedList = array(bob, carol);

        // set dick as note operator
        vm.startPrank(alice);
        _postNoteWithMintModule(
            FIRST_CHARACTER_ID,
            NOTE_URI,
            address(approvalMintModule),
            abi.encode(new address[](0), 1)
        );
        web3Entry.grantOperators4Note(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            new address[](0),
            array(dick)
        );
        vm.stopPrank();

        // note operator set approved amount for bob and carol
        expectEmit(CheckAll);
        emit Events.SetApprovedMintAmount4Addresses(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            approvedAmount,
            approvedList
        );
        vm.prank(dick);
        approvalMintModule.setApprovedAmount(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            approvedList,
            approvedAmount
        );

        // check approved amount
        for (uint256 i = 0; i < approvedList.length; i++) {
            _checkApprovedInfo(
                FIRST_CHARACTER_ID,
                FIRST_NOTE_ID,
                approvedList[i],
                approvedAmount,
                0
            );
        }
    }

    function testSetApprovedAmountFail(uint256 amount) public {
        // caller is not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
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
        _checkApprovedInfo(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, approvedAmount, 1);
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
        _checkApprovedInfo(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, approvedAmount, 1);
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
            _checkApprovedInfo(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, approvedAmount, i);
        }
    }

    function testProcessMintFailNoApprovedAmount() public {
        // `bob` has no approvedAmount
        vm.prank(address(web3Entry));
        vm.expectRevert(abi.encodeWithSelector(ErrNotApprovedOrExceedApproval.selector));
        approvalMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
    }

    function testProcessMintFailExceedApprovedAmount(uint256 approvedAmount) public {
        vm.assume(approvedAmount < 100);

        // alice set approved amount
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(
            FIRST_CHARACTER_ID,
            FIRST_NOTE_ID,
            array(bob),
            approvedAmount
        );

        // processMint
        vm.startPrank(address(web3Entry));
        for (uint256 i = 0; i < approvedAmount; i++) {
            approvalMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
        }
        // exceed the approved amount
        vm.expectRevert(abi.encodeWithSelector(ErrNotApprovedOrExceedApproval.selector));
        approvalMintModule.processMint(bob, FIRST_CHARACTER_ID, FIRST_NOTE_ID, "");
        vm.stopPrank();

        // check approved info
        _checkApprovedInfo(FIRST_CHARACTER_ID, FIRST_NOTE_ID, bob, approvedAmount, approvedAmount);
    }

    function testProcessMintFailUnAuthorized() public {
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
            _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList[i], "");

            _checkApprovedInfo(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList[i], 1, 1);
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

            _checkApprovedInfo(FIRST_CHARACTER_ID, FIRST_NOTE_ID, approvedList[i], 1, 1);
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

    function testMintNoteFailWithApprovalMintModuleInitNoApprovedAmount() public {
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
        vm.expectRevert(abi.encodeWithSelector(ErrNotApprovedOrExceedApproval.selector));
        _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, alice, "");
    }

    function testMintNoteFailWithApprovalMintModuleSetApprovedAmount() public {
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

        vm.expectRevert(abi.encodeWithSelector(ErrNotApprovedOrExceedApproval.selector));
        _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, carol, "");
    }

    function testMintFailWithMintNoteNFT() public {
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

    function _checkApprovedInfo(
        uint256 characterId,
        uint256 noteId,
        address account,
        uint256 expectedApprovedAmount,
        uint256 expectedMintedAmount
    ) internal {
        // check approved amount of `account`
        (uint256 approvedAmount, uint256 mintedAmount) = approvalMintModule.getApprovedInfo(
            characterId,
            noteId,
            account
        );
        assertEq(approvedAmount, expectedApprovedAmount);
        assertEq(expectedMintedAmount, mintedAmount);
    }
}
