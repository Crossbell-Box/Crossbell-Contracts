// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface,check-send-result,multiple-sends
pragma solidity 0.8.18;

import {CommonTest} from "../helpers/CommonTest.sol";
import {TipsWithConfig} from "../../contracts/misc/TipsWithConfig.sol";
import {MiraToken} from "../../contracts/mocks/MiraToken.sol";
import {ITipsWithConfig} from "../../contracts/interfaces/ITipsWithConfig.sol";

contract TipsWithConfigTest is CommonTest {
    uint256 public constant initialBalance = 10000 ether;

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
        address feeReceiver,
        uint256 totalRound
    );

    event CollectTips4Character(
        uint256 indexed tipConfigId,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 fee,
        address feeReceiver,
        uint256 currentRound
    );

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function testSetDefaultFeeFraction(uint256 fraction) public {
        vm.assume(fraction <= 10000);

        vm.prank(alice);
        _tips.setDefaultFeeFraction(alice, fraction);

        assertEq(_tips.getFeeFraction(alice, 1), fraction);
        assertEq(_tips.getFeeAmount(alice, 1, 10000), fraction);
    }

    function testSetDefaultFeeFractionFail() public {
        vm.expectRevert("TipsWithConfig: caller is not fee receiver");
        _tips.setDefaultFeeFraction(alice, 100);

        vm.expectRevert("TipsWithConfig: fraction out of range");
        vm.prank(alice);
        _tips.setDefaultFeeFraction(alice, 10001);

        assertEq(_tips.getFeeFraction(alice, 1), 0);
    }

    function testSetFeeFraction4Character(uint256 fraction, uint256 characterId) public {
        vm.assume(fraction <= 10000);
        vm.assume(characterId < 10 && characterId > 0);

        vm.prank(alice);
        _tips.setFeeFraction4Character(alice, characterId, fraction);

        assertEq(_tips.getFeeFraction(alice, characterId), fraction);
        assertEq(_tips.getFeeAmount(alice, characterId, 10000), fraction);
    }

    function testSetFeeFraction4CharacterFail() public {
        vm.expectRevert("TipsWithConfig: caller is not fee receiver");
        _tips.setFeeFraction4Character(alice, 1, 100);

        vm.expectRevert("TipsWithConfig: fraction out of range");
        vm.prank(alice);
        _tips.setFeeFraction4Character(alice, 1, 10001);

        assertEq(_tips.getFeeFraction(alice, 1), 0);
    }

    function testGetFeeFraction(uint256 fraction, uint256 characterId) public {
        vm.assume(fraction <= 10000);
        vm.assume(characterId < 10 && characterId > 0);

        vm.startPrank(alice);
        _tips.setDefaultFeeFraction(alice, fraction);
        assertEq(_tips.getFeeFraction(alice, characterId), fraction);

        _tips.setFeeFraction4Character(alice, characterId, fraction + 2);
        assertEq(_tips.getFeeFraction(alice, characterId), fraction + 2);
        vm.stopPrank();
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
            address(1),
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
            interval,
            address(1)
        );

        // check status
        assertEq(_tips.getTipsConfigId(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID), 1);
        _checkConfig(
            _tips.getTipsConfig(1),
            ITipsWithConfig.TipsConfig({
                id: 1,
                fromCharacterId: FIRST_CHARACTER_ID,
                toCharacterId: SECOND_CHARACTER_ID,
                token: address(token),
                amount: amount,
                startTime: startTime,
                endTime: endTime,
                interval: interval,
                feeReceiver: address(1),
                totalRound: (endTime - startTime) / interval + 1,
                currentRound: 0
            })
        );
    }

    function testSetTipsConfig4CharacterWithUpdateConfig() public {
        uint256 amount = 1 ether;
        uint256 interval = 10 days;
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 2 * interval;

        vm.startPrank(alice);
        token.approve(address(_tips), 1 ether);
        _tips.setTipsConfig4Character(
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            address(token),
            amount,
            startTime,
            endTime,
            interval,
            address(1)
        );

        // check status
        assertEq(_tips.getTipsConfigId(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID), 1);
        _checkConfig(
            _tips.getTipsConfig(1),
            ITipsWithConfig.TipsConfig({
                id: 1,
                fromCharacterId: FIRST_CHARACTER_ID,
                toCharacterId: SECOND_CHARACTER_ID,
                token: address(token),
                amount: amount,
                startTime: startTime,
                endTime: endTime,
                interval: interval,
                feeReceiver: address(1),
                totalRound: (endTime - startTime) / interval + 1,
                currentRound: 0
            })
        );

        skip(interval / 2);

        amount = 2 ether;
        interval = 20 days;
        startTime = block.timestamp;
        endTime = startTime + interval;

        _tips.setTipsConfig4Character(
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            address(token),
            amount,
            startTime,
            endTime,
            interval,
            address(2)
        );
        vm.stopPrank();

        // check status
        assertEq(_tips.getTipsConfigId(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID), 1);
        _checkConfig(
            _tips.getTipsConfig(1),
            ITipsWithConfig.TipsConfig({
                id: 1,
                fromCharacterId: FIRST_CHARACTER_ID,
                toCharacterId: SECOND_CHARACTER_ID,
                token: address(token),
                amount: amount,
                startTime: startTime,
                endTime: endTime,
                interval: interval,
                feeReceiver: address(2),
                totalRound: (endTime - startTime) / interval + 1,
                currentRound: 0
            })
        );
        // check balances
        assertEq(token.balanceOf(alice), initialBalance - 1 ether);
        assertEq(token.balanceOf(bob), 1 ether);
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
            interval,
            address(0)
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
            interval,
            address(0)
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
            interval,
            address(0)
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
            0,
            address(0)
        );
    }

    function testcollectTips4Character(uint256 amount, uint256 interval) public {
        vm.assume(amount > 0 && amount < initialBalance);
        vm.assume(interval > 0 && interval < 100 days);

        uint256 startTime = block.timestamp + 10;
        uint256 endTime = startTime + 2 * interval;

        vm.startPrank(alice);
        token.approve(address(_tips), amount);
        _tips.setTipsConfig4Character(
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            address(token),
            amount,
            startTime,
            endTime,
            interval,
            address(0)
        );
        vm.stopPrank();

        skip(10);

        // expect events
        expectEmit(CheckAll);
        emit Approval(alice, address(_tips), 0);
        expectEmit(CheckAll);
        emit Sent(address(_tips), alice, bob, amount, "", "");
        expectEmit(CheckAll);
        emit Transfer(alice, bob, amount);
        expectEmit(CheckAll);
        emit CollectTips4Character(
            1,
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            address(token),
            amount,
            0,
            address(0),
            1
        );
        _tips.collectTips4Character(1);

        // check status
        assertEq(_tips.getTipsConfigId(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID), 1);
        _checkConfig(
            _tips.getTipsConfig(1),
            ITipsWithConfig.TipsConfig({
                id: 1,
                fromCharacterId: FIRST_CHARACTER_ID,
                toCharacterId: SECOND_CHARACTER_ID,
                token: address(token),
                amount: amount,
                startTime: startTime,
                endTime: endTime,
                interval: interval,
                feeReceiver: address(0),
                totalRound: (endTime - startTime) / interval + 1,
                currentRound: 1
            })
        );
        // check balances
        assertEq(token.balanceOf(alice), initialBalance - amount);
        assertEq(token.balanceOf(bob), amount);
    }

    function testCollectTips4CharacterWithFee(
        uint256 amount,
        uint256 interval,
        uint256 fraction
    ) public {
        vm.assume(amount > 0 && amount < initialBalance / 3);
        vm.assume(interval > 0 && interval < 100 days);
        vm.assume(fraction > 0 && fraction < 10000);

        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 2 * interval;

        // set fee fraction
        address feeReceiver = address(123456);
        vm.startPrank(feeReceiver);
        _tips.setDefaultFeeFraction(feeReceiver, fraction / 2);
        _tips.setFeeFraction4Character(feeReceiver, SECOND_CHARACTER_ID, fraction);
        vm.stopPrank();

        // set tips config
        vm.startPrank(alice);
        token.approve(address(_tips), initialBalance);
        _tips.setTipsConfig4Character(
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            address(token),
            amount,
            startTime,
            endTime,
            interval,
            feeReceiver
        );
        vm.stopPrank();

        // some times later
        skip(interval);

        // collect tips
        _tips.collectTips4Character(1);

        // check status
        assertEq(_tips.getTipsConfigId(FIRST_CHARACTER_ID, SECOND_CHARACTER_ID), 1);
        _checkConfig(
            _tips.getTipsConfig(1),
            ITipsWithConfig.TipsConfig({
                id: 1,
                fromCharacterId: FIRST_CHARACTER_ID,
                toCharacterId: SECOND_CHARACTER_ID,
                token: address(token),
                amount: amount,
                startTime: startTime,
                endTime: endTime,
                interval: interval,
                feeReceiver: feeReceiver,
                totalRound: (endTime - startTime) / interval + 1,
                currentRound: 2
            })
        );
        // check balances
        uint256 feeAmount = (amount * 2 * fraction) / 10000;
        assertEq(token.balanceOf(alice), initialBalance - amount * 2);
        assertEq(token.balanceOf(bob), amount * 2 - feeAmount);
        assertEq(token.balanceOf(feeReceiver), feeAmount);
    }

    function testCollectTips4CharacterFailInvalidStartTime() public {
        uint256 startTime = block.timestamp + 10;
        uint256 endTime = startTime + 20;

        vm.prank(alice);
        _tips.setTipsConfig4Character(
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            address(token),
            1 ether,
            startTime,
            endTime,
            1,
            address(0)
        );

        vm.expectRevert(abi.encodePacked("TipsWithConfig: start time not comes"));
        _tips.collectTips4Character(1);
    }

    function _checkConfig(
        ITipsWithConfig.TipsConfig memory config1,
        ITipsWithConfig.TipsConfig memory config2
    ) internal {
        assertEq(config1.id, config2.id);
        assertEq(config1.fromCharacterId, config2.fromCharacterId);
        assertEq(config1.toCharacterId, config2.toCharacterId);
        assertEq(config1.token, config2.token);
        assertEq(config1.amount, config2.amount);
        assertEq(config1.startTime, config2.startTime);
        assertEq(config1.endTime, config2.endTime);
        assertEq(config1.interval, config2.interval);
        assertEq(config1.feeReceiver, config2.feeReceiver);
        assertEq(config1.totalRound, config2.totalRound);
        assertEq(config1.currentRound, config2.currentRound);
    }
}
