// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {CommonTest} from "../helpers/CommonTest.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {CharacterBoundToken} from "../../contracts/misc/CharacterBoundToken.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {
    IERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {
    IERC1155MetadataURI
} from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";

contract CbtTest is CommonTest {
    uint256 public amount = 1;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event Mint(uint256 indexed to, uint256 indexed tokenId, uint256 indexed tokenNumber);
    event Burn(uint256 indexed from, uint256 indexed tokenId, uint256 indexed amount);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // alice mint first character
        vm.prank(alice);
        _createCharacter(CHARACTER_HANDLE, alice);

        // bob mint second character
        vm.prank(bob);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testSupportsInterfacexxx() public {
        assertTrue(cbt.supportsInterface(type(IERC1155).interfaceId));
        assertTrue(cbt.supportsInterface(type(IERC1155MetadataURI).interfaceId));
        assertTrue(cbt.supportsInterface(type(IERC165).interfaceId));
    }

    function testMint() public {
        // MINTER_ROLE should mint
        cbt.mint(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        assertEq(cbt.balanceOf(FIRST_CHARACTER_ID, FIRST_CBT_ID), amount);
        // mint
        cbt.mint(FIRST_CHARACTER_ID, SECOND_CBT_ID);
        assertEq(cbt.balanceOf(FIRST_CHARACTER_ID, SECOND_CBT_ID), amount);

        // expect correct emit
        expectEmit(CheckAll);
        emit Mint(FIRST_CHARACTER_ID, FIRST_CBT_ID, 2);
        cbt.mint(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        assertEq(cbt.balanceOf(FIRST_CHARACTER_ID, FIRST_CBT_ID), amount * 2);

        // grant mint role and mint
        cbt.grantRole(MINTER_ROLE, bob);
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3);
        emit Mint(FIRST_CHARACTER_ID, SECOND_CBT_ID, 2);
        vm.prank(bob);
        cbt.mint(FIRST_CHARACTER_ID, SECOND_CBT_ID);
        assertEq(cbt.balanceOf(FIRST_CHARACTER_ID, SECOND_CBT_ID), amount * 2);
    }

    function testMintFail() public {
        // bob with no mint role should mint cbt fail
        vm.prank(bob);
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(bob),
                " is missing role ",
                Strings.toHexString(uint256(MINTER_ROLE), 32)
            )
        );
        cbt.mint(FIRST_CBT_ID, amount);

        // can't mint to the zero characterID
        vm.expectRevert(abi.encodePacked("mint to the zero characterId"));
        cbt.mint(ZERO_CBT_ID, FIRST_CBT_ID);
    }

    function testBurn() public {
        cbt.mint(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        //owner should burn
        uint256 preBalance = cbt.balanceOf(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        vm.prank(alice);
        expectEmit(CheckAll);
        emit Burn(FIRST_CHARACTER_ID, FIRST_CBT_ID, amount);
        cbt.burn(FIRST_CHARACTER_ID, FIRST_CBT_ID, amount);
        uint256 postBalance = cbt.balanceOf(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        assertEq(preBalance - amount, postBalance);

        // approved cbt should burn
        cbt.mint(FIRST_CHARACTER_ID, SECOND_CBT_ID);
        vm.prank(alice);
        cbt.setApprovalForAll(bob, true);
        vm.prank(bob);
        cbt.burn(FIRST_CHARACTER_ID, SECOND_CBT_ID, amount);

        // check balance
        assertEq(
            cbt.balanceOf(alice, FIRST_CBT_ID),
            cbt.balanceOf(FIRST_CHARACTER_ID, FIRST_CBT_ID)
        );
        assertEq(
            cbt.balanceOf(alice, SECOND_CBT_ID),
            cbt.balanceOf(FIRST_CHARACTER_ID, SECOND_CBT_ID)
        );
        assertEq(cbt.balanceOf(alice, FIRST_CBT_ID), 0);
        assertEq(cbt.balanceOf(alice, SECOND_CBT_ID), 0);
    }

    function testBurnFail() public {
        // only owner and approved operator can burn
        vm.expectRevert(abi.encodePacked("caller is not token owner nor approved"));
        vm.prank(bob);
        cbt.burn(FIRST_CHARACTER_ID, FIRST_CBT_ID, amount);

        //burn amount exceeds balance
        uint256 currentBalance = cbt.balanceOf(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        vm.prank(alice);
        vm.expectRevert(abi.encodePacked("burn amount exceeds balance"));
        cbt.burn(FIRST_CHARACTER_ID, FIRST_CBT_ID, currentBalance + 1);

        // cancel approval should not run
        vm.prank(alice);
        cbt.setApprovalForAll(bob, false);
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("caller is not token owner nor approved"));
        cbt.burn(FIRST_CHARACTER_ID, SECOND_CBT_ID, amount);
    }

    function testSetTokenURI() public {
        string memory uri = "ipfs://tokenURI";

        // owner set tokenURI
        expectEmit(CheckData);
        emit URI(uri, 1);
        cbt.setTokenURI(1, uri);
        assertEq(cbt.uri(1), uri);

        // grant role to alice, and set tokenURI
        cbt.grantRole(MINTER_ROLE, alice);
        vm.prank(alice);
        cbt.setTokenURI(2, uri);
        assertEq(cbt.uri(2), uri);
    }

    function testSetTokenURIFail() public {
        string memory uri = "ipfs://tokenURI";

        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(alice),
                " is missing role ",
                Strings.toHexString(uint256(MINTER_ROLE), 32)
            )
        );
        vm.prank(alice);
        cbt.setTokenURI(1, uri);
    }

    function testTransfer() public {
        cbt.mint(FIRST_CHARACTER_ID, FIRST_CBT_ID);

        // safeTransferFrom
        vm.expectRevert(abi.encodePacked("non-transferable"));
        cbt.safeTransferFrom(alice, bob, FIRST_CBT_ID, 1, new bytes(0));

        // safeBatchTransferFrom
        uint256[] memory ids = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        ids[0] = 1;
        amounts[0] = 1;
        vm.expectRevert(abi.encodePacked("non-transferable"));
        cbt.safeBatchTransferFrom(alice, bob, ids, amounts, new bytes(0));
    }

    function testSetApprovalForAll() public {
        assertEq(cbt.isApprovedForAll(alice, bob), false);

        // set approval true
        expectEmit(CheckTopic1 | CheckTopic2 | CheckData);
        emit ApprovalForAll(alice, bob, true);
        vm.prank(alice);
        cbt.setApprovalForAll(bob, true);
        assertEq(cbt.isApprovedForAll(alice, bob), true);

        // set approval false
        expectEmit(CheckTopic1 | CheckTopic2 | CheckData);
        emit ApprovalForAll(alice, bob, false);
        vm.prank(alice);
        cbt.setApprovalForAll(bob, false);
        assertEq(cbt.isApprovedForAll(alice, bob), false);
    }

    function testBalanceOf() public {
        // blanceOf should return the sum of CBTs from all characters
        // alice mint the third character
        vm.prank(alice);
        web3Entry.createCharacter(makeCharacterData("handle3", alice));
        // the third character get 2 CBTs
        cbt.mint(THIRD_CHARACTER_ID, FIRST_CBT_ID);
        cbt.mint(THIRD_CHARACTER_ID, FIRST_CBT_ID);
        // the first character get 1 CBT
        cbt.mint(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        // balance of alice should be the sum of balance of character1 and character3
        assertEq(
            cbt.balanceOf(alice, FIRST_CBT_ID),
            cbt.balanceOf(FIRST_CHARACTER_ID, FIRST_CBT_ID) +
                cbt.balanceOf(THIRD_CHARACTER_ID, FIRST_CBT_ID)
        );

        // transfer character 3 to bob
        vm.prank(alice);
        web3Entry.safeTransferFrom(alice, bob, THIRD_CHARACTER_ID);
        // check balance
        assertEq(
            cbt.balanceOf(alice, FIRST_CBT_ID),
            cbt.balanceOf(FIRST_CHARACTER_ID, FIRST_CBT_ID)
        );
        assertEq(cbt.balanceOf(bob, FIRST_CBT_ID), cbt.balanceOf(THIRD_CHARACTER_ID, FIRST_CBT_ID));
    }

    function testBalanceOfBatch() public {
        cbt.mint(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        cbt.mint(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        cbt.mint(SECOND_CHARACTER_ID, FIRST_CBT_ID);
        // the first character has 2 CBTs
        // the second character has 1 CBT
        address[] memory accounts = new address[](2);
        accounts[0] = alice;
        accounts[1] = bob;
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = FIRST_CBT_ID;
        tokenIds[1] = FIRST_CBT_ID;
        uint256[] memory batchBalance = cbt.balanceOfBatch(accounts, tokenIds);
        assertEq(batchBalance[0], 2);
        assertEq(batchBalance[1], 1);
    }

    function testBalanceOfByCharacterId() public {
        cbt.mint(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        uint256 balance10f1 = cbt.balanceOf(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        assertEq(balance10f1, 1);
    }

    function testBalanceOfByCharacterIdFail() public {
        vm.expectRevert(abi.encodePacked("zero is not a valid owner"));
        cbt.balanceOf(0, FIRST_CBT_ID);
    }

    function testbalanceOfBatchFail() public {
        address[] memory accounts = new address[](2);
        accounts[0] = alice;
        accounts[1] = bob;
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = FIRST_CBT_ID;
        vm.expectRevert(abi.encodePacked("accounts and ids length mismatch"));
        cbt.balanceOfBatch(accounts, tokenIds);
    }

    function testIsApproveForALl() public {
        assertEq(cbt.isApprovedForAll(alice, bob), false);

        vm.startPrank(alice);
        cbt.setApprovalForAll(bob, true);
        assertEq(cbt.isApprovedForAll(alice, bob), true);

        cbt.setApprovalForAll(bob, false);
        assertEq(cbt.isApprovedForAll(alice, bob), false);
        vm.stopPrank();
    }

    function testUri() public {
        string memory uri = "ipfs://tokenURI";
        cbt.setTokenURI(1, uri);

        assertEq(cbt.uri(1), uri);
        assertEq(cbt.uri(2), "");
    }

    function testHasRole() public {
        // check role
        assertEq(cbt.hasRole(MINTER_ROLE, alice), false);
        assertEq(cbt.hasRole(MINTER_ROLE, bob), false);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, alice), false);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, bob), false);

        // grant role
        cbt.grantRole(MINTER_ROLE, bob);
        cbt.grantRole(DEFAULT_ADMIN_ROLE, alice);

        // check role
        assertEq(cbt.hasRole(MINTER_ROLE, alice), false);
        assertEq(cbt.hasRole(MINTER_ROLE, bob), true);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, alice), true);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, bob), false);
    }

    function testGetRoleMember() public {
        // owner(this contract) is granted in constructor
        assertEq(cbt.getRoleMember(DEFAULT_ADMIN_ROLE, 0), address(this));
        // owner is granted in constructor
        assertEq(cbt.getRoleMember(MINTER_ROLE, 0), address(this));

        // grant role
        cbt.grantRole(MINTER_ROLE, bob);
        cbt.grantRole(DEFAULT_ADMIN_ROLE, alice);

        // get role member
        assertEq(cbt.getRoleMember(DEFAULT_ADMIN_ROLE, 1), alice);
        assertEq(cbt.getRoleMember(MINTER_ROLE, 1), bob);
    }

    function testGetRoleMemberCount() public {
        // owner(this contract) is granted in constructor
        assertEq(cbt.getRoleMemberCount(DEFAULT_ADMIN_ROLE), 1);
        // owner is granted in constructor
        assertEq(cbt.getRoleMemberCount(MINTER_ROLE), 1);

        // grant role
        cbt.grantRole(MINTER_ROLE, alice);
        cbt.grantRole(MINTER_ROLE, bob);
        cbt.grantRole(DEFAULT_ADMIN_ROLE, alice);
        cbt.grantRole(DEFAULT_ADMIN_ROLE, bob);

        assertEq(cbt.getRoleMemberCount(DEFAULT_ADMIN_ROLE), 3);
        assertEq(cbt.getRoleMemberCount(MINTER_ROLE), 3);
    }

    function testGetRoleAdmin() public {
        assertEq(cbt.getRoleAdmin(MINTER_ROLE), DEFAULT_ADMIN_ROLE);
        assertEq(cbt.getRoleAdmin(DEFAULT_ADMIN_ROLE), DEFAULT_ADMIN_ROLE);
    }

    function testGrantRole() public {
        // check role
        assertEq(cbt.hasRole(MINTER_ROLE, bob), false);

        // grant role
        cbt.grantRole(MINTER_ROLE, bob);

        // check role
        assertEq(cbt.hasRole(MINTER_ROLE, bob), true);
        assertEq(cbt.getRoleMember(MINTER_ROLE, 1), bob);

        // mint cbt
        web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE3, alice));
        vm.prank(bob);
        cbt.mint(1, 1);
    }

    function testGrantRoleFail() public {
        // check role
        assertEq(cbt.hasRole(MINTER_ROLE, bob), false);

        // grant role fail
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(alice),
                " is missing role ",
                Strings.toHexString(uint256(DEFAULT_ADMIN_ROLE), 32)
            )
        );
        vm.prank(alice);
        cbt.grantRole(MINTER_ROLE, bob);

        // mint cbt fail
        web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE3, alice));
        vm.prank(bob);
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(bob),
                " is missing role ",
                Strings.toHexString(uint256(MINTER_ROLE), 32)
            )
        );
        cbt.mint(1, 1);
    }

    function testRevokeRole() public {
        // grant role
        cbt.grantRole(MINTER_ROLE, bob);
        assertEq(cbt.hasRole(MINTER_ROLE, bob), true);
        assertEq(cbt.getRoleMember(MINTER_ROLE, 1), bob);

        // revoke role
        cbt.revokeRole(MINTER_ROLE, bob);
        assertEq(cbt.hasRole(MINTER_ROLE, bob), false);

        // mint cbt fail
        web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE4, alice));
        vm.prank(bob);
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(bob),
                " is missing role ",
                Strings.toHexString(uint256(MINTER_ROLE), 32)
            )
        );
        cbt.mint(1, 1);
    }

    function testRevokeRoleFail() public {
        // grant role
        cbt.grantRole(MINTER_ROLE, bob);
        assertEq(cbt.hasRole(MINTER_ROLE, bob), true);
        assertEq(cbt.getRoleMember(MINTER_ROLE, 1), bob);

        // revoke role fail
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(alice),
                " is missing role ",
                Strings.toHexString(uint256(DEFAULT_ADMIN_ROLE), 32)
            )
        );
        vm.prank(alice);
        cbt.revokeRole(MINTER_ROLE, bob);
        // check role
        assertEq(cbt.hasRole(MINTER_ROLE, bob), true);

        // mint cbt
        web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE3, alice));
        vm.prank(bob);
        cbt.mint(1, 1);
    }

    function testRenounceRol() public {
        // grant role to bob
        cbt.grantRole(MINTER_ROLE, bob);
        assertEq(cbt.hasRole(MINTER_ROLE, bob), true);
        assertEq(cbt.getRoleMemberCount(MINTER_ROLE), 2);
        assertEq(cbt.getRoleMember(MINTER_ROLE, 1), bob);

        // renounce role
        vm.startPrank(bob);
        cbt.renounceRole(MINTER_ROLE, bob);
        assertEq(cbt.hasRole(MINTER_ROLE, bob), false);
        assertEq(cbt.getRoleMemberCount(MINTER_ROLE), 1);

        // mint cbt fail
        web3Entry.createCharacter(makeCharacterData(CHARACTER_HANDLE4, alice));
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(bob),
                " is missing role ",
                Strings.toHexString(uint256(MINTER_ROLE), 32)
            )
        );
        cbt.mint(1, 1);
        vm.stopPrank();
    }

    function testTokenNumber() public {
        // tokenNumber is emitted by Mint event
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3);
        emit Mint(FIRST_CHARACTER_ID, FIRST_CBT_ID, 1);
        cbt.mint(FIRST_CHARACTER_ID, FIRST_CBT_ID);
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3);
        emit Mint(SECOND_CHARACTER_ID, FIRST_CBT_ID, 2);
        cbt.mint(SECOND_CHARACTER_ID, FIRST_CBT_ID);
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3);
        emit Mint(THIRD_CHARACTER_ID, FIRST_CBT_ID, 3);
        cbt.mint(THIRD_CHARACTER_ID, FIRST_CBT_ID);

        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3);
        emit Mint(FIRST_CHARACTER_ID, SECOND_CBT_ID, 1);
        cbt.mint(FIRST_CHARACTER_ID, SECOND_CBT_ID);
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3);
        emit Mint(SECOND_CHARACTER_ID, SECOND_CBT_ID, 2);
        cbt.mint(SECOND_CHARACTER_ID, SECOND_CBT_ID);
    }
}
