// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {CommonTest} from "./helpers/CommonTest.sol";

contract CharacterSettingsTest is CommonTest {
    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();
    }

    function testSetupState() public {
        assertEq(web3Entry.name(), WEB3_ENTRY_NFT_NAME);
        assertEq(web3Entry.symbol(), WEB3_ENTRY_NFT_SYMBOL);
        assertEq(web3Entry.getRevision(), 4);
        assertEq(web3Entry.getLinklistContract(), address(linklist));
    }
}
