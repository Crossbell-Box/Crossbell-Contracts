// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Events} from "../../contracts/libraries/Events.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {
    ErrNotEnoughPermission,
    ErrCallerNotWeb3EntryOrNotOwner,
    ErrCallerNotWeb3Entry,
    ErrNotOwner
} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract LinklistTest is CommonTest {
    event Transfer(address indexed from, uint256 indexed characterId, uint256 indexed tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Burn(address indexed from, uint256 indexed characterId, uint256 indexed tokenId);

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testMint() public {
        // link character
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
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
        vm.prank(address(web3Entry));
        linklist.mint(FIRST_CHARACTER_ID, FollowLinkType);

        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Burn(alice, FIRST_CHARACTER_ID, FIRST_LINKLIST_ID);
        vm.prank(alice);
        linklist.burn(1);

        // check balances
        assertEq(linklist.balanceOf(FIRST_CHARACTER_ID), 0);
        assertEq(linklist.balanceOf(alice), 0);
        // check totalSupply
        assertEq(linklist.totalSupply(), 0);
    }

    function testBurnFail() public {
        vm.prank(address(web3Entry));
        linklist.mint(FIRST_CHARACTER_ID, FollowLinkType);

        // case 1: caller not owner
        vm.expectRevert(abi.encodeWithSelector(ErrNotOwner.selector));
        linklist.burn(1);

        // case 2: token not exist
        vm.expectRevert("ERC721: owner query for nonexistent token");
        linklist.burn(2);
    }
}
