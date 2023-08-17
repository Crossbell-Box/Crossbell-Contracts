// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Events} from "../../contracts/libraries/Events.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {ErrNotEnoughPermission} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract LinkAddressTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        _createCharacter(CHARACTER_HANDLE, alice);
        _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testLinkAddress() public {
        expectEmit(CheckAll);
        emit Events.LinkAddress(FIRST_CHARACTER_ID, address(0x1232414), FollowLinkType, 1);
        // alice link an address
        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                FIRST_CHARACTER_ID,
                address(0x1232414),
                FollowLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // link twice
        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                FIRST_CHARACTER_ID,
                address(0x1232414),
                FollowLinkType,
                new bytes(0)
            )
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                FIRST_CHARACTER_ID,
                address(0x1232414),
                FollowLinkType,
                new bytes(0)
            )
        );

        // check state
        address[] memory linkingAddress = linklist.getLinkingAddresses(1);
        assertEq(linkingAddress.length, 1);
        assertEq(linkingAddress[0], address(0x1232414));
        assertEq(linklist.getLinkingAddressListLength(1), 1);
    }

    function testLinkAddressFail() public {
        // case 1: NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                FIRST_CHARACTER_ID,
                address(0x1232414),
                FollowLinkType,
                new bytes(0)
            )
        );
    }

    function testUnlinkAddress() public {
        nft.mint(bob);
        vm.startPrank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                FIRST_CHARACTER_ID,
                address(0x1232414),
                FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckAll);
        emit Events.UnlinkAddress(FIRST_CHARACTER_ID, address(0x1232414), FollowLinkType);
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(FIRST_CHARACTER_ID, address(0x1232414), FollowLinkType)
        );

        // unlink twice
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(FIRST_CHARACTER_ID, address(0x1232414), FollowLinkType)
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        assertEq(linklist.getOwnerCharacterId(1), FIRST_CHARACTER_ID);
        assertEq(linklist.getLinkingAddresses(1).length, 0);
        assertEq(linklist.getLinkingAddressListLength(1), 0);
    }

    function testUnlinkAddressFail() public {
        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                FIRST_CHARACTER_ID,
                address(0x1232414),
                FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(FIRST_CHARACTER_ID, address(0x1232414), FollowLinkType)
        );
    }
}
