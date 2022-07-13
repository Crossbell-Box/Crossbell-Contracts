// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../Web3Entry.sol";
import "../Linklist.sol";
import "../MintNFT.sol";
import "../libraries/DataTypes.sol";
import "../upgradeability/TransparentUpgradeableProxy.sol";
import "../modules/link/ApprovalLinkModule4Character.sol";
import "./helpers/EmitExpecter.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";

import "./helpers/SetUp.sol";

contract LinkModuleTest is Test, SetUp, EmitExpecter, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public userThree = address(0x3333);

    function setUp() public {
        _setUp();
    }

    function testLinkCharacterWithLinkModule() public {
        // User not in approval list should not fail to link a character
        address[] memory whitelist = new address[](2);
        whitelist[0] = userThree;
        whitelist[1] = bob;

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(
            DataTypes.CreateCharacterData(
                bob,
                Const.MOCK_CHARACTER_HANDLE2,
                Const.MOCK_CHARACTER_URI,
                address(linkModule4Character),
                abi.encode(whitelist)
            )
        );

        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType,
                new bytes(1)
            )
        );
    }
}
