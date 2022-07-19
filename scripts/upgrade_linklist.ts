// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    const [owner] = await ethers.getSigners();

    const Linklist = await ethers.getContractFactory("Linklist");
    const linkList = await Linklist.deploy();

    // proxyWeb3Entry
    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxyLinklist = await Proxy.attach("0xFc8C75bD5c26F50798758f387B698f207a016b6A");
    await proxyLinklist.upgradeTo(linkList.address);

    console.log("linkList deployed to:", linkList.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});