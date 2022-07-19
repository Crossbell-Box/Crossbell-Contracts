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

    const Periphery = await ethers.getContractFactory("Periphery");
    const periphery = await Periphery.deploy();

    const Resolver = await ethers.getContractFactory("Resolver");
    const resolver = await Resolver.deploy();

    const LinkModuleLogic = await ethers.getContractFactory("LinkModuleLogic");
    const linkModuleLogic = await LinkModuleLogic.deploy();

    const CharacterLogic = await ethers.getContractFactory("CharacterLogic");
    const characterLogic = await CharacterLogic.deploy();

    const PostLogic = await ethers.getContractFactory("PostLogic");
    const postLogic = await PostLogic.deploy();

    const LinkLogic = await ethers.getContractFactory("LinkLogic");
    const linkLogic = await LinkLogic.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry", {
        libraries: {
            LinkModuleLogic: linkModuleLogic.address,
            CharacterLogic: characterLogic.address,
            PostLogic: postLogic.address,
            LinkLogic: linkLogic.address,
        },
    });
    const web3Entry = await Web3Entry.deploy();

    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxyWeb3Entry = await Proxy.deploy(web3Entry.address, admin, "0x");
    const proxyLinklist = await Proxy.deploy(linkList.address, admin, "0x");
    const proxyPeriphery = await Proxy.deploy(periphery.address, admin, "0x");

    await mintNFT.deployed();
    await linkList.deployed();
    await web3Entry.deployed();
    await proxyWeb3Entry.deployed();
    await proxyLinklist.deployed();
    await proxyPeriphery.deployed();

    await web3Entry
        .attach(proxyWeb3Entry.address)
        .connect(addr1)
        .initialize(
            "Web3 Entry Character",
            "WEC",
            proxyLinklist.address,
            mintNFT.address,
            proxyPeriphery.address,
            resolver.address
        );

    await linkList
        .attach(proxyLinklist.address)
        .connect(addr1)
        .initialize("Link List Token", "LLT", proxyWeb3Entry.address);

    await periphery
        .attach(proxyPeriphery.address)
        .connect(addr1)
        .initialize(proxyWeb3Entry.address, proxyLinklist.address);

    console.log("LinkModuleLogic deployed to:", linkModuleLogic.address);
    console.log("CharacterLogic deployed to:", characterLogic.address);
    console.log("PostLogic deployed to:", postLogic.address);
    console.log("LinkLogic deployed to:", linkLogic.address);
    console.log("Web3Entry deployed to:", web3Entry.address);
    console.log("periphery deployed to:", periphery.address);
    console.log("Linklist deployed to:", linkList.address);
    console.log("MintNFT impl deployed to:", mintNFT.address);
    console.log("ProxyWeb3Entry deployed to:", proxyWeb3Entry.address);
    console.log("ProxyLinklist deployed to:", proxyLinklist.address);
    console.log("proxyPeriphery deployed to:", proxyPeriphery.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});