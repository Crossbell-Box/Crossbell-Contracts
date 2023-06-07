// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface,check-send-result,multiple-sends
pragma solidity 0.8.16;

import {CommonTest} from "../helpers/CommonTest.sol";
import {TipsWithFee} from "../../contracts/misc/TipsWithFee.sol";
import {MiraToken} from "../../contracts/mocks/MiraToken.sol";

contract TipsWithFeeTest is CommonTest {
    uint256 public constant initialBalance = 10 ether;

    TipsWithFee internal _tips;

    event TipCharacter(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 fee,
        address feeReceiver
    );

    event TipCharacterForNote(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        uint256 indexed toNoteId,
        address token,
        uint256 amount,
        uint256 fee,
        address feeReceiver
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
        //        token.mint(carol, initialBalance);

        // deploy and init Tips contract
        _tips = new TipsWithFee();
        _tips.initialize(address(web3Entry), address(token));

        // create characters
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testSetupState() public {
        // check status after initialization
        assertEq(_tips.getWeb3Entry(), address(web3Entry));
        assertEq(_tips.getToken(), address(token));
    }

    function testReinitializeFail() public {
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        _tips.initialize(address(0x10), address(0x10));

        // check status
        assertEq(_tips.getWeb3Entry(), address(web3Entry));
        assertEq(_tips.getToken(), address(token));
    }

    function testSetDefaultFeeFraction(uint256 fraction) public {
        vm.assume(fraction <= 10000);

        vm.prank(alice);
        _tips.setDefaultFeeFraction(alice, fraction);

        assertEq(_tips.getFeeFraction(alice, 1, 0), fraction);
        assertEq(_tips.getFeeAmount(alice, 1, 0, 10000), fraction);
    }

    function testSetFeeFraction4Character(uint256 fraction, uint256 characterId) public {
        vm.assume(fraction <= 10000);
        vm.assume(characterId < 10 && characterId > 0);

        vm.prank(alice);
        _tips.setFeeFraction4Character(alice, characterId, fraction);

        assertEq(_tips.getFeeFraction(alice, characterId, 0), fraction);
        assertEq(_tips.getFeeAmount(alice, characterId, 0, 10000), fraction);
    }

    function testSetFeeFraction4Note(uint256 fraction, uint256 characterId, uint256 noteId) public {
        vm.assume(fraction <= 10000);
        vm.assume(characterId < 10 && characterId > 0);
        vm.assume(noteId < 10 && noteId > 0);

        vm.prank(alice);
        _tips.setFeeFraction4Note(alice, characterId, noteId, fraction);

        assertEq(_tips.getFeeFraction(alice, characterId, noteId), fraction);
        assertEq(_tips.getFeeAmount(alice, characterId, noteId, 10000), fraction);
    }

    function testGetFeeFraction(uint256 fraction, uint256 characterId, uint256 noteId) public {
        vm.assume(fraction <= 10000);
        vm.assume(characterId < 10 && characterId > 0);
        vm.assume(noteId < 10 && noteId > 0);

        vm.startPrank(alice);
        _tips.setDefaultFeeFraction(alice, fraction);
        assertEq(_tips.getFeeFraction(alice, characterId, noteId), fraction);

        _tips.setFeeFraction4Character(alice, characterId, fraction + 2);
        assertEq(_tips.getFeeFraction(alice, characterId, noteId), fraction + 2);

        _tips.setFeeFraction4Note(alice, characterId, noteId, fraction + 1);
        assertEq(_tips.getFeeFraction(alice, characterId, noteId), fraction + 1);
        vm.stopPrank();
    }

    function testTipCharacter(uint256 amount, uint256 fraction) public {
        vm.assume(amount < 1 ether && amount > 0);
        vm.assume(fraction < 10000 && fraction > 0);

        vm.prank(carol);
        _tips.setDefaultFeeFraction(carol, fraction);

        bytes memory data = abi.encode(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID, carol);
        uint256 feeAmount = _tips.getFeeAmount(carol, SECOND_CHARACTER_ID, 0, amount);

        // expect events
        expectEmit(CheckAll);
        emit Sent(alice, alice, address(_tips), amount, data, "");
        expectEmit(CheckAll);
        emit Transfer(alice, address(_tips), amount);
        expectEmit(CheckAll);
        emit Sent(
            address(_tips),
            address(_tips),
            bob,
            amount - feeAmount,
            abi.encode(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID),
            ""
        );
        expectEmit(CheckAll);
        emit Transfer(address(_tips), bob, amount - feeAmount);
        expectEmit(CheckAll);
        emit Sent(
            address(_tips),
            address(_tips),
            carol,
            feeAmount,
            abi.encode(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID),
            ""
        );
        expectEmit(CheckAll);
        emit Transfer(address(_tips), carol, feeAmount);
        expectEmit(CheckAll);
        emit TipCharacter(
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            address(token),
            amount,
            feeAmount,
            carol
        );
        vm.prank(alice);
        token.send(address(_tips), amount, data);

        // check balance
        assertEq(token.balanceOf(alice), initialBalance - amount);
        assertEq(token.balanceOf(bob), amount - feeAmount);
        assertEq(token.balanceOf(carol), feeAmount);
    }

    function testTipCharacterFailx() public {
        uint256 amount = 1 ether;

        // case 1: caller is not character owner
        vm.expectRevert("TipsWithFee: caller is not character owner");
        vm.prank(alice);
        token.send(
            address(_tips),
            amount,
            abi.encode(SECOND_CHARACTER_ID, FIRST_CHARACTER_ID, FIRST_NOTE_ID, carol)
        );

        // case 2: character does not exist
        vm.expectRevert("ERC721: owner query for nonexistent token");
        vm.prank(alice);
        token.send(
            address(_tips),
            amount,
            abi.encode(3, SECOND_CHARACTER_ID, FIRST_NOTE_ID, carol)
        );

        vm.expectRevert("ERC721: owner query for nonexistent token");
        vm.prank(alice);
        token.send(address(_tips), amount, abi.encode(FIRST_CHARACTER_ID, 4, FIRST_NOTE_ID, carol));

        // check balance
        assertEq(token.balanceOf(alice), initialBalance);
        assertEq(token.balanceOf(alice), initialBalance);
        assertEq(token.balanceOf(bob), 0);
    }

    function testTipCharacter4Note(uint256 amount, uint256 fraction) public {
        vm.assume(amount < 1 ether && amount > 0);
        vm.assume(fraction < 10000 && fraction > 0);

        vm.prank(carol);
        _tips.setFeeFraction4Note(carol, SECOND_CHARACTER_ID, FIRST_NOTE_ID, fraction);

        bytes memory data = abi.encode(
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            FIRST_NOTE_ID,
            carol
        );
        uint256 feeAmount = _tips.getFeeAmount(carol, SECOND_CHARACTER_ID, FIRST_NOTE_ID, amount);

        // expect events
        expectEmit(CheckAll);
        emit Sent(alice, alice, address(_tips), amount, data, "");
        expectEmit(CheckAll);
        emit Transfer(alice, address(_tips), amount);
        expectEmit(CheckAll);
        emit Sent(
            address(_tips),
            address(_tips),
            bob,
            amount - feeAmount,
            abi.encode(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID),
            ""
        );
        expectEmit(CheckAll);
        emit Transfer(address(_tips), bob, amount - feeAmount);
        expectEmit(CheckAll);
        emit Sent(
            address(_tips),
            address(_tips),
            carol,
            feeAmount,
            abi.encode(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID),
            ""
        );
        expectEmit(CheckAll);
        emit Transfer(address(_tips), carol, feeAmount);
        expectEmit(CheckAll);
        emit TipCharacterForNote(
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            FIRST_NOTE_ID,
            address(token),
            amount,
            feeAmount,
            carol
        );
        vm.prank(alice);
        token.send(address(_tips), amount, data);

        // check balance
        assertEq(token.balanceOf(alice), initialBalance - amount);
        assertEq(token.balanceOf(bob), amount - feeAmount);
        assertEq(token.balanceOf(carol), feeAmount);
    }

    function testTipCharacterForNoteFail() public {
        uint256 amount = 1 ether;

        // case 1: caller is not character owner
        vm.expectRevert("TipsWithFee: caller is not character owner");
        vm.prank(alice);
        token.send(
            address(_tips),
            amount,
            abi.encode(SECOND_CHARACTER_ID, SECOND_CHARACTER_ID, FIRST_NOTE_ID, carol)
        );

        // case 2: character does not exist
        vm.expectRevert("ERC721: owner query for nonexistent token");
        vm.prank(alice);
        token.send(
            address(_tips),
            amount,
            abi.encode(3, SECOND_CHARACTER_ID, FIRST_NOTE_ID, carol)
        );

        vm.expectRevert("ERC721: owner query for nonexistent token");
        vm.prank(alice);
        token.send(address(_tips), amount, abi.encode(FIRST_CHARACTER_ID, 4, FIRST_NOTE_ID));

        // check balance
        assertEq(token.balanceOf(alice), initialBalance);
        assertEq(token.balanceOf(alice), initialBalance);
        assertEq(token.balanceOf(bob), 0);
    }
}
