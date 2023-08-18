// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {
    ErrNotEnoughPermission,
    ErrCallerNotWeb3EntryOrNotOwner,
    ErrCallerNotWeb3Entry,
    ErrNotOwner,
    ErrTokenNotExists,
    ErrNotCharacterOwner
} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

contract LinklistTest is CommonTest {
    event Transfer(address indexed from, uint256 indexed characterId, uint256 indexed tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Burn(uint256 indexed from, uint256 indexed tokenId);

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testSetupState() public {
        assertEq(linklist.Web3Entry(), address(web3Entry));
    }

    function testSupportsInterface() public {
        assertTrue(web3Entry.supportsInterface(type(IERC721).interfaceId));
        assertTrue(web3Entry.supportsInterface(type(IERC721Enumerable).interfaceId));
        assertTrue(web3Entry.supportsInterface(type(IERC721Metadata).interfaceId));
        assertTrue(web3Entry.supportsInterface(type(IERC165).interfaceId));
    }

    function testMint() public {
        // link character
        expectEmit(CheckAll);
        emit Transfer(address(0), FIRST_CHARACTER_ID, FIRST_LINKLIST_ID);
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                LikeLinkType,
                new bytes(0)
            )
        );

        // check state
        assertEq(linklist.totalSupply(), 1);
        assertEq(linklist.balanceOf(alice), 1);
        assertEq(linklist.balanceOf(FIRST_CHARACTER_ID), 1);
        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.characterOwnerOf(1), FIRST_CHARACTER_ID);
        assertEq(linklist.getOwnerCharacterId(1), 1);
        assertEq(linklist.Uri(1), "");
        assertEq(linklist.getLinkingCharacterIds(1).length, 1);
        assertEq(linklist.getLinkingCharacterIds(1)[0], 2);
        assertEq(linklist.getLinkType(1), LikeLinkType);
    }

    function testMintFail() public {
        // case 1: not owner can't link character
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // case 2: caller not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        linklist.mint(FIRST_CHARACTER_ID, FollowLinkType);

        // check state
        assertEq(linklist.totalSupply(), 0);
    }

    function testSetUri() public {
        // link character
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );
        // case 1: set linklist uri by alice
        linklist.setUri(1, TOKEN_URI);
        // check linklist uri
        assertEq(linklist.Uri(1), TOKEN_URI);
        vm.stopPrank();

        // case 2: set linklist uri by web3Entry
        vm.prank(address(web3Entry));
        linklist.setUri(1, NEW_TOKEN_URI);
        // check linklist uri
        assertEq(linklist.Uri(1), NEW_TOKEN_URI);

        // check state
        string memory uri = linklist.Uri(1);
        assertEq(uri, NEW_TOKEN_URI);
    }

    function testSetUriFail() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                FollowLinkType,
                new bytes(0)
            )
        );

        // bob sets linklist uri
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3EntryOrNotOwner.selector));
        vm.prank(bob);
        linklist.setUri(1, TOKEN_URI);
    }

    function testUriFail() public {
        // token not exist
        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.Uri(2);
    }

    function testMintFuzz(uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(amount < 100);
        vm.startPrank(address(web3Entry));

        for (uint256 i = 1; i <= amount; i++) {
            linklist.mint(FIRST_CHARACTER_ID, FollowLinkType);
        }

        // check balances
        uint256 balanceOfCharacter = linklist.balanceOf(1);
        assertEq(balanceOfCharacter, amount);

        uint256 balanceOfAddress = linklist.balanceOf(alice);
        assertEq(balanceOfAddress, amount);

        // check totalSupply
        uint256 totalSupply = linklist.totalSupply();
        uint256 expectedTotalSupply = amount;
        assertEq(totalSupply, expectedTotalSupply);
    }

    function testBurn() public {
        vm.startPrank(address(web3Entry));
        linklist.mint(FIRST_CHARACTER_ID, FollowLinkType);

        expectEmit(CheckAll);
        emit Burn(FIRST_CHARACTER_ID, FIRST_LINKLIST_ID);
        linklist.burn(1);
        vm.stopPrank();

        // check balances
        assertEq(linklist.balanceOf(FIRST_CHARACTER_ID), 0);
        assertEq(linklist.balanceOf(alice), 0);
        // check totalSupply
        assertEq(linklist.totalSupply(), 0);
    }

    function testBurnFail() public {
        vm.prank(address(web3Entry));
        linklist.mint(FIRST_CHARACTER_ID, FollowLinkType);

        // case 1: caller not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        linklist.burn(1);

        // case 2: token not exist
        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        vm.prank(address(web3Entry));
        linklist.burn(2);
    }

    function testBurnFuzz(uint256 amount) public {
        vm.assume(amount > 0 && amount < 1000);
        uint256 mintAmount = amount;
        uint256 burnAmount = amount / 2;

        vm.startPrank(address(web3Entry));
        // mint linklist
        for (uint256 i = 0; i < mintAmount; i++) {
            linklist.mint(FIRST_CHARACTER_ID, FollowLinkType);
        }
        // check balances
        assertEq(linklist.balanceOf(FIRST_CHARACTER_ID), mintAmount);
        // check totalSupply
        assertEq(linklist.balanceOf(alice), mintAmount);
        assertEq(linklist.totalSupply(), mintAmount);

        // burn linklist
        for (uint256 i = 1; i <= burnAmount; i++) {
            linklist.burn(i);
        }
        vm.stopPrank();

        // check balances
        uint256 leftAmount = mintAmount - burnAmount;
        assertEq(linklist.balanceOf(FIRST_CHARACTER_ID), leftAmount);
        assertEq(linklist.balanceOf(alice), leftAmount);
        // check totalSupply
        assertEq(linklist.totalSupply(), mintAmount - burnAmount);
    }

    function testBurnLinklistByWeb3Entry() public {
        vm.startPrank(alice);
        // link character
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));
        // check
        assertEq(linklist.balanceOf(1), 1);
        assertEq(linklist.balanceOf(alice), 1);
        assertEq(linklist.totalSupply(), 1);
        assertEq(web3Entry.getLinklistId(1, FollowLinkType), 1);
        assertEq(web3Entry.getLinklistType(1), FollowLinkType);

        // burn linklist
        web3Entry.burnLinklist(1);
        // check linklist 1
        assertEq(linklist.balanceOf(1), 0);
        assertEq(linklist.balanceOf(alice), 0);
        assertEq(linklist.totalSupply(), 0);
        assertEq(web3Entry.getLinklistId(1, FollowLinkType), 0);
        assertEq(web3Entry.getLinklistType(1), bytes32Zero);

        // link character
        // check linklist 2
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));
        assertEq(linklist.balanceOf(1), 1);
        assertEq(linklist.balanceOf(alice), 1);
        assertEq(linklist.totalSupply(), 1);
        assertEq(web3Entry.getLinklistId(1, FollowLinkType), 2);
        assertEq(web3Entry.getLinklistType(2), FollowLinkType);
        vm.stopPrank();
    }

    function testBurnLinklistFailByWeb3Entry() public {
        vm.prank(alice);
        // link character
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));
        // check
        assertEq(web3Entry.getLinklistId(1, FollowLinkType), 1);
        assertEq(web3Entry.getLinklistType(1), FollowLinkType);

        // case 1: caller not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrNotCharacterOwner.selector));
        web3Entry.burnLinklist(1);

        // case 2: linklist not exist
        vm.expectRevert("ERC721: owner query for nonexistent token");
        web3Entry.burnLinklist(100);
    }
}
