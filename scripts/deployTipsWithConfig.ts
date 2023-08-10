// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
    const proxyWeb3Entry = "0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8";
    const proxyAdminMultisig = "0x5f603895B48F0C451af39bc7e0c587aE15718e4d";

    // initialize data
    let ABI = ["function initialize(address)"];
    let iface = new ethers.utils.Interface(ABI);
    let data = iface.encodeFunctionData("initialize", [proxyWeb3Entry]);
    // console.log(data);

    // deploy TipsWithFee contract
    const Tips = await ethers.getContractFactory("TipsWithConfig");
    const tips = await Tips.deploy();
    await tips.deployed();
    await tips.initialize(proxyWeb3Entry);

    // deploy proxy with initialized data
    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxyTips = await Proxy.deploy(tips.address, proxyAdminMultisig, data);
    await proxyTips.deployed();
    // await tips.initialize(proxyWeb3Entry, miraToken);

    console.log("proxyTips deployed to:", proxyTips.address);
    console.log("tips logic deployed to:", tips.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
