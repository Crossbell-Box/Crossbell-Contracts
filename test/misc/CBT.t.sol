// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../src/libraries/DataTypes.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../src/misc/CBT1155.sol";

contract CbtTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    uint256 public amount = 1;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;


    event Mint(uint256 indexed to, uint256 indexed tokenId, uint256 indexed amount);
    event Burn(uint256 indexed from, uint256 indexed tokenId, uint256 indexed amount);

    function setUp() public {
        _setUp();

        // alice mint first character
        DataTypes.CreateCharacterData memory characterData = makeCharacterData(
            Const.MOCK_CHARACTER_HANDLE,
            alice
        );
        vm.prank(alice);
        web3Entry.createCharacter(characterData);

        // bob mint second character
        DataTypes.CreateCharacterData memory characterData2 = makeCharacterData(
            Const.MOCK_CHARACTER_HANDLE2,
            bob
        );
        vm.prank(bob);
        web3Entry.createCharacter(characterData2);
    }

    function testCbt() public {
        // MINTER_ROLE should mint
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID);
        uint256 balance1Of1 = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CBT_ID
        );
        assertEq(balance1Of1, amount);
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.SECOND_CBT_ID);
        uint256 balance2Of1 = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CBT_ID
        );
        assertEq(balance2Of1, amount);
        
        // expect correct emit
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID);

        //owner should burn
        uint256 preBalance = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CBT_ID
        );
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.SECOND_CBT_ID);
        vm.prank(alice);
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        uint256 postBalance = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CBT_ID
        );
        assertEq(preBalance - amount, postBalance);

        // expect correct emit
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        vm.prank(alice);
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);

        // approved cbt should burn
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.SECOND_CBT_ID);
        vm.prank(alice);
        cbt.setApprovalForAll(bob, true);
        vm.prank(bob);
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.SECOND_CBT_ID, amount);

        // setTokenURI
        cbt.setTokenURI(Const.FIRST_CBT_ID, Const.MOCK_TOKEN_URI);
        string memory preUri = cbt.uri(Const.FIRST_CBT_ID);
        assertEq(Const.MOCK_TOKEN_URI, preUri);
        cbt.setTokenURI(Const.FIRST_CBT_ID, Const.MOCK_NEW_TOKEN_URI);
        string memory postUri = cbt.uri(Const.FIRST_CBT_ID);
        assertEq(Const.MOCK_NEW_TOKEN_URI, postUri);

        cbt.setTokenURI(Const.SECOND_CBT_ID, Const.MOCK_TOKEN_URI);
        string memory preUri2 = cbt.uri(Const.SECOND_CBT_ID);
        assertEq(Const.MOCK_TOKEN_URI, preUri2);
        cbt.setTokenURI(Const.SECOND_CBT_ID, Const.MOCK_NEW_TOKEN_URI);
        string memory postUri2 = cbt.uri(Const.SECOND_CBT_ID);
        assertEq(Const.MOCK_NEW_TOKEN_URI, postUri2);
    }

    function testCbtFail() public {
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID);
        // can't mint to the zero characterID
        vm.expectRevert(abi.encodePacked("mint to the zero characterId"));
        cbt.mint(Const.ZERO_CBT_ID, Const.FIRST_CBT_ID);

        // caller is not token owner nor approved
        vm.expectRevert(abi.encodePacked("caller is not token owner nor approved"));
        vm.prank(bob);
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);

        //burn amount exceeds balance
        uint256 currentBalance = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CBT_ID
        );
        vm.prank(alice);
        vm.expectRevert(abi.encodePacked("burn amount exceeds balance"));
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, currentBalance + 1);

        // cancel approval should not run
        vm.prank(alice);
        cbt.setApprovalForAll(bob, false);
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("caller is not token owner nor approved"));
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.SECOND_CBT_ID, amount);

        // only MINTER_ROLE can set uri
        vm.prank(alice);
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(alice),
                " is missing role ",
                Strings.toHexString(uint256(MINTER_ROLE), 32)
            )
        );
        cbt.setTokenURI(Const.FIRST_CBT_ID, Const.MOCK_TOKEN_URI);

        // cbt cannot be tansferred
        vm.expectRevert(abi.encodePacked("non-transferable"));
        cbt.safeTransferFrom(alice, bob, Const.FIRST_CBT_ID, amount, new bytes(0));
        vm.expectRevert(abi.encodePacked("non-transferable"));
        uint256[] memory ids = new uint256[](1);
        ids[0] = Const.FIRST_CBT_ID;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        cbt.safeBatchTransferFrom(alice, bob, ids, amounts, new bytes(0));
    }

    function testMint() public {
        // admin mint
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE3, alice));
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 );
        emit Mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, 1);
        cbt.mint(1, 1);

        // grant mint role and mint
        cbt.grantRole(MINTER_ROLE, bob);
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 );
        emit Mint(Const.FIRST_CHARACTER_ID, Const.SECOND_CBT_ID, 1);
        vm.prank(bob);
        cbt.mint(1, 2);

    }

    function testMintFail() public {
        // bob with no mint role should mint cbt fail
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE3, alice));
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

    function testGrantRole() public {
        // check role
        assertEq(cbt.hasRole(MINTER_ROLE, bob), false);

        // grant role
        cbt.grantRole(MINTER_ROLE, bob);

        // check role
        assertEq(cbt.hasRole(MINTER_ROLE, bob), true);
        assertEq(cbt.getRoleMember(MINTER_ROLE, 1), bob);

        // mint cbt
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE3, alice));
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
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE3, alice));
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
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE4, alice));
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
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE3, alice));
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
        cbt.renounceRole(MINTER_ROLE,bob);
        assertEq(cbt.hasRole(MINTER_ROLE, bob), false);
        assertEq(cbt.getRoleMemberCount(MINTER_ROLE), 1);

        // mint cbt fail
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE4, alice));
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
}