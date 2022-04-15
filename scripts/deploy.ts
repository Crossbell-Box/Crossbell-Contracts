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

    // We get the contract to deploy
    const Linklist = await ethers.getContractFactory("Linklist");
    const linkList = await Linklist.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry");
    const web3Entry = await Web3Entry.deploy();

    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxy = await Proxy.deploy(web3Entry.address, admin, "0x");

    await linkList.deployed();
    await web3Entry.deployed();
    await proxy.deployed();

    await linkList.initialize("Link List Token", "LLT", proxy.address);

    await web3Entry
        .attach(proxy.address)
        .connect(addr1)
        .initialize("Web3 Entry Profile", "WEP", linkList.address);
    console.log("Linklist deployed to:", linkList.address);
    console.log("Proxy deployed to:", proxy.address);
    console.log("Web3Entry deployed to:", web3Entry.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
