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

    function testInitializeMintModule() public {
        vm.prank(address(web3Entry));
        // call initializeMintModule
    }

    function testInitializeMintModuleFail() public {
        vm.prank(address(web3Entry));
    }

    function testApprove() public {
        vm.prank(address(web3Entry));
    }

    function testApproveFail() public {
        vm.prank(address(web3Entry));
    }

    function testProcessMint() public {
        vm.prank(address(web3Entry));
    }

    function testProcessMintFail() public {
        vm.prank(address(web3Entry));
    }

    // solhint-disable-next-line function-max-lines
    function testMintNoteWithApprovalMintModule() public {
        // alice post a note with approvalMintModule
        expectEmit(CheckAll);
        emit Events.SetMintModule4Note(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            address(approvalMintModule),
            abi.encode(addressList1),
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
                address(approvalMintModule),
                abi.encode(addressList1),
                false
            )
        );

        // approved addresses in init can mint
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

        // check state
        // addresses in addressList1  are approved
        for (uint256 i = 0; i < addressList1.length; i++) {
            assert(
                ApprovalMintModule(address(approvalMintModule)).isApproved(
                    Const.FIRST_CHARACTER_ID,
                    Const.FIRST_NOTE_ID,
                    addressList1[i]
                )
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
                abi.encode(addressList2),
                false
            )
        );

        // addresses without approval can't mint
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

        // addresses with cancelled approval can't mint
        bool[] memory boolList = new bool[](1);
        boolList[0] = false;
        // carol can mint first
        web3Entry.mintNote(
            DataTypes.MintNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                carol,
                new bytes(0)
            )
        );
        // carol can't mint after alice cancelling approval
        vm.prank(alice);
        ApprovalMintModule(address(approvalMintModule)).approve(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            addressList2,
            boolList
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

        // can only mint through web3entry
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        address noteNft = note.mintNFT;
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        vm.prank(address(alice));
        IMintNFT(address(noteNft)).mint(alice);
    }

    function testInitializeMintNFTFail() public {
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

        // can't initialize twice
        DataTypes.Note memory note = web3Entry.getNote(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );
        address noteNft = note.mintNFT;
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        IMintNFT(noteNft).initialize(1, 1, address(web3Entry), "name", "symbol");
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

    function testApproveMintModule() public {
        vm.prank(alice);
        bool[] memory boolList = new bool[](1);
        boolList[0] = false;
        ApprovalMintModule(address(approvalMintModule)).approve(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            addressList2,
            boolList
        );
    }

    function testApproveMintModuleFail() public {
        // not owner can't approve
        vm.expectRevert(abi.encodeWithSelector(ErrNotCharacterOwner.selector));
        vm.prank(bob);
        bool[] memory boolList = new bool[](1);
        boolList[0] = true;
        ApprovalMintModule(address(approvalMintModule)).approve(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            addressList2,
            boolList
        );

        // invalid array length
        vm.expectRevert(abi.encodeWithSelector(ErrArrayLengthMismatch.selector));
        vm.prank(alice);
        ApprovalMintModule(address(approvalMintModule)).approve(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            addressList1,
            boolList
        );
    }
}
