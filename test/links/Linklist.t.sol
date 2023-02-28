// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/Web3Entry.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../../contracts/libraries/Error.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract LinklistTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    event Transfer(address indexed from, uint256 indexed characterId, uint256 indexed tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testMintx() public {
        // link character
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Transfer(address(0), Const.FIRST_CHARACTER_ID, 1);
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // check state
        assertEq(linklist.totalSupply(), 1);
        assertEq(linklist.balanceOf(alice), 1);
        assertEq(linklist.balanceOf(Const.FIRST_CHARACTER_ID), 1);
        assertEq(linklist.ownerOf(1), alice);
        assertEq(linklist.characterOwnerOf(1), Const.FIRST_CHARACTER_ID);
        assertEq(linklist.getOwnerCharacterId(1), 1);
        assertEq(linklist.Uri(1), "");

        // mint linklist directly by web3Entry
        vm.prank(address(web3Entry));
        linklist.mint(1, Const.FollowLinkType);
        // check state
        assertEq(linklist.totalSupply(), 2);
        assertEq(linklist.balanceOf(alice), 2);
        assertEq(linklist.balanceOf(Const.FIRST_CHARACTER_ID), 2);
        assertEq(linklist.ownerOf(2), alice);
        assertEq(linklist.characterOwnerOf(2), Const.FIRST_CHARACTER_ID);
        assertEq(linklist.getOwnerCharacterId(2), 1);
        assertEq(linklist.Uri(2), "");
    }

    function testSetUri() public {
        // link character
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        // case 1: set linklist uri by alice
        linklist.setUri(1, Const.MOCK_TOKEN_URI);
        // check linklist uri
        assertEq(linklist.Uri(1), Const.MOCK_TOKEN_URI);
        vm.stopPrank();

        // case 2: set linklist uri by web3Entry
        vm.prank(address(web3Entry));
        linklist.setUri(1, Const.MOCK_NEW_TOKEN_URI);
        // check linklist uri
        assertEq(linklist.Uri(1), Const.MOCK_NEW_TOKEN_URI);
    }

    function testSetUriFail() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // bob sets linklist uri
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3EntryOrNotOwner.selector));
        vm.prank(bob);
        linklist.setUri(1, Const.MOCK_TOKEN_URI);
    }
}
