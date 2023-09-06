// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.18;

/// @notice The executables used in ffi commands. These are set here
///         to have a single source of truth in case absolute paths
///         need to be used.
library Executables {
    string internal constant bash = "bash";
    string internal constant jq = "jq";
    string internal constant forge = "forge";
    string internal constant echo = "echo";
    string internal constant sed = "sed";
}
