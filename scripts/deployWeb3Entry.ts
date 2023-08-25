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
    const linklist = "0xFc8C75bD5c26F50798758f387B698f207a016b6A";
    const mintNFTImpl = "0x24AACCD73aE036dB1bb9CD279D41BD2675dec737";
    const periphery = "0x96e96b7AF62D628cE7eb2016D2c1D2786614eA73";
    const newbieVilla = "0xD0c83f0BB2c61D55B3d33950b70C59ba2f131caA";

    // We get the contract to deploy

    const CharacterLib = await ethers.getContractFactory("CharacterLib");
    const characterLib = await CharacterLib.deploy();

    const PostLib = await ethers.getContractFactory("PostLib");
    const postLib = await PostLib.deploy();

    const LinkLib = await ethers.getContractFactory("LinkLib");
    const linkLib = await LinkLib.deploy();

    const LinklistLib = await ethers.getContractFactory("LinklistLib");
    const linklistLib = await LinklistLib.deploy();

    const OperatorLib = await ethers.getContractFactory("OperatorLib");
    const operatorLib = await OperatorLib.deploy();

    const MetaTxLib = await ethers.getContractFactory("MetaTxLib");
    const metaTxLib = await MetaTxLib.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry", {
        libraries: {
            CharacterLib: characterLib.address,
            PostLib: postLib.address,
            LinkLib: linkLib.address,
            LinklistLib: linklistLib.address,
            OperatorLib: operatorLib.address,
            MetaTxLib: metaTxLib.address,
        },
    });
    const web3Entry = await Web3Entry.deploy();
    await web3Entry.deployed();
    await web3Entry.initialize(
        "Web3 Entry Character",
        "WEC",
        linklist,
        mintNFTImpl,
        periphery,
        newbieVilla,
    );

    console.log("CharacterLib.sol deployed to:", characterLib.address);
    console.log("PostLib.sol deployed to:", postLib.address);
    console.log("LinkLib.sol deployed to:", linkLib.address);
    console.log("OperatorLib.sol deployed to:", operatorLib.address);
    console.log("Web3Entry deployed to:", web3Entry.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
