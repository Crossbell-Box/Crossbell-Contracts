// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface,check-send-result,multiple-sends
pragma solidity 0.8.18;

import {CommonTest} from "../helpers/CommonTest.sol";
import {TipsWithConfig} from "../../contracts/misc/TipsWithConfig.sol";
import {MiraToken} from "../../contracts/mocks/MiraToken.sol";

contract TipsWithFeeTest is CommonTest {
    uint256 public constant initialBalance = 10 ether;
    uint256 public constant tipConfig = 0;

    TipsWithConfig internal _tips;

    uint256 internal _tipsConfigIndex = 0;

    event SetTipsConfig4Character(
        uint256 indexed tipConfigId,
        uint256 indexed fromCharacterId,
        uint256 indexed toCharacterId,
        address token,
        uint256 amount,
        uint256 startTime,
        uint256 expiration,
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

    // function testSetTipsConfig4Character(uint256 amount) public {
    //     vm.assume(amount < 1 ether && amount > 0);

    //     vm.prank(alice);
    //     _tips.setTipsConfig4Character(1, 2, amount, 3600, 1690365841);

    //     // expect events
    //     expectEmit(CheckAll);
    //     emit SetTipsConfig4Character(1, 1, 2, address(token), amount, 0, 3600, 1690365841, 0);
    // }
}
