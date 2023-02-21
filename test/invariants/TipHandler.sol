// SPDX-License-Identifier: MIT
// solhint-disable check-send-result, comprehensive-interface
pragma solidity 0.8.16;

import "../helpers/utils.sol";
import "../helpers/SetUp.sol";
import "../../contracts/misc/Tips.sol";
import "../../contracts/mocks/MiraToken.sol";
import "../../contracts/interfaces/IWeb3Entry.sol";
import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract TipHandler is Utils {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ghost varibles
    uint256 public sumOfFunds;
    uint256 public sumOfTips;
    mapping(bytes32 => uint256) public numCalls;

    Tips public tips;
    MiraToken public token;
    IWeb3Entry public web3Entry;

    address public miraAdmin = address(0x11111);
    address internal _currentTipper;
    address internal _currentTo;
    EnumerableSet.AddressSet internal _actors; // record all actors
    uint256 public constant MIRA_TOTAL_SUPPLY = 100000 ether;

    modifier createTipper(address tipper) {
        numCalls["TipHandler.CreateTiper"]++;
        _currentTipper = tipper;
        _actors.add(_currentTipper);
        _;
    }

    modifier createTo(address to) {
        numCalls["TipHandler.CreateTo"]++;
        _currentTo = to;
        _actors.add(_currentTo);
        _;
    }

    constructor(address tips_, address token_, address web3Entry_) {
        token = MiraToken(token_);
        tips = Tips(tips_);
        web3Entry = IWeb3Entry(web3Entry_);

        // prefund mira admin
        vm.prank(miraAdmin);
        token.mint(miraAdmin, MIRA_TOTAL_SUPPLY);
    }

    function getActors() external view returns (address[] memory) {
        return _actors.values();
    }

    function tipCharacter(
        address to,
        uint256 fundAmount,
        uint256 tipAmount
    ) public createTipper(msg.sender) createTo(to) {
        numCalls["TipHandler.TipCharacter"]++;
        console2.log("starting tip character..., the random tipper is", _currentTipper);
        console2.log("starting tip character..., the random to is", _currentTo);

        fundAmount = bound(fundAmount, 0, token.balanceOf(miraAdmin));
        fundTiper(fundAmount);

        vm.startPrank(_currentTipper);
        tipAmount = bound(tipAmount, 0, address(_currentTipper).balance);

        uint256 tipperCharacterId = createCharacterForActor(_currentTipper);
        uint256 toCharacterId = createCharacterForActor(_currentTo);

        bytes memory data = abi.encode(tipperCharacterId, toCharacterId, Const.FIRST_NOTE_ID);
        vm.prank(_currentTipper);
        token.send(address(tips), tipAmount, data);
        sumOfTips += tipAmount; // solhint-disable reentrancy
    }

    function fundTiper(uint256 amount) public {
        numCalls["TipHandler.FundTiper"]++;
        amount = bound(amount, 0, address(miraAdmin).balance);
        vm.prank(miraAdmin);
        bool success = token.transfer(_currentTipper, amount);
        require(success, "Fund tipper failed");
        sumOfFunds += amount;
    }

    function createCharacterForActor(address actor) public returns (uint256) {
        numCalls["TipHandler.CreateCharacter"]++;
        uint256 characterId = web3Entry.getPrimaryCharacterId(actor);
        if (characterId == 0) {
            characterId = web3Entry.createCharacter(
                makeCharacterData(Strings.toHexString(uint256(uint160(actor)), 20), actor)
            );
            require(characterId > 0, "Failed creating character");
            return characterId;
        } else {
            return characterId;
        }
    }
}
