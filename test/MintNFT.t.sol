// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {DataTypes} from "../contracts/libraries/DataTypes.sol";
import {ErrCallerNotWeb3Entry} from "../contracts/libraries/Error.sol";
import {MintNFT} from "../contracts/MintNFT.sol";
import {IMintNFT} from "../contracts/interfaces/IMintNFT.sol";
import {CommonTest} from "./helpers/CommonTest.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract MintNFTTest is CommonTest {
    address public mintNFT;

    function setUp() public {
        _setUp();

        // create a character for bob
        _createCharacter(CHARACTER_HANDLE, bob);

        // bob posts a note
        vm.prank(bob);
        _postNote(FIRST_CHARACTER_ID, NOTE_URI);

        // mint a note for alice
        _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, alice, "");

        DataTypes.Note memory note = web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
        mintNFT = note.mintNFT;
    }

    function testSetupState() public {
        // check metadata
        assertEq(IERC721Metadata(mintNFT).name(), "Note-1-1");
        assertEq(IERC721Metadata(mintNFT).symbol(), "Note-1-1");
        assertEq(IERC721Metadata(mintNFT).tokenURI(1), NOTE_URI);

        // check source note pointer
        (uint256 characterId, uint256 noteId) = IMintNFT(mintNFT).getSourceNotePointer();
        assertEq(characterId, 1);
        assertEq(noteId, 1);

        assertEq(IERC721Enumerable(mintNFT).totalSupply(), 1);
        assertEq(IERC721(mintNFT).balanceOf(alice), 1);
        assertEq(IERC721(mintNFT).ownerOf(1), alice);
        assertEq(IMintNFT(mintNFT).originalReceiver(1), alice);
    }

    function testMint() public {
        // mint nft
        vm.prank(address(web3Entry));
        IMintNFT(mintNFT).mint(bob);

        // check state
        assertEq(IERC721Enumerable(mintNFT).totalSupply(), 2);
        assertEq(IERC721(mintNFT).balanceOf(bob), 1);
        assertEq(IERC721(mintNFT).ownerOf(2), bob);
        assertEq(IMintNFT(mintNFT).originalReceiver(2), bob);
    }

    function testMintFail() public {
        // caller is not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        IMintNFT(mintNFT).mint(bob);
    }

    function testMintWithMintNote() public {
        // mint a note for carol
        _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, carol, "");

        // check state
        assertEq(IERC721Enumerable(mintNFT).totalSupply(), 2);
        assertEq(IERC721(mintNFT).balanceOf(carol), 1);
        assertEq(IERC721(mintNFT).ownerOf(2), carol);
        assertEq(IMintNFT(mintNFT).originalReceiver(2), carol);
    }

    function testOriginalReceiverWithTransfer() public {
        // mint a note for carol
        _mintNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID, carol, "");
        // carol transfers nft to dick
        vm.prank(carol);
        IERC721(mintNFT).transferFrom(carol, dick, 2);

        // check state
        assertEq(IMintNFT(mintNFT).originalReceiver(2), carol);
        assertEq(IERC721(mintNFT).balanceOf(dick), 1);
        assertEq(IERC721(mintNFT).ownerOf(2), dick);
    }
}
