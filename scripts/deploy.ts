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

    const newbieVilla = "0xD0c83f0BB2c61D55B3d33950b70C59ba2f131caA";

    // We get the contract to deploy

    const MintNFT = await ethers.getContractFactory("MintNFT");
    const mintNFT = await MintNFT.deploy();

    const Linklist = await ethers.getContractFactory("Linklist");
    const linkList = await Linklist.deploy();

    const Periphery = await ethers.getContractFactory("Periphery");
    const periphery = await Periphery.deploy();

    const CharacterLib = await ethers.getContractFactory("CharacterLib");
    const characterLib = await CharacterLib.deploy();

    const OperatorLib = await ethers.getContractFactory("OperatorLib");
    const operatorLib = await OperatorLib.deploy();

    const PostLib = await ethers.getContractFactory("PostLib");
    const postLib = await PostLib.deploy();

    const LinkLib = await ethers.getContractFactory("LinkLib");
    const linkLib = await LinkLib.deploy();

    const LinklistLib = await ethers.getContractFactory("LinklistLib");
    const linklistLib = await LinklistLib.deploy();

    const MetaTxLib = await ethers.getContractFactory("MetaTxLib");
    const metaTxLib = await MetaTxLib.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry", {
        libraries: {
            CharacterLib: characterLib.address,
            OperatorLib: operatorLib.address,
            PostLib: postLib.address,
            LinkLib: linkLib.address,
            LinklistLib: linklistLib.address,
            MetaTxLib: metaTxLib.address,
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
            newbieVilla,
        );

    await linkList
        .attach(proxyLinklist.address)
        .connect(addr1)
        .initialize("Link List Token", "LLT", proxyWeb3Entry.address);

    await periphery
        .attach(proxyPeriphery.address)
        .connect(addr1)
        .initialize(proxyWeb3Entry.address, proxyLinklist.address);

    console.log("CharacterLib.sol deployed to:", characterLib.address);
    console.log("PostLib.sol deployed to:", postLib.address);
    console.log("LinkLib.sol deployed to:", linkLib.address);
    console.log("LinklistLib.sol deployed to:", linklistLib.address);
    console.log("MetaTxLib.sol deployed to:", metaTxLib.address);
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
