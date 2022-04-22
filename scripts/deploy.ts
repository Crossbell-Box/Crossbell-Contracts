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

    const MintNFT = await ethers.getContractFactory("MintNFT");
    const mintNFT = await MintNFT.deploy();

    const Linklist = await ethers.getContractFactory("Linklist");
    const linkList = await Linklist.deploy();

    const InteractionLogic = await ethers.getContractFactory("InteractionLogic");
    const interactionLogic = await InteractionLogic.deploy();

    const ProfileLogic = await ethers.getContractFactory("ProfileLogic");
    const profileLogic = await ProfileLogic.deploy();

    const PostLogic = await ethers.getContractFactory("PostLogic");
    const postLogic = await PostLogic.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry", {
        libraries: {
            InteractionLogic: interactionLogic.address,
            ProfileLogic: profileLogic.address,
            PostLogic: postLogic.address,
        },
    });
    const web3Entry = await Web3Entry.deploy();

    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxyWeb3Entry = await Proxy.deploy(web3Entry.address, admin, "0x");
    const proxyLinklist = await Proxy.deploy(linkList.address, admin, "0x");

    await mintNFT.deployed();
    await linkList.deployed();
    await web3Entry.deployed();
    await proxyWeb3Entry.deployed();
    await proxyLinklist.deployed();

    await web3Entry
        .attach(proxyWeb3Entry.address)
        .connect(addr1)
        .initialize("Web3 Entry Profile", "WEP", proxyLinklist.address, mintNFT.address);

    await linkList
        .attach(proxyLinklist.address)
        .connect(addr1)
        .initialize("Link List Token", "LLT", proxyWeb3Entry.address);

    console.log("Linklist deployed to:", linkList.address);
    console.log("Web3Entry deployed to:", web3Entry.address);
    console.log("ProxyWeb3Entry deployed to:", proxyWeb3Entry.address);
    console.log("ProxyLinklist deployed to:", proxyLinklist.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
