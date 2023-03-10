// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {Test} from "forge-std/Test.sol";
import {
    ErrNotApproved,
    ErrCallerNotWeb3Entry,
    ErrNotCharacterOwner
} from "../../../contracts/libraries/Error.sol";
import {Const} from "../../helpers/Const.sol";
import {Utils} from "../../helpers/Utils.sol";
import {SetUp} from "../../helpers/SetUp.sol";
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

contract ApprovalMintModuleTest is Test, Utils, SetUp {
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testProcessMint(uint256 approvedAmount) public {
        vm.assume(approvedAmount < 100);
        vm.assume(0 < approvedAmount);

        // set approved amount
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            array(bob),
            approvedAmount
        );

        // processMint
        for (uint256 i = 1; i < approvedAmount; i++) {
            vm.prank(address(web3Entry));
            approvalMintModule.processMint(bob, Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, "");

            uint256 currentApprovedAmount = approvalMintModule.getApprovedAmount(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                bob
            );

            // check state: approvedAmount decreases by 1 after every processMint
            assertEq(currentApprovedAmount, approvedAmount - i);
        }
    }

    function testProcessMintFail(uint256 amount) public {
        vm.assume(amount < 100);
        vm.assume(0 < amount);

        // case 1: not approved can't process mint
        vm.startPrank(address(web3Entry));
        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        approvalMintModule.processMint(bob, Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, "");
        vm.stopPrank();

        // case 2: can't exceed the approved amount
        // alice set approved amount
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            array(bob),
            amount
        );
        // processMint
        vm.startPrank(address(web3Entry));
        for (uint256 i = 0; i < amount; i++) {
            approvalMintModule.processMint(bob, Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, "");
        }
        // exceed the approved amount
        vm.expectRevert(abi.encodeWithSelector(ErrNotApproved.selector));
        approvalMintModule.processMint(bob, Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, "");
        vm.stopPrank();

        // cese 3: only web3Entry can call processMint
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        approvalMintModule.processMint(bob, Const.FIRST_CHARACTER_ID, Const.FIRST_NOTE_ID, "");
    }

    function testInitializeMintNFTFail(uint256 amount) public {
        vm.assume(amount < 100);
        vm.assume(0 < amount);

        // post note
        vm.prank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.MOCK_NOTE_URI,
                address(0x0),
                new bytes(0),
                address(approvalMintModule),
                abi.encode(array(alice, bob), amount),
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

    function testInitializeMintModule(uint256 amount) public {
        vm.assume(amount < 100);

        vm.prank(address(web3Entry));
        IMintModule4Note(address(approvalMintModule)).initializeMintModule(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            abi.encode(array(alice), amount)
        );

        // check state
        assertEq(
            approvalMintModule.getApprovedAmount(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                alice
            ),
            amount
        );
    }

    function testInitializeMintModuleFail() public {
        // only web3Entry can initialize
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        IMintModule4Note(address(approvalMintModule)).initializeMintModule(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            ""
        );
    }

    function testSetApprovedAmount(uint256 amount) public {
        vm.assume(amount < 100);

        vm.prank(alice);
        approvalMintModule.setApprovedAmount(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            array(bob),
            amount
        );
        // check state
        assertEq(
            approvalMintModule.getApprovedAmount(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                bob
            ),
            amount
        );
    }

    function testSetApprovedAmountFail(uint256 amount) public {
        vm.assume(amount < 100);

        // not web3Entry can't approve
        vm.expectRevert(abi.encodeWithSelector(ErrNotCharacterOwner.selector));
        approvalMintModule.setApprovedAmount(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            array(carol),
            amount
        );
    }

    // solhint-disable-next-line function-max-lines
    function testMintNoteWithApprovalMintModule() public {
        // alice post a note with approvalMintModule
        vm.prank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.MOCK_NOTE_URI,
                address(0x0),
                new bytes(0),
                address(approvalMintModule),
                abi.encode(array(alice, bob), 1),
                false
            )
        );

        // case 1: approved addresses in init can mint
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

        // case 2: addresses approved by calling 'setApprovedAmount' can
        // alice approve carol
        vm.prank(alice);
        approvalMintModule.setApprovedAmount(
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
        // the approved amount of alice and bob should be 0 after minting
        address[] memory addrs = array(alice, bob, carol);
        for (uint256 i = 0; i < addrs.length; i++) {
            assertEq(
                approvalMintModule.getApprovedAmount(
                    Const.FIRST_CHARACTER_ID,
                    Const.FIRST_NOTE_ID,
                    addrs[i]
                ),
                0
            );
        }

        // check note's mint NFT address
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        address noteNft = note.mintNFT;
        // check symbol and symbol
        assertEq(IERC721Metadata(noteNft).name(), "Note-1-1");
        assertEq(IERC721Metadata(noteNft).symbol(), "Note-1-1");
        // check total supply
        assertEq(IERC721Enumerable(noteNft).totalSupply(), 3);
        // check minted NFT
        assertEq(IERC721(noteNft).balanceOf(alice), 1);
        assertEq(IERC721(noteNft).balanceOf(bob), 1);
        assertEq(IERC721(noteNft).balanceOf(carol), 1);
        //check token URI
        assertEq(IERC721Metadata(noteNft).tokenURI(1), Const.MOCK_NOTE_URI);
        assertEq(IERC721Metadata(noteNft).tokenURI(2), Const.MOCK_NOTE_URI);
        assertEq(IERC721Metadata(noteNft).tokenURI(3), Const.MOCK_NOTE_URI);
        assertEq(IERC721Metadata(noteNft).tokenURI(4), "");
    }

    // solhint-disable-next-line function-max-lines
    function testMintNoteWithApprovalMintModuleFail() public {
        // alice post a note with approvalMintModule
        vm.prank(alice);
        web3Entry.postNote(
            DataTypes.PostNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.MOCK_NOTE_URI,
                address(0x0),
                new bytes(0),
                address(approvalMintModule),
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
        approvalMintModule.setApprovedAmount(
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
