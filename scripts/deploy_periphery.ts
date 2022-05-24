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

    const [owner, addr1] = await ethers.getSigners();
    const admin = owner.address;

    const web3EntryProxyAddress = "0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8";
    const linklistProxyAddress = "0xFc8C75bD5c26F50798758f387B698f207a016b6A";

    const Periphery = await ethers.getContractFactory("Periphery");
    const periphery = await Periphery.deploy();

    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxyPeriphery = await Proxy.deploy(periphery.address, admin, "0x");

    await periphery.deployed();
    await proxyPeriphery.deployed();

    await periphery
        .attach(proxyPeriphery.address)
        .connect(addr1)
        .initialize(web3EntryProxyAddress, linklistProxyAddress);

    console.log("periphery deployed to:", periphery.address);
    console.log("proxyPeriphery deployed to:", proxyPeriphery.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
