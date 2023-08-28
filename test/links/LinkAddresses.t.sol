// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Events} from "../../contracts/libraries/Events.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {ErrNotEnoughPermission} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract LinkAddressTest is CommonTest {
    uint256 public firstCharacter;
    uint256 public secondCharacter;

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        firstCharacter = _createCharacter(CHARACTER_HANDLE, alice);
        secondCharacter = _createCharacter(CHARACTER_HANDLE2, bob);
    }

    function testLinkAddress() public {
        address ethAddress = vm.addr(1);

        expectEmit(CheckAll);
        emit Events.LinkAddress(firstCharacter, ethAddress, FollowLinkType, 1);
        //  link an address
        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(firstCharacter, ethAddress, FollowLinkType, "")
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // link twice
        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(firstCharacter, ethAddress, FollowLinkType, "")
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(firstCharacter, ethAddress, FollowLinkType, "")
        );

        // check state
        address[] memory linkingAddress = linklist.getLinkingAddresses(1);
        assertEq(linkingAddress.length, 1);
        assertEq(linkingAddress[0], ethAddress);
        assertEq(linklist.getLinkingAddressListLength(1), 1);
    }

    function testLinkAddressFail() public {
        // case 1: NotEnoughPermission
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        web3Entry.linkAddress(
            DataTypes.linkAddressData(firstCharacter, vm.addr(1), FollowLinkType, "")
        );
    }

    function testUnlinkAddress() public {
        address ethAddress = vm.addr(1);

        nft.mint(bob);

        vm.startPrank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(firstCharacter, ethAddress, FollowLinkType, "")
        );

        // unlink
        expectEmit(CheckAll);
        emit Events.UnlinkAddress(firstCharacter, ethAddress, FollowLinkType);
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(firstCharacter, ethAddress, FollowLinkType)
        );

        // unlink twice
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(firstCharacter, ethAddress, FollowLinkType)
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        assertEq(linklist.getOwnerCharacterId(1), firstCharacter);
        assertEq(linklist.getLinkingAddresses(1).length, 0);
        assertEq(linklist.getLinkingAddressListLength(1), 0);
    }

    function testUnlinkAddressFail() public {
        address ethAddress = vm.addr(1);

        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(firstCharacter, ethAddress, FollowLinkType, "")
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(firstCharacter, ethAddress, FollowLinkType)
        );
    }
}
