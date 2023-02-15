// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;


import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/misc/Tips.sol";
import "../../contracts/mocks/MiraToken.sol";
import "../../contracts/mocks/Currency.sol";
import "forge-std/console2.sol";
import "forge-std/InvariantTest.sol";
import "forge-std/Test.sol";
import "./TransferHandler.sol";
import "../helpers/SetUp.sol";
import "../../lib/forge-std/lib/ds-test/src/test.sol";

contract BaseInvariants is Test, SetUp, Utils  {
    Tips public tips;
    // MiraToken public token;
    Currency public token;
    TransferHandler public transferHandler;

    address[] public _excludedContracts;

    function setUp() public {
        _setUp();

        token = new Currency();
        
        tips = new Tips();
        tips.initialize(address(web3Entry), address(token));

        transferHandler = new TransferHandler(address(tips), address(token));

        _excludedContracts = [address(web3Entry), address(proxyWeb3Entry)];
    }

    function invariant_A() public {
        uint256 _totalSupply = token.totalSupply();
        assert(true);
        assertGe(_totalSupply, 0);
        assertGe(_totalSupply, transferHandler.sumBalance());
    }
}