// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore,no-console
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";
import {stdJson} from "forge-std/StdJson.sol";

/// @title DeployConfig
/// @notice Represents the configuration required to deploy the system. It is expected
///         to read the file from JSON. A future improvement would be to have fallback
///         values if they are not defined in the JSON themselves.
contract DeployConfig is Script {
    string internal _json;

    uint256 public chainID;
    address public proxyAdminOwner;
    string public web3EntryTokenName;
    string public web3EntryTokenSymbol;
    string public linklistTokenName;
    string public linklistTokenSymbol;
    address public xsyncOperator;
    address public miraToken;
    address public newbieVillaAdmin;

    constructor(string memory _path) {
        console.log("DeployConfig: reading file %s", _path);
        try vm.readFile(_path) returns (string memory data) {
            _json = data;
        } catch {
            console.log(
                "Warning: unable to read config. Do not deploy unless you are not using config."
            );
            return;
        }

        chainID = stdJson.readUint(_json, "$.chainID");
        proxyAdminOwner = stdJson.readAddress(_json, "$.proxyAdminOwner");
        web3EntryTokenName = stdJson.readString(_json, "$.web3EntryTokenName");
        web3EntryTokenSymbol = stdJson.readString(_json, "$.web3EntryTokenSymbol");
        linklistTokenName = stdJson.readString(_json, "$.linklistTokenName");
        linklistTokenSymbol = stdJson.readString(_json, "$.linklistTokenSymbol");
        xsyncOperator = stdJson.readAddress(_json, "$.xsyncOperator");
        miraToken = stdJson.readAddress(_json, "$.miraToken");
        newbieVillaAdmin = stdJson.readAddress(_json, "$.newbieVillaAdmin");
    }
}
