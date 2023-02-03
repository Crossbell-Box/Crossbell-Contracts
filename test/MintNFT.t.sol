// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../contracts/MintNFT.sol";
import "../contracts/libraries/Error.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";

contract MintNFTTest is Test, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    MintNFT public nft;
    address public web3Entry = address(1);

    function setUp() public {
        nft = new MintNFT();
        nft.initialize(1, 1, web3Entry, "name", "symbol");
    }

    function testMint() public {
        // mint nft
        vm.prank(web3Entry);
        nft.mint(bob);

        // check states
        assertEq(nft.totalSupply(), 1);
        assertEq(nft.balanceOf(bob), 1);
        assertEq(nft.ownerOf(1), bob);
    }

    function testMintFail() public {
        // caller is not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        nft.mint(bob);
    }
}
