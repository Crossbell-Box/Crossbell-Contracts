// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/misc/Thanks.sol";
import "../../contracts/mocks/Currency.sol";

contract ThanksTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x333);

    Thanks public t;
    address public token;

    // custom errors
    error ErrCallerNotCharacterOwner();

    // events
    event ThankCharacter(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount
    );
    event ThankNote(
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        uint256 indexed toNoteId,
        address token,
        uint256 amount
    );

    function setUp() public {
        _setUp();

        // deploy and init Thanks contract
        t = new Thanks();
        t.initialize(address(web3Entry));

        // deploy and mint token
        Currency currency = new Currency();
        currency.mint(alice, 10 ether);
        token = address(currency);

        vm.prank(alice);
        currency.approve(address(t), type(uint256).max);

        // create characters
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testSetupState() public {
        // check status after initialization
        assertEq(t.web3Entry(), address(web3Entry));
    }

    function testReinitializeFail() public {
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        t.initialize(address(0x10));

        // check status
        assertEq(t.web3Entry(), address(web3Entry));
    }

    function testThankCharacter(uint256 amount) public {
        vm.assume(amount < 10 ether);

        // expect events
        expectEmit(CheckAll);
        emit ThankCharacter(Const.FIRST_CHARACTER_ID, Const.SECOND_CHARACTER_ID, token, amount);
        vm.prank(alice);
        t.thankCharacter(Const.FIRST_CHARACTER_ID, Const.SECOND_CHARACTER_ID, token, amount);
    }

    function testThankCharacterFail() public {
        uint256 amount = 1 ether;

        // case 1: caller is not character owner
        //        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotCharacterOwner.selector));
        //        t.thankCharacter(Const.FIRST_CHARACTER_ID, Const.SECOND_CHARACTER_ID, token, amount);

        // case 2: character does not exist
        vm.expectRevert("ERC721: owner query for nonexistent token");
        t.thankCharacter(3, Const.SECOND_CHARACTER_ID, token, amount);
        vm.prank(alice);
        vm.expectRevert("ERC721: owner query for nonexistent token");
        t.thankCharacter(Const.FIRST_CHARACTER_ID, 4, token, amount);
    }

    function testThankNote(uint256 amount) public {
        vm.assume(amount < 10 ether);

        // expect events
        expectEmit(CheckAll);
        emit ThankNote(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            token,
            amount
        );
        vm.prank(alice);
        t.thankNote(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            token,
            amount
        );
    }

    function testThankNoteFail() public {
        uint256 amount = 1 ether;

        // case 1: caller is not character owner
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotCharacterOwner.selector));
        t.thankNote(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CHARACTER_ID,
            Const.FIRST_NOTE_ID,
            token,
            amount
        );

        // case 2: character does not exist
        vm.expectRevert("ERC721: owner query for nonexistent token");
        t.thankNote(3, Const.SECOND_CHARACTER_ID, Const.FIRST_NOTE_ID, token, amount);
        vm.prank(alice);
        vm.expectRevert("ERC721: owner query for nonexistent token");
        t.thankNote(Const.FIRST_CHARACTER_ID, 4, Const.FIRST_NOTE_ID, token, amount);
    }
}
