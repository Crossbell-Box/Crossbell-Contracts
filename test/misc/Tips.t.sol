// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface,check-send-result,multiple-sends
pragma solidity 0.8.16;

import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/misc/Tips.sol";
import "../../contracts/mocks/MiraToken.sol";

contract TipsTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x333);

    uint256 public constant initialBalance = 10 ether;

    // custom errors
    error ErrCallerNotCharacterOwner();

    // events
    event TipCharacter(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount
    );
    event TipCharacterForNote(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        uint256 indexed toNoteId,
        address token,
        uint256 amount
    );
    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        _setUp();

        // deploy and mint token
        token = new MiraToken("Mira Token", "MIRA", address(this));
        token.mint(alice, initialBalance);
        token.mint(carol, initialBalance);

        // deploy and init Tips contract
        tips = new Tips();
        tips.initialize(address(web3Entry), address(token));

        // create characters
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testSetupState() public {
        // check status after initialization
        assertEq(tips.getWeb3Entry(), address(web3Entry));
        assertEq(tips.getToken(), address(token));
    }

    function testReinitializeFail() public {
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        tips.initialize(address(0x10), address(0x10));

        // check status
        assertEq(tips.getWeb3Entry(), address(web3Entry));
        assertEq(tips.getToken(), address(token));
    }

    function testTipCharacter(uint256 amount) public {
        vm.assume(amount < 10 ether);

        bytes memory data = abi.encode(Const.FIRST_CHARACTER_ID, Const.SECOND_CHARACTER_ID);

        // expect events
        expectEmit(CheckAll);
        emit Sent(alice, alice, address(tips), amount, data, "");
        expectEmit(CheckAll);
        emit Transfer(alice, address(tips), amount);
        expectEmit(CheckAll);
        emit Sent(address(tips), address(tips), bob, amount, data, "");
        expectEmit(CheckAll);
        emit Transfer(address(tips), bob, amount);
        expectEmit(CheckAll);
        emit TipCharacter(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CHARACTER_ID,
            address(token),
            amount
        );
        vm.prank(alice);
        token.send(address(tips), amount, data);

        // check balance
        assertEq(token.balanceOf(alice), initialBalance - amount);
        assertEq(token.balanceOf(bob), amount);
    }

    function testTipCharacterFail() public {
        uint256 amount = 1 ether;

        // case 1: caller is not character owner
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotCharacterOwner.selector));
        vm.prank(carol);
        token.send(
            address(tips),
            amount,
            abi.encode(Const.FIRST_CHARACTER_ID, Const.SECOND_CHARACTER_ID)
        );

        // case 2: character does not exist
        vm.expectRevert("ERC721: owner query for nonexistent token");
        vm.prank(carol);
        token.send(address(tips), amount, abi.encode(3, Const.SECOND_CHARACTER_ID));

        vm.expectRevert("ERC721: owner query for nonexistent token");
        vm.prank(alice);
        token.send(address(tips), amount, abi.encode(Const.FIRST_CHARACTER_ID, 4));

        // check balance
        assertEq(token.balanceOf(alice), initialBalance);
        assertEq(token.balanceOf(alice), initialBalance);
        assertEq(token.balanceOf(bob), 0);
    }

    function testTipCharacterForNote(uint256 amount) public {
        vm.assume(amount < 10 ether);

        bytes memory data = abi.encode(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CHARACTER_ID,
            Const.FIRST_NOTE_ID
        );

        // expect events
        expectEmit(CheckAll);
        emit Sent(alice, alice, address(tips), amount, data, "");
        expectEmit(CheckAll);
        emit Transfer(alice, address(tips), amount);
        expectEmit(CheckAll);
        emit Sent(
            address(tips),
            address(tips),
            bob,
            amount,
            abi.encode(Const.FIRST_CHARACTER_ID, Const.SECOND_CHARACTER_ID),
            ""
        );
        expectEmit(CheckAll);
        emit Transfer(address(tips), bob, amount);
        expectEmit(CheckAll);
        emit TipCharacterForNote(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            address(token),
            amount
        );
        vm.prank(alice);
        token.send(address(tips), amount, data);

        // check balance
        assertEq(token.balanceOf(alice), initialBalance - amount);
        assertEq(token.balanceOf(bob), amount);
    }

    function testTipCharacterForNoteFail() public {
        uint256 amount = 1 ether;

        // case 1: caller is not character owner
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotCharacterOwner.selector));
        vm.prank(carol);
        token.send(
            address(tips),
            amount,
            abi.encode(Const.FIRST_CHARACTER_ID, Const.SECOND_CHARACTER_ID, Const.FIRST_NOTE_ID)
        );

        // case 2: character does not exist
        vm.expectRevert("ERC721: owner query for nonexistent token");
        vm.prank(carol);
        token.send(
            address(tips),
            amount,
            abi.encode(3, Const.SECOND_CHARACTER_ID, Const.FIRST_NOTE_ID)
        );

        vm.expectRevert("ERC721: owner query for nonexistent token");
        vm.prank(alice);
        token.send(
            address(tips),
            amount,
            abi.encode(Const.FIRST_CHARACTER_ID, 4, Const.FIRST_NOTE_ID)
        );

        // check balance
        assertEq(token.balanceOf(alice), initialBalance);
        assertEq(token.balanceOf(alice), initialBalance);
        assertEq(token.balanceOf(bob), 0);
    }

    function testOperatorSend(uint256 amount) public {
        vm.assume(amount < 10 ether);

        vm.prank(alice);
        token.authorizeOperator(carol);

        vm.prank(carol);
        token.operatorSend(
            alice,
            address(tips),
            amount,
            "",
            abi.encode(Const.FIRST_CHARACTER_ID, Const.SECOND_CHARACTER_ID)
        );

        // check balance
        assertEq(token.balanceOf(bob), amount);
    }

    function testSendFail() public {
        // case 1: unknown receiving
        vm.expectRevert("Tips: unknown receiving");
        vm.prank(alice);
        token.send(address(tips), 1 ether, "");

        // case 2: unknown receiving
        vm.expectRevert("Tips: unknown receiving");
        vm.prank(alice);
        token.send(
            address(tips),
            1 ether,
            abi.encode(uint256(1), uint256(1), uint256(1), uint256(1))
        );

        // case 3: invalid token
        vm.expectRevert("Tips: invalid token");
        tips.tokensReceived(
            address(this),
            alice,
            address(tips),
            1 ether,
            abi.encode(uint256(1), uint256(1), uint256(1)),
            ""
        );
    }
}
