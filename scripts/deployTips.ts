// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
    const [owner, addr1] = await ethers.getSigners();
    const admin = owner.address;

    const proxyWeb3Entry = "0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8";
    const proxyAdminMultisig = "0x2CD6eA7DE6B33C663a669158c70800BAba17a951";

    const Tips = await ethers.getContractFactory("Tips");
    const tips = await Tips.deploy();
    await tips.deployed();
    await tips.initialize(proxyWeb3Entry);

    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxyTips = await Proxy.deploy(tips.address, proxyAdminMultisig, "0x");
    await proxyTips.deployed();
    await tips.attach(proxyTips.address).connect(addr1).initialize(proxyWeb3Entry);

    console.log("proxyTips deployed to:", proxyTips.address);
    console.log("tips logic deployed to:", tips.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
