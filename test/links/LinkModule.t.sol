// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {ErrNotAddressOwner} from "../../contracts/libraries/Error.sol";
import {CommonTest} from "../helpers/CommonTest.sol";

contract LinkModuleTest is CommonTest {
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
        _createCharacter(CHARACTER_HANDLE, alice);
        web3Entry.createCharacter(
            DataTypes.CreateCharacterData(
                bob,
                CHARACTER_HANDLE2,
                CHARACTER_URI,
                address(linkModule4Character),
                abi.encode(allowlist)
            )
        );

        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                FIRST_CHARACTER_ID,
                SECOND_CHARACTER_ID,
                LikeLinkType,
                new bytes(1)
            )
        );

        web3Entry.createCharacter(makeCharacterData("imdick", dick));
        vm.prank(dick);
        web3Entry.linkCharacter(DataTypes.linkCharacterData(3, 2, LikeLinkType, new bytes(1)));
    }
}
