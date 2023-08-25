// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../contracts/libraries/DataTypes.sol";
import {
    ErrNotEnoughPermission,
    ErrCallerNotWeb3EntryOrNotOwner,
    ErrCallerNotWeb3Entry,
    ErrTokenNotExists,
    ErrNotCharacterOwner,
    ErrLinkTypeExists
} from "../contracts/libraries/Error.sol";
import {OP} from "../contracts/libraries/OP.sol";
import {Events} from "../contracts/libraries/Events.sol";
import {CommonTest} from "./helpers/CommonTest.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

contract LinklistTest is CommonTest {
    event Transfer(address indexed from, uint256 indexed characterId, uint256 indexed tokenId);
    event Burn(uint256 indexed from, uint256 indexed tokenId);
    event UriSet(uint256 indexed tokenId, string newUri);
    event LinkTypeSet(uint256 indexed tokenId, bytes32 indexed newlinkType);

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
        vm.prank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));

        // case 1: set linklist uri by linklist owner
        string memory tokenUri = TOKEN_URI;
        expectEmit(CheckAll);
        emit UriSet(1, tokenUri);
        vm.prank(alice);
        linklist.setUri(1, tokenUri);
        // check uri
        assertEq(linklist.Uri(1), tokenUri);

        // case 2: set linklist uri by web3Entry
        string memory newUri = NEW_TOKEN_URI;
        expectEmit(CheckAll);
        emit UriSet(1, newUri);
        vm.prank(address(web3Entry));
        linklist.setUri(1, newUri);
        // check uri
        assertEq(linklist.Uri(1), newUri);
    }

    function testSetUriFail() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));

        // case 1: caller not web3Entry or not owner
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3EntryOrNotOwner.selector));
        vm.prank(bob);
        linklist.setUri(1, TOKEN_URI);

        // case 2: token not exist
        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        vm.prank(address(web3Entry));
        linklist.setUri(2, TOKEN_URI);
    }

    function testSetLinkType() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));

        // set linklist type
        bytes32 linkType = WatchLinkType;
        expectEmit(CheckAll);
        emit LinkTypeSet(1, linkType);
        vm.prank(address(web3Entry));
        linklist.setLinkType(1, linkType);
        // check link type
        assertEq(linklist.getLinkType(1), linkType);
    }

    function testSetLinkTypeFail() public {
        // case 1: caller is not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        linklist.setLinkType(1, FollowLinkType);

        // case 2: token not exist
        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        vm.prank(address(web3Entry));
        linklist.setLinkType(2, FollowLinkType);
    }

    // set linklist type through web3Entry
    function testSetLinkListType() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));

        // set linklist type
        expectEmit(CheckAll);
        emit Events.DetachLinklist(1, 1, FollowLinkType);
        expectEmit(CheckAll);
        emit Events.AttachLinklist(1, 1, WatchLinkType);
        expectEmit(CheckAll);
        emit LinkTypeSet(1, WatchLinkType);
        vm.prank(alice);
        web3Entry.setLinklistType(1, WatchLinkType);

        // check link type
        assertEq(linklist.getLinkType(1), WatchLinkType);
        assertEq(web3Entry.getLinklistId(1, WatchLinkType), 1);
        // check old link type
        assertEq(web3Entry.getLinklistId(1, FollowLinkType), 0);
    }

    function testSetLinkListTypeMultiple() public {
        // link character
        vm.startPrank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));

        // set linklist type
        web3Entry.setLinklistType(1, WatchLinkType);
        web3Entry.setLinklistType(1, LikeLinkType);
        web3Entry.setLinklistType(1, FollowLinkType);
        vm.stopPrank();

        // check link type
        assertEq(linklist.getLinkType(1), FollowLinkType);
        assertEq(web3Entry.getLinklistId(1, FollowLinkType), 1);
        // check old link type
        assertEq(web3Entry.getLinklistId(1, LikeLinkType), 0);
        assertEq(web3Entry.getLinklistId(1, WatchLinkType), 0);
    }

    function testSetLinkListTypeWithOperator() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));

        // grant operator permission to bob
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(1, bob, 1 << OP.SET_LINKLIST_TYPE);

        // set linklist type
        vm.prank(bob);
        web3Entry.setLinklistType(1, WatchLinkType);
        // check link type
        assertEq(linklist.getLinkType(1), WatchLinkType);
    }

    function testSetLinkListTypeFail() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));

        // set linklist type
        // case 1: call has no permission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setLinklistType(1, WatchLinkType);

        // case 2: operator has no permission
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(
            1,
            bob,
            OP.DEFAULT_PERMISSION_BITMAP ^ (1 << OP.SET_LINKLIST_TYPE)
        );
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setLinklistType(1, WatchLinkType);
    }

    function testSetLinkListTypeFailWithLinkTypeExist() public {
        // link character
        vm.startPrank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, LikeLinkType, ""));

        // set linklist type
        vm.expectRevert(abi.encodeWithSelector(ErrLinkTypeExists.selector, 1, LikeLinkType));
        web3Entry.setLinklistType(1, LikeLinkType);

        // set linkType for linklist with the same linkType
        vm.expectRevert(abi.encodeWithSelector(ErrLinkTypeExists.selector, 1, LikeLinkType));
        web3Entry.setLinklistType(2, LikeLinkType);
        vm.stopPrank();
    }

    function testUriFail() public {
        // token not exist
        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.Uri(2);
    }

    // solhint-disable-next-line function-max-lines
    function testQueryWithTokenNotExists() public {
        // token not exist
        uint256 tokenId = 2;

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingCharacterIds(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingCharacterListLength(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getOwnerCharacterId(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingNotes(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingERC721s(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingERC721ListLength(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingAddresses(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingAddressListLength(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingAnyUris(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingAnyUriKeys(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingAnyListLength(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingLinklistIds(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkingLinklistLength(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.getLinkType(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.Uri(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.characterOwnerOf(tokenId);

        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        linklist.ownerOf(tokenId);
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
        // query linkType error
        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
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
        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        web3Entry.burnLinklist(100);
    }

    function testSetLinklistUri() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));

        string memory newUri = MOCK_URI;
        expectEmit(CheckAll);
        emit UriSet(1, newUri);
        // set uri
        vm.prank(alice);
        web3Entry.setLinklistUri(1, newUri);
        // check uri
        assertEq(web3Entry.getLinklistUri(1), newUri);
        assertEq(linklist.Uri(1), newUri);
    }

    function testSetLinklistUriWithOperator() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));

        // grant operator permission to bob
        vm.prank(alice);
        web3Entry.grantOperatorPermissions(1, bob, 1 << OP.SET_LINKLIST_URI);

        string memory newUri = MOCK_URI;
        // set uri
        vm.prank(bob);
        web3Entry.setLinklistUri(1, newUri);
        // check uri
        assertEq(web3Entry.getLinklistUri(1), newUri);
        assertEq(linklist.Uri(1), newUri);
    }

    function testSetLinklistUriFail() public {
        vm.prank(alice);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(1, 2, FollowLinkType, ""));

        //  case 1: caller has no permission
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.setLinklistUri(1, MOCK_URI);

        // case 2: linklist not exist
        vm.expectRevert(abi.encodeWithSelector(ErrTokenNotExists.selector));
        vm.prank(alice);
        web3Entry.setLinklistUri(2, MOCK_URI);
    }
}
