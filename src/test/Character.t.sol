// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "../Web3Entry.sol";
import "../libraries/DataTypes.sol";
import "../libraries/LinkModuleLogic.sol";
import "../libraries/CharacterLogic.sol";
import "../libraries/PostLogic.sol";
import "../libraries/LinkLogic.sol";
import "../MintNFT.sol";
import "../Resolver.sol";
import "../LinkList.sol";
import "../Web3Entry.sol";
import "../misc/Periphery.sol";
import "../upgradeability/TransparentUpgradeableProxy.sol";
import "./EmitExpecter.sol";
import "./Const.sol";
import "./helpers/utils.sol";

contract setUpTest is Test, EmitExpecter, Utils {
    Web3Entry web3Entry;

    address public alice = address(0x1111);
    address public bob = address(0x2222);

    function setUp() public {
        Web3Entry web3EntryImpl = new Web3Entry();
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(web3EntryImpl),
            alice,
            ""
        );
        web3Entry = Web3Entry(address(proxy));
    }

    function testCreateCharacter() public {
        DataTypes.CreateCharacterData memory characterData = makeCharacterData(Const.MOCK_CHARACTER_HANDLE);

        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        // The event we expect
        emit Events.CharacterCreated(1, bob, bob, Const.MOCK_CHARACTER_HANDLE, block.timestamp);
        // The event we get
        vm.prank(bob);
        web3Entry.createCharacter(characterData);

    }

    function testCreateCharacterFail() public {
        string memory handle = "da2423cea4f1047556e7a142f81a7eda";
        DataTypes.CreateCharacterData memory characterData = makeCharacterData(handle);
        vm.expectRevert(abi.encodePacked("HandleLengthInvalid"));
        vm.prank(bob);
        web3Entry.createCharacter(characterData);

        string memory handle2 = "";
        DataTypes.CreateCharacterData memory characterData2 = makeCharacterData(handle2);
        vm.expectRevert(abi.encodePacked("HandleLengthInvalid"));
        vm.prank(bob);
        web3Entry.createCharacter(characterData2);
        
    }
}
