// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/misc/Tips.sol";
import "../../contracts/mocks/MiraToken.sol";
import "../../contracts/interfaces/IWeb3Entry.sol";
import "forge-std/console2.sol";
import "forge-std/InvariantTest.sol";
import "forge-std/Test.sol";
import {StdUtils} from "forge-std/StdUtils.sol";
import {Vm} from "forge-std/Vm.sol";
import {CommonBase} from "forge-std/Base.sol";
// import {LibAddressSet} from "./LibAddressSet.sol";

struct AddressSet {
    address[] addrs;
    mapping(address => bool) saved;
}

contract TransferHandler is Utils {
    using LibAddressSet for AddressSet;
    AddressSet internal _actors;

    mapping(bytes32 => uint256) public numCalls;
    uint256 public sumBalance;

    Tips public tips;
    MiraToken public token;
    IWeb3Entry public web3Entry;

    address public admin = address(0x11111);
    address internal currentActor;

    constructor(address tips_, address token_, address web3Entry_) {
        token = MiraToken(token_);
        tips = Tips(tips_);
        web3Entry = IWeb3Entry(web3Entry_);
    }

    function actors() external view returns (address[] memory) {
        return _actors.addrs;
    }

    modifier createActor(address tipper, address toCharacterAddress) {
        currentActor = tipper;
        _actors.add(tipper);
        _actors.add(toCharacterAddress);
        _;
    }

    function mintToken(address owner, uint256 amount) public {
        numCalls["TransferHandler.mintMira"]++;

        vm.prank(admin);
        token.mint(owner, amount);

        sumBalance += amount;
    }

    function tipCharacter(
        address tipper,
        address to,
        uint256 amount
    ) public createActor(tipper, to) {
        numCalls["TransferHandler.tip"]++;
        _fundTiper(tipper, amount);

        uint256 tipperCharacterId = _createCharacterForToAddress(tipper);
        uint256 toCharacterId = _createCharacterForToAddress(to);

        amount = bound(amount, 0, address(tipper).balance);
        bytes memory data = abi.encode(tipperCharacterId, toCharacterId, Const.FIRST_NOTE_ID);

        vm.prank(tipper);
        token.send(address(tips), amount, data);
    }

    function _fundTiper(address tiper, uint256 amount) public {
        vm.prank(admin);
        token.mint(tiper, amount);

        sumBalance += amount;
    }

    function _createCharacterForToAddress(address to) public returns (uint256) {
        uint256 characterId = web3Entry.getPrimaryCharacterId(to);
        if (characterId == 0) {
            characterId = web3Entry.createCharacter(
                makeCharacterData(Strings.toHexString(uint256(uint160(to)), 20), to)
            );
            require(characterId > 0, "Failed creating character");
            return characterId;
        } else {
            return characterId;
        }
    }
}

library LibAddressSet {
    function add(AddressSet storage s, address addr) public {
        if (!s.saved[addr]) {
            s.addrs.push(addr);
            s.saved[addr] = true;
        }
    }

    function contains(AddressSet storage s, address addr) internal view returns (bool) {
        return s.saved[addr];
    }

    function count(AddressSet storage s) internal view returns (uint256) {
        return s.addrs.length;
    }
}
