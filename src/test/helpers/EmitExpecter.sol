// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@std/Vm.sol";
import "@std/Test.sol";

contract EmitExpecter is Test {
    uint8 public constant CheckTopic1 = 0x1;
    uint8 public constant CheckTopic2 = 0x2;
    uint8 public constant CheckTopic3 = 0x4;
    uint8 public constant CheckData = 0x8;

    function expectEmit() public {
        expectEmit(0);
    }

    function expectEmit(uint8 checks) public {
        require(checks < 16, "Invalid emitOptions passed to expectEmit");

        uint8 mask = 0x1; //0001
        bool checkTopic1 = (checks & mask) > 0;
        bool checkTopic2 = (checks & (mask << 1)) > 0;
        bool checkTopic3 = (checks & (mask << 2)) > 0;
        bool checkData = (checks & (mask << 3)) > 0;

        vm.expectEmit(checkTopic1, checkTopic2, checkTopic3, checkData);
    }
}
