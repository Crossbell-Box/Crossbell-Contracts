// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface,check-send-result,multiple-sends
pragma solidity 0.8.16;

import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../../contracts/misc/NewbieVilla.sol";

contract NewbieVillaTest is Test, SetUp, Utils {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    function setUp() public {
        _setUp();

        //  mint token
        token.mint(alice, 10 ether);
        token.mint(bob, 10 ether);

        // grant mint role to alice
        vm.prank(newbieAdmin);
        newbieVilla.grantRole(ADMIN_ROLE, alice);
    }

    function testSetupState() public {
        // check status after initialization
        assertEq(newbieVilla.web3Entry(), address(web3Entry));
        assertEq(newbieVilla.getToken(), address(token));
    }

    function testNewbieInitializeFail() public {
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        newbieVilla.initialize(
            address(web3Entry),
            xsyncOperator,
            address(0x000001),
            address(0x000001)
        );
    }

    function testNewbieCreateCharacter() public {
        vm.prank(alice);
        Web3Entry(address(web3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbieVilla))
        );

        // check operators
        address[] memory operators = web3Entry.getOperators(Const.FIRST_CHARACTER_ID);
        assertEq(operators[0], alice);
        assertEq(operators[1], xsyncOperator);

        // check operator permission bitmap
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, alice),
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, xsyncOperator),
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
    }

    function testNewbieCreateCharacterFail() public {
        // bob has no mint role, so he can't send character to newbieVilla contract
        vm.prank(bob);
        vm.expectRevert(abi.encodePacked("NewbieVilla: receive unknown character"));
        Web3Entry(address(web3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(newbieVilla))
        );
    }

    function testTransferNewbieIn() public {
        vm.prank(alice);
        Web3Entry(address(web3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(alice))
        );
        vm.prank(alice);
        Web3Entry(address(web3Entry)).safeTransferFrom(
            address(alice),
            address(newbieVilla),
            Const.FIRST_CHARACTER_ID
        );
        // check operators
        address[] memory operators = web3Entry.getOperators(Const.FIRST_CHARACTER_ID);
        assertEq(operators[0], alice);
        assertEq(operators[1], xsyncOperator);

        // check operator permission bitmap
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, alice),
            OP.DEFAULT_PERMISSION_BITMAP
        );
        assertEq(
            web3Entry.getOperatorPermissions(Const.FIRST_CHARACTER_ID, xsyncOperator),
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
    }

    function testTransferNewbieInFail() public {
        vm.startPrank(bob);
        Web3Entry(address(web3Entry)).createCharacter(
            makeCharacterData(Const.MOCK_CHARACTER_HANDLE, address(bob))
        );
        vm.expectRevert(abi.encodePacked("NewbieVilla: receive unknown character"));
        Web3Entry(address(web3Entry)).safeTransferFrom(
            address(bob),
            address(newbieVilla),
            Const.FIRST_CHARACTER_ID
        );

        NFT nft = new NFT();
        nft.mint(bob);
        vm.expectRevert(abi.encodePacked("NewbieVilla: receive unknown token"));
        nft.safeTransferFrom(address(bob), address(newbieVilla), Const.FIRST_CHARACTER_ID);
    }

    function testWithdrawNewbieOut() public {
        address to = carol;
        uint256 characterId = Const.FIRST_CHARACTER_ID;
        uint256 nonce = 1;
        uint256 expires = block.timestamp + 10 minutes;
        uint256 amount = 1 ether;

        // 1. create and transfer web3Entry nft to newbieVilla
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, newbieAdmin));
        vm.prank(newbieAdmin);
        web3Entry.safeTransferFrom(newbieAdmin, address(newbieVilla), characterId);

        // 2. send some token to web3Entry nft in newbieVilla
        vm.prank(alice);
        token.send(address(newbieVilla), amount, abi.encode(2, characterId));

        // 3. withdraw web3Entry nft
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(address(newbieVilla), characterId, nonce, expires))
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(newbieAdminPrivateKey, digest);
        // withdraw
        vm.prank(to);
        newbieVilla.withdraw(to, characterId, nonce, expires, abi.encodePacked(r, s, v));

        // check state
        assertEq(newbieVilla.balanceOf(characterId), 0);
        assertEq(web3Entry.ownerOf(characterId), carol);
        assertEq(token.balanceOf(carol), amount);
    }

    function testTokensReceived(uint256 amount) public {
        vm.assume(amount > 0 && amount < 10 ether);

        vm.prank(alice);
        token.send(
            address(newbieVilla),
            amount,
            abi.encode(Const.FIRST_CHARACTER_ID, Const.SECOND_CHARACTER_ID)
        );

        // check balance
        assertEq(newbieVilla.balanceOf(Const.SECOND_CHARACTER_ID), amount);
    }

    function testTokensReceivedFail() public {
        // case 1: unknown receiving
        vm.expectRevert("NewbieVilla: unknown receiving");
        vm.prank(alice);
        token.send(address(newbieVilla), 1 ether, "");

        // case 2: unknown receiving
        vm.expectRevert("NewbieVilla: unknown receiving");
        vm.prank(alice);
        token.send(address(newbieVilla), 1 ether, abi.encode(uint256(1)));

        // case 3: invalid token
        vm.expectRevert("NewbieVilla: invalid token");
        newbieVilla.tokensReceived(
            address(this),
            alice,
            address(newbieVilla),
            1 ether,
            abi.encode(uint256(1), uint256(2)),
            ""
        );

        // check balance
        assertEq(newbieVilla.balanceOf(Const.SECOND_CHARACTER_ID), 0);
    }

    function testExpired() public {
        vm.expectRevert("NewbieVilla: receipt has expired");
        newbieVilla.withdraw(bob, 1, 0, block.timestamp - 1, "");
    }

    function testNewbieRole() public {
        // check role
        assertEq(cbt.hasRole(ADMIN_ROLE, alice), false);
        assertEq(cbt.hasRole(ADMIN_ROLE, bob), false);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, alice), false);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, bob), false);

        // grant role
        cbt.grantRole(ADMIN_ROLE, bob);
        cbt.grantRole(DEFAULT_ADMIN_ROLE, alice);

        // check role
        assertEq(cbt.hasRole(ADMIN_ROLE, alice), false);
        assertEq(cbt.hasRole(ADMIN_ROLE, bob), true);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, alice), true);
        assertEq(cbt.hasRole(DEFAULT_ADMIN_ROLE, bob), false);

        // get role member
        assertEq(cbt.getRoleMember(DEFAULT_ADMIN_ROLE, 1), alice);
        assertEq(cbt.getRoleMember(ADMIN_ROLE, 0), bob);

        // get role admin
        assertEq(cbt.getRoleAdmin(ADMIN_ROLE), DEFAULT_ADMIN_ROLE);
        assertEq(cbt.getRoleAdmin(DEFAULT_ADMIN_ROLE), DEFAULT_ADMIN_ROLE);

        // revoke role
        cbt.revokeRole(ADMIN_ROLE, bob);
        assertEq(cbt.hasRole(ADMIN_ROLE, bob), false);
    }

    function testNewbieRenounceRole() public {
        // grant role to bob
        cbt.grantRole(ADMIN_ROLE, bob);
        assertEq(cbt.hasRole(ADMIN_ROLE, bob), true);
        assertEq(cbt.getRoleMemberCount(ADMIN_ROLE), 1);
        assertEq(cbt.getRoleMember(ADMIN_ROLE, 0), bob);

        // renounce role
        vm.prank(bob);
        cbt.renounceRole(ADMIN_ROLE, bob);
        assertEq(cbt.hasRole(ADMIN_ROLE, bob), false);
        assertEq(cbt.getRoleMemberCount(ADMIN_ROLE), 0);
    }
}
