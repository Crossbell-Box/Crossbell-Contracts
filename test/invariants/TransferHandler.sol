// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/misc/Tips.sol";
import "../../contracts/mocks/MiraToken.sol";
import "forge-std/console2.sol";
import "forge-std/InvariantTest.sol";
import "forge-std/Test.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {Vm} from "forge-std/Vm.sol";
import {CommonBase} from "forge-std/Base.sol";
// import {LibAddressSet} from "./LibAddressSet.sol";

struct AddressSet {
    address[] addrs;
    mapping(address => bool) saved;
}

contract TransferHandler is CommonBase, StdCheats, StdUtils  {
    using LibAddressSet for AddressSet;
    AddressSet internal _actors;

    mapping(bytes32 => uint256) public numCalls;
    uint256 public sumBalance;
    
    Tips public tips;
    MiraToken public token;

    address public admin = address(0x11111);

    constructor(address tips_, address token_) {
        token = MiraToken(token_);
        tips = Tips(tips_);
    }

    function actors() external view returns (address[] memory) {
        return _actors.addrs;
    }

    modifier createActor() {
        _actors.add(msg.sender);
        _;
    }

    
    function mintToken(address owner, uint256 amount) public {
        numCalls["TransferHandler.mintMira"]++;

        vm.prank(admin);
        token.mint(owner, amount);

        sumBalance += amount;
    }

    function tipToken(
        address owner,
        address to,
        uint256 amount,
        bytes calldata data
    ) public {
        numCalls["TransferHandler.tip"]++;
        _fundTiper(owner, amount);
        amount = bound(amount, 0, address(owner).balance);
        
        vm.prank(owner);
        token.send(to, amount, data);
    }

    function _fundTiper(address tiper, uint256 amount) public {
        vm.prank(admin);
        token.mint(tiper, amount);

        sumBalance += amount;
    }
}

library LibAddressSet {
    function add(AddressSet storage s, address addr) public {
        if (!s.saved[addr]) {
            s.addrs.push(addr);
            s.saved[addr] = true;
        }
    }

    function contains(
      AddressSet storage s,
      address addr
    ) internal view returns (bool) {
        return s.saved[addr];
    }

    function count(
        AddressSet storage s
    ) internal view returns (uint256) {
        return s.addrs.length;
    }
}