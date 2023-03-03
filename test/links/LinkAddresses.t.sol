// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../../contracts/Web3Entry.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../../contracts/libraries/Error.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract LinkAddressTest is Test, SetUp, Utils {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));
    }

    function testLinkAddress() public {
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.LinkAddress(
            Const.FIRST_CHARACTER_ID,
            address(0x1232414),
            Const.FollowLinkType,
            1
        );
        // alice link an address
        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // link twice
        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // periphery can link
        // the first input is msg.sender and the second input is tx.origin
        vm.prank(address(periphery), alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType,
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
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType,
                new bytes(0)
            )
        );
    }

    function testUnlinkAddress() public {
        nft.mint(bob);
        vm.startPrank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Events.UnlinkAddress(
            Const.FIRST_CHARACTER_ID,
            address(0x1232414),
            Const.FollowLinkType
        );
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType
            )
        );

        // unlink twice
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType
            )
        );
        vm.stopPrank();

        // check linklist
        assertEq(linklist.ownerOf(1), alice);

        // check state
        assertEq(linklist.getOwnerCharacterId(1), Const.FIRST_CHARACTER_ID);
        assertEq(linklist.getLinkingAddresses(1).length, 0);
        assertEq(linklist.getLinkingAddressListLength(1), 0);
    }

    function testUnlinkAddressFail() public {
        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // unlink
        vm.expectRevert(abi.encodeWithSelector(ErrNotEnoughPermission.selector));
        vm.prank(bob);
        web3Entry.unlinkAddress(
            DataTypes.unlinkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType
            )
        );
    }
}
