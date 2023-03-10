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
import {IMintModule4Note} from "../../../contracts/interfaces/IMintModule4Note.sol";
import {IMintNFT} from "../../../contracts/interfaces/IMintNFT.sol";
import {ApprovalMintModule} from "../../../contracts/modules/mint/ApprovalMintModule.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract ApprovalWithAmountMintModuleTest is Test, Utils, SetUp {
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    // solhint-disable-next-line function-max-lines
    function testProcessMint(uint256 approvedAmount) public {
        // case 1: approved addresses in initialization get 1 approved amount
        vm.prank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.MOCK_NOTE_URI,
                address(0x0),
                new bytes(0),
                address(approvalWithAmountMintModule),
                abi.encode(array(alice, bob)),
                false
            )
        );
        // approved addresses can process mint
        vm.startPrank(address(web3Entry));
        ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).processMint(
            alice,
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            ""
        );
        ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).processMint(
            bob,
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            ""
        );
        vm.stopPrank();

        // case 2: set custom approved amount
        vm.prank(alice);
        vm.assume(approvedAmount < 100);
        ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).setApprovedAmount(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            array(bob),
            approvedAmount
        );
        for (uint256 i = 0; i < approvedAmount; i++) {
            vm.prank(address(web3Entry));
            ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).processMint(
                bob,
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                ""
            );
            // bob mints one NFT, and approvedAmount decreases by 1
            web3Entry.mintNote(
                DataTypes.MintNoteData(
                    Const.FIRST_CHARACTER_ID,
                    Const.FIRST_NOTE_ID,
                    bob,
                    new bytes(0)
                )
            );
        }
    }

    function testProcessMintFail() public {
        // case 1: not approved can't process mint
        vm.startPrank(address(web3Entry));
        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).processMint(
            alice,
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            ""
        );
        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).processMint(
            bob,
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            ""
        );
        vm.stopPrank();

        // cese 2: only web3Entry can call processMint
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).processMint(
            bob,
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            ""
        );
    }

    function testInitializeMintNFTFail() public {
        vm.prank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.MOCK_NOTE_URI,
                address(0x0),
                new bytes(0),
                address(approvalWithAmountMintModule),
                abi.encode(array(alice, bob)),
                false
            )
        );
        // approved addresses in init can mint (mintNFT is initialized)
        web3Entry.mintNote(
            DataTypes.MintNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                alice,
                new bytes(0)
            )
        );

        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        address noteNft = note.mintNFT;
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        IMintNFT(noteNft).initialize(1, 1, address(web3Entry), "name", "symbol");
    }

    function testInitializeMintModule() public {
        vm.prank(address(web3Entry));
        IMintModule4Note(address(approvalWithAmountMintModule)).initializeMintModule(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            abi.encode(array(alice, bob))
        );

        // check state
        assertEq(
            ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).getApprovedAmount(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                alice
            ),
            1
        );
        assertEq(
            ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).getApprovedAmount(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                bob
            ),
            1
        );
    }

    function testInitializeMintModuleFail() public {
        // only web3Entry can initialize
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        IMintModule4Note(address(approvalWithAmountMintModule)).initializeMintModule(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            ""
        );
    }

    function testSetApprovedAmount(uint256 amount) public {
        vm.assume(amount < 100);
        vm.startPrank(alice);
        ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).setApprovedAmount(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            array(alice),
            amount
        );
        // check state
        assertEq(
            ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).getApprovedAmount(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                alice
            ),
            amount
        );
    }

    function testSetApprovedAmountFail(uint256 amount) public {
        vm.assume(amount < 100);
        // not owner can't approve
        vm.expectRevert(abi.encodeWithSelector(ErrNotCharacterOwner.selector));
        vm.prank(bob);
        ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).setApprovedAmount(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            array(carol),
            amount
        );
    }

    // solhint-disable-next-line function-max-lines
    function testMintNoteWithApprovalWithAmountMintModule() public {
        // alice post a note with approvalWithAmountMintModule
        expectEmit(CheckAll);
        emit Events.SetMintModule4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            address(approvalWithAmountMintModule),
            abi.encode(array(alice, bob)),
            block.timestamp
        );
        expectEmit(CheckAll);
        emit Events.PostNote(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, 0, 0, new bytes(0));
        vm.prank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.MOCK_NOTE_URI,
                address(0x0),
                new bytes(0),
                address(approvalWithAmountMintModule),
                abi.encode(array(alice, bob)),
                false
            )
        );

        // case 1: approved addresses in init can mint
        expectEmit(CheckAll);
        emit Events.MintNFTInitialized(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            block.timestamp
        );
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

        // case 2: addresses approved by calling 'approve' can
        // alice approve carol
        vm.prank(alice);
        ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).setApprovedAmount(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            array(carol),
            1
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

        // check state
        // addresses in addressList1  are approved
        for (uint256 i = 0; i < array(alice, bob).length; i++) {
            assertEq(
                ApprovalWithAmountMintModule(address(approvalWithAmountMintModule))
                    .getApprovedAmount(
                        Const.FIRST_CHARACTER_ID,
                        Const.FIRST_NOTE_ID,
                        array(alice, bob)[i]
                    ),
                1
            );
        }

        // check note's mint NFT address
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        address noteNft = note.mintNFT;

        // check symbol and symbol
        string memory symbol = string.concat(
            "Note-",
            "1", // character Id
            "-",
            "1" // note Id
        );
        assertEq(IERC721Metadata(address(noteNft)).name(), symbol);
        assertEq(IERC721Metadata(address(noteNft)).symbol(), symbol);
        // check minted NFT
        assertEq(IERC721(address(noteNft)).balanceOf(alice), 1);
        assertEq(IERC721(address(noteNft)).balanceOf(bob), 1);
        assertEq(IERC721(address(noteNft)).balanceOf(carol), 1);
        // check total supply
        assertEq(IERC721Enumerable(address(noteNft)).totalSupply(), 3);
        //check token URI
        assertEq(IERC721Metadata(address(noteNft)).tokenURI(1), Const.MOCK_NOTE_URI);
        assertEq(IERC721Metadata(address(noteNft)).tokenURI(2), Const.MOCK_NOTE_URI);
        assertEq(IERC721Metadata(address(noteNft)).tokenURI(3), Const.MOCK_NOTE_URI);
        assertEq(IERC721Metadata(address(noteNft)).tokenURI(4), "");
    }

    // solhint-disable-next-line function-max-lines
    function testMintNoteWithApprovalWithAmountMintModuleFail() public {
        // alice post a note with approvalWithAmountMintModule
        vm.prank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.MOCK_NOTE_URI,
                address(0x0),
                new bytes(0),
                address(approvalWithAmountMintModule),
                abi.encode(array(carol)),
                false
            )
        );

        // case 1: addresses without approval can't mint
        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        web3Entry.mintNote(
            DataTypes.MintNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                alice,
                new bytes(0)
            )
        );
        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        web3Entry.mintNote(
            DataTypes.MintNoteData(Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, bob, new bytes(0))
        );

        // case 2: addresses with cancelled approval can't mint
        // carol can't mint after alice cancelling approval
        // carol can mint before cancelling
        web3Entry.mintNote(
            DataTypes.MintNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                carol,
                new bytes(0)
            )
        );
        vm.prank(alice);
        ApprovalWithAmountMintModule(address(approvalWithAmountMintModule)).setApprovedAmount(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            array(carol),
            0
        );
        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        web3Entry.mintNote(
            DataTypes.MintNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                carol,
                new bytes(0)
            )
        );

        // case 3: can only mint through web3Entry
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        address noteNft = note.mintNFT;
        vm.prank(address(alice));
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        IMintNFT(address(noteNft)).mint(alice);
    }
}
