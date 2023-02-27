// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "../../contracts/base/NFTBase.sol";
import "../../contracts/interfaces/IWeb3Entry.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ReinitializeWeb3Entry is NFTBase, Initializable {
    function initialize(string calldata name_, string calldata symbol_) external reinitializer(3) {
        super._initialize(name_, symbol_);
    }
}
