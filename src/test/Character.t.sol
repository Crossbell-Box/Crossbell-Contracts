// SPDX-License-Identifier: UNLICENSED
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

contract setUpTest is Test, EmitExpecter {
    Web3Entry web3Entry;

    address public alice = address(0x1111);
    address public bob = address(0x2222);

    uint256 characterId = 1;
    string character_uri =
        "https://raw.githubusercontent.com/Crossbell-Box/Crossbell-Contracts/main/examples/sampleProfile.json";
    string character_handle = "0xcrossbell-eth";

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
        DataTypes.CreateCharacterData memory characterData = DataTypes.CreateCharacterData(
            alice,
            character_handle,
            character_uri,
            address(0),
            ""
        );

        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        // The event we expect
        emit Events.CharacterCreated(1, bob, alice, character_handle, block.timestamp);
        // The event we get
        vm.prank(bob);
        web3Entry.createCharacter(characterData);
    }
}
