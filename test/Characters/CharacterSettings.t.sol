// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {Test} from "forge-std/Test.sol";
import {Web3Entry} from "../../contracts/Web3Entry.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {Events} from "../../contracts/libraries/Events.sol";
import {ErrHandleExists, ErrNotEnoughPermission} from "../../contracts/libraries/Error.sol";
import {Utils} from "../helpers/Utils.sol";
import {SetUp} from "../helpers/SetUp.sol";

contract CharacterSettingsTest is Test, SetUp, Utils {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
    }

    function testSetCharacterUri() public {
        DataTypes.CreateCharacterData memory characterData = makeCharacterData(
            MOCK_CHARACTER_HANDLE,
            alice
        );
        vm.prank(alice);
        web3Entry.createCharacter(characterData);
        // User should fail to create character or set handle with exists handle
        vm.expectRevert(abi.encodeWithSelector(ErrHandleExists.selector));
        vm.prank(alice);
        web3Entry.createCharacter(characterData);

        // UserTwo should fail to set character uri as a character owned by user 1
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.setCharacterUri(1, MOCK_URI);

        // User should set new character uri
        vm.prank(alice);
        web3Entry.setCharacterUri(1, "fake-uri");

        // Should return the correct tokenURI after transfer
        vm.prank(alice);
        web3Entry.transferFrom(alice, bob, 1);
        string memory uri = web3Entry.getCharacterUri(1);
        assertEq(uri, "fake-uri");
    }
}
