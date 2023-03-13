// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {ErrCallerNotWeb3Entry} from "../contracts/libraries/Error.sol";
import {MintNFT} from "../contracts/MintNFT.sol";
import {CommonTest} from "./helpers/CommonTest.sol";

contract MintNFTTest is CommonTest {
    MintNFT public nft_;
    address public web3Entry_ = address(1);

    function setUp() public {
        nft_ = new MintNFT();
        nft_.initialize(1, 1, web3Entry_, "name", "symbol");
    }

    function testMint() public {
        // mint nft
        vm.prank(web3Entry_);
        nft_.mint(bob);

        // check states
        assertEq(nft_.totalSupply(), 1);
        assertEq(nft_.balanceOf(bob), 1);
        assertEq(nft_.ownerOf(1), bob);
    }

    function testMintFail() public {
        // caller is not web3Entry
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        nft_.mint(bob);
    }
}
