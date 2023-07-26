// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface,check-send-result,multiple-sends
pragma solidity 0.8.18;

import {CommonTest} from "../helpers/CommonTest.sol";
import {TipsWithConfig} from "../../contracts/misc/TipsWithConfig.sol";
import {MiraToken} from "../../contracts/mocks/MiraToken.sol";

contract TipsWithFeeTest is CommonTest {
    uint256 public constant initialBalance = 10 ether;

    TipsWithConfig internal _tips;

    event SetTipsConfig4Character(
        uint256 indexed tipConfigId,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 startTime,
        uint256 endTime,
        uint256 interval,
        uint256 tipTimes
    );

    event TriggerTips4Character(
        uint256 indexed tipConfigId,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 redeemedAmount,
        uint256 fee,
        address feeReceiver
    );

    function setUp() public {
        _setUp();

        // deploy and mint token
        token = new MiraToken("Mira Token", "MIRA", address(this));
        token.mint(alice, initialBalance);
        //        token.mint(carol, initialBalance);

        // deploy and init Tips contract
        _tips = new TipsWithConfig();
        _tips.initialize(address(web3Entry));

        // create characters
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testSetupState() public {
        // check status after initialization
        assertEq(_tips.getWeb3Entry(), address(web3Entry));
    }

    function testReinitializeFail() public {
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        _tips.initialize(address(0x10));

        // check status
        assertEq(_tips.getWeb3Entry(), address(web3Entry));
    }

    function testSetTipsConfig4Character(uint256 amount, uint256 interval) public {
        vm.assume(amount > 0);
        vm.assume(interval > 0 && interval < 10 days);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + interval;

        expectEmit(CheckAll);
        emit SetTipsConfig4Character(
            1,
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            address(token),
            amount,
            startTime,
            endTime,
            interval,
            (endTime - startTime) / interval + 1
        );
        vm.prank(alice);
        _tips.setTipsConfig4Character(
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            address(token),
            amount,
            startTime,
            endTime,
            interval
        );
    }

    function testSetTipsConfig4CharacterWithUpdateConfig() public {
        // TODO
        vm.prank(alice);
    }

    function testSetTipsConfig4CharacterFail(uint256 interval) public {
        vm.assume(interval > 0 && interval < 10 days);

        // case 1: msg.sender is not character owner
        vm.expectRevert("TipsWithConfig: not character owner");
        _tips.setTipsConfig4Character(
            1,
            2,
            address(token),
            1 ether,
            block.timestamp + 10,
            block.timestamp + interval,
            interval
        );

        // case 2: invalid startTime
        vm.expectRevert("TipsWithConfig: invalid startTime");
        vm.prank(alice);
        _tips.setTipsConfig4Character(
            1,
            2,
            address(token),
            1 ether,
            0,
            block.timestamp + 20,
            interval
        );

        // case 3: invalid endTime
        vm.expectRevert("TipsWithConfig: invalid endTime");
        vm.prank(alice);
        _tips.setTipsConfig4Character(
            1,
            2,
            address(token),
            1 ether,
            block.timestamp,
            block.timestamp,
            interval
        );

        // case 4: invalid interval
        vm.expectRevert("TipsWithConfig: interval must be greater than 0");
        vm.prank(alice);
        _tips.setTipsConfig4Character(
            1,
            2,
            address(token),
            1 ether,
            block.timestamp + 10,
            block.timestamp + 20,
            0
        );
    }

    function testTriggerTips4Character() public {
        // TODO
        vm.prank(alice);
    }

    function testTriggerTips4CharacterFail() public {
        // TODO
        vm.prank(alice);
    }
}
