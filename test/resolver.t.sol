// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../contracts/Resolver.sol";
import "../contracts/libraries/DataTypes.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";

contract ResolverTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    Resolver public resolver;

    function setUp() public {
        resolver = new Resolver();
    }

    function testResolver() public {
        // Admin should add ENS and delete ENS
        string[] memory labels = new string[](3);
        labels[0] = "vitalik";
        labels[1] = "atlas";
        labels[2] = "albert";
        address[] memory owners = new address[](3);
        owners[0] = alice;
        owners[1] = bob;
        owners[2] = carol;
        resolver.addENSRecords(labels, owners);
        uint256 ensCount = resolver.getTotalENSCount();
        assertEq(ensCount, 3);
        uint256 rnsCount = resolver.getTotalRNSCount();
        assertEq(rnsCount, 0);
        string[] memory deleteLabels = new string[](1);
        deleteLabels[0] = "vitalik";
        resolver.deleteENSRecords(deleteLabels);
        uint256 ensCount2 = resolver.getTotalENSCount();
        assertEq(ensCount2, 2);
        uint256 rnsCount2 = resolver.getTotalRNSCount();
        assertEq(rnsCount2, 0);

        // Admin should add RNS and delete RNS
        resolver.addRNSRecords(labels, owners);
        uint256 ensCount3 = resolver.getTotalENSCount();
        assertEq(ensCount3, 2);
        uint256 rnsCount3 = resolver.getTotalRNSCount();
        assertEq(rnsCount3, 3);
        resolver.deleteRNSRecords(deleteLabels);
        uint256 ensCount4 = resolver.getTotalRNSCount();
        assertEq(ensCount4, 2);
        uint256 rnsCount4 = resolver.getTotalRNSCount();
        assertEq(rnsCount4, 2);
    }
}
