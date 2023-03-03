// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../../contracts/Web3Entry.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract LinkModuleTest is Test, SetUp, Utils {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
    }

    function testLinkCharacterWithLinkModule() public {
        // User not in approval list should not fail to link a character
        address[] memory allowlist = new address[](2);
        allowlist[0] = carol;
        allowlist[1] = bob;

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(
            DataTypes.CreateCharacterData(
                bob,
                Const.MOCK_CHARACTER_HANDLE2,
                Const.MOCK_CHARACTER_URI,
                address(linkModule4Character),
                abi.encode(allowlist)
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

        web3Entry.createCharacter(makeCharacterData("imdick", dick));
        vm.prank(dick);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(3, 2, Const.LikeLinkType, new bytes(1))
        );
    }

    function testSetLinkModule4Address() public {
        // owner can setMintModule4Note
        vm.prank(alice);
        // TODO: tackle with return data(implement ApprovalLinkModule4Address.sol)
        // expectEmit(CheckAll);
        // emit Events.SetLinkModule4Address(
        //     alice,
        //     address(0),
        //     new bytes(0),
        //     block.timestamp
        // );
        web3Entry.setLinkModule4Address(
            DataTypes.setLinkModule4AddressData(alice, address(0), new bytes(0))
        );

        // check module
        address module = web3Entry.getLinkModule4Address(alice);
        assertEq(module, address(0));
    }

    function testSetLinkModule4AddressFail() public {
        // not owner can't
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotAddressOwner.selector));
        web3Entry.setLinkModule4Address(
            DataTypes.setLinkModule4AddressData(alice, address(0), new bytes(0))
        );
    }
}
