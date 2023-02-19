// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface, func-name-mixedcase
pragma solidity 0.8.16;

import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/misc/Tips.sol";
import "../../contracts/mocks/MiraToken.sol";
import "./TipHandler.sol";
import "../helpers/SetUp.sol";
import "forge-std/Test.sol";

contract InvariantTips is Test, SetUp, Utils {
    Tips public tips;
    MiraToken public token;
    TipHandler public tipHandler;

    address public miraAdmin = address(0x11111);

    function setUp() public {
        _setUp();

        token = new MiraToken("Mira Token", "MIRA", miraAdmin);

        tips = new Tips();
        tips.initialize(address(web3Entry), address(token));

        tipHandler = new TipHandler(address(tips), address(token), address(web3Entry));

        targetContract(address(tipHandler));
    }

    /**
     * @notice  Check that `mira total supply = sumFunds + balance of miraAdmin` holds.
     */
    function invariant_totalSupply() public {
        assertEq(
            tipHandler.MIRA_TOTAL_SUPPLY(),
            tipHandler.sumOfTips() + token.balanceOf(miraAdmin)
        );
    }

    /**
     * @notice  Check that `sum of all tips = sum of all actors's balances(except for mira Admin)` holds
     */
    function invariant_totalTips() public {
        uint256 sumOfBalances;
        address[] memory allActors = tipHandler.getActors();
        for (uint256 i; i < allActors.length; ++i) {
            console.log(allActors[i]);
            if (allActors[i] != miraAdmin) {
                sumOfBalances += token.balanceOf(allActors[i]);
            }
        }
        assertEq(tipHandler.sumOfTips(), sumOfBalances);
    }
}
