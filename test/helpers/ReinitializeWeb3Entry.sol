// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {NFTBase} from "../../contracts/base/NFTBase.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ReinitializeWeb3Entry is NFTBase, Initializable {
    function initialize(string calldata name_, string calldata symbol_) external reinitializer(3) {
        super._initialize(name_, symbol_);
    }
}
