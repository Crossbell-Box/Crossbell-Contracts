// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/misc/Tips.sol";
import "../../contracts/mocks/MiraToken.sol";
import "forge-std/console2.sol";
import "forge-std/InvariantTest.sol";
import "forge-std/Test.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
import { Vm }       from "forge-std/Vm.sol";

contract TransferHandler is StdUtils {

    mapping(bytes32 => uint256) public numCalls;
    uint256 public sumBalance;

    Tips public tips;
    MiraToken public token;

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    constructor(address tips_, address token_) {
        token = MiraToken(token_);
        tips = Tips(tips_);
        token.mint(address(this), 10 ether);
    }

    function tipToken(address owner, address to,uint256 amount, bytes calldata data) public virtual {
        numCalls["unboundedTransfer.tip"]++;

        token.mint(owner, amount);

        vm.prank(owner);
        token.send(to, amount, data);
        sumBalance += amount;
    }

}

// contract BoundedTransferHandler is UnboundedTransferHandler {

//     constructor(address asset_, address token_) UnboundedTransferHandler(asset_, token_) { }

//     function transferAssetToToken(address owner, uint256 assets) public override {
//         numCalls["boundedTransfer.transfer"]++;

//         assets = bound(assets, 0, token.totalAssets() / 100);

//         super.transferAssetToToken(owner, assets);
//     }

// }
