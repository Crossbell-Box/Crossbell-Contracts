// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/Web3Entry.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract CharacterSettingsTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);

    function setUp() public {
        _setUp();
    }

    function testCharacterHandle() public {
        DataTypes.CreateCharacterData memory characterData = makeCharacterData(
            Const.MOCK_CHARACTER_HANDLE,
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
        web3Entry.setCharacterUri(1, Const.MOCK_URI);

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
