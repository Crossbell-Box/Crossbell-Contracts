// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {CommonTest} from "./helpers/CommonTest.sol";
import {Web3Entry} from "../contracts/Web3Entry.sol";
import {IWeb3Entry} from "../contracts/interfaces/IWeb3Entry.sol";
import {TransparentUpgradeableProxy} from "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import {OP} from "../contracts/libraries/OP.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {TransparentUpgradeableProxy} from "../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract UpgradeWeb3Entry is CommonTest {
    using EnumerableSet for EnumerableSet.AddressSet;

    // test upgradeability of web3Entry from crossbell fork
    address payable internal _web3Entry = payable(address(0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8));
    address internal _linklist = address(0xFc8C75bD5c26F50798758f387B698f207a016b6A);
    address internal _proxyAdmin = address(0x5f603895B48F0C451af39bc7e0c587aE15718e4d);

    function setUp() public {
        // create and select a fork from crossbell at block 41621719
        vm.createSelectFork("https://rpc.crossbell.io", 41621719);
    }

    function testCheckSetupState() public view {
        assertEq(IWeb3Entry(_web3Entry).getLinklistContract(), _linklist);

        bytes32 v = vm.load(_web3Entry, bytes32(uint256(20)));
        assertEq(uint256(v >> 160), uint256(3)); // initialize version
    }

    function testInitializeFail() public {
        Web3Entry newImpl = new Web3Entry();
        // upgrade
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_web3Entry).upgradeTo(address(newImpl));

        // initialize
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        IWeb3Entry(_web3Entry).initialize(
            "Web3 Entry Character", "WEC", _linklist, address(mintNFTImpl), address(periphery), address(newbieVilla)
        );
    }

    function testCheckStorage() public {
        Web3Entry newImpl = new Web3Entry();
        // upgrade
        vm.prank(_proxyAdmin);
        TransparentUpgradeableProxy(_web3Entry).upgradeTo(address(newImpl));

        // check state
        uint256 characterId = 4418;
        string memory handle = IWeb3Entry(_web3Entry).getHandle(characterId);
        address characterOwner = IERC721(_web3Entry).ownerOf(characterId);
        assertEq(handle, "albert");
        assertEq(IWeb3Entry(_web3Entry).getLinklistContract(), _linklist);
        assertEq(IWeb3Entry(_web3Entry).getHandle(characterId), handle);
        assertEq(
            IWeb3Entry(_web3Entry).getCharacterUri(characterId),
            "ipfs://bafkreig2gii2uuvrhfftfzqibjpztwt5kfyouuj2p2xpnvlakau4fzmtme"
        );
        assertEq(IWeb3Entry(_web3Entry).getLinklistId(characterId, FollowLinkType), 151);
        assertEq(IWeb3Entry(_web3Entry).getLinklistType(151), FollowLinkType);
        assertEq(IWeb3Entry(_web3Entry).getCharacter(characterId).noteCount, 51);
        assertEq(IWeb3Entry(_web3Entry).getCharacterByHandle(handle).characterId, characterId);
        assertEq(IWeb3Entry(_web3Entry).isPrimaryCharacter(characterId), true);
        assertEq(IWeb3Entry(_web3Entry).getPrimaryCharacterId(characterOwner), characterId);
    }
}
