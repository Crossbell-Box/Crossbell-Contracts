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

    const newbieVilla = "0xcE9950c48d0E955833d1297a35F5579Cf4E1a6c2";
    const proxyAdminMultisig = "0x2CD6eA7DE6B33C663a669158c70800BAba17a951";

    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxyNewbieVilla = await Proxy.deploy(newbieVilla, proxyAdminMultisig, "0x");
    await proxyNewbieVilla.deployed();

    console.log("proxyNewbieVilla deployed to:", newbieVilla.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
