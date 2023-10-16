// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {CommonTest} from "./helpers/CommonTest.sol";
import {NewbieVilla} from "../contracts/misc/NewbieVilla.sol";
import {
    TransparentUpgradeableProxy
} from "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract UpgradeNewbieVillaTest is CommonTest {
    // test upgradeability of NewbieVilla from crossbell fork
    address internal _web3Entry = address(0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8);
    address internal constant _token = 0xAfB95CC0BD320648B3E8Df6223d9CDD05EbeDC64;
    address payable internal _newbieVilla =
        payable(address(0xD0c83f0BB2c61D55B3d33950b70C59ba2f131caA));
    address internal _proxyAdmin = address(0x5f603895B48F0C451af39bc7e0c587aE15718e4d);

    function setUp() public {
        // create and select a fork from crossbell at block 46718115
        vm.createSelectFork(vm.envString("CROSSBELL_RPC_URL"), 46718115);
    }

    function testCheckSetupState() public {
        assertEq(NewbieVilla(_newbieVilla).web3Entry(), _web3Entry);
        assertEq(NewbieVilla(_newbieVilla).getToken(), _token);
    }

    function testUpgradeNewbieVilla() public {
        NewbieVilla newImpl = new NewbieVilla();
        // upgrade and initialize
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_newbieVilla).upgradeTo(address(newImpl));
        // check newImpl
        vm.prank(_proxyAdmin);
        assertEq(TransparentUpgradeableProxy(_newbieVilla).implementation(), address(newImpl));
        // check state
        assertEq(NewbieVilla(_newbieVilla).web3Entry(), _web3Entry);
        assertEq(NewbieVilla(_newbieVilla).getToken(), _token);
    }

    function testUpgradeNewbieVillaWithStorageCheck() public {
        // create and select a fork from crossbell at block 46718115
        vm.createSelectFork(vm.envString("CROSSBELL_RPC_URL"), 46718115);

        NewbieVilla newImpl = new NewbieVilla();
        // upgrade
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_newbieVilla).upgradeTo(address(newImpl));

        NewbieVilla newbieVilla = NewbieVilla(_newbieVilla);

        // transfer character to newbieVilla
        address owner = 0xC8b960D09C0078c18Dcbe7eB9AB9d816BcCa8944;
        vm.prank(owner);
        IERC721(_web3Entry).safeTransferFrom(owner, _newbieVilla, 10);
        assertEq(newbieVilla.getKeeper(10), owner);

        // check storage
        assertEq(newbieVilla.web3Entry(), _web3Entry);
        assertEq(newbieVilla.getToken(), _token);
        assertEq(newbieVilla.hasRole(ADMIN_ROLE, 0x51e2368D60Bc329DBd5834370C1e633bE60C1d6D), true);

        assertEq(
            vm.load(address(newbieVilla), bytes32(uint256(7))),
            bytes32(uint256(uint160(0x0058be0845952D887D1668B5545de995E12e8783)))
        );
    }
}
