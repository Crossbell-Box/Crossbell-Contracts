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

    // We get the contract to deploy

    const LinkModuleLogic = await ethers.getContractFactory("LinkModuleLogic");
    const linkModuleLogic = await LinkModuleLogic.deploy();

    const CharacterLogic = await ethers.getContractFactory("CharacterLogic");
    const characterLogic = await CharacterLogic.deploy();

    const PostLogic = await ethers.getContractFactory("PostLogic");
    const postLogic = await PostLogic.deploy();

    const LinkLogic = await ethers.getContractFactory("LinkLogic");
    const linkLogic = await LinkLogic.deploy();

    const OperatorLogic = await ethers.getContractFactory("OperatorLogic");
    const operatorLogic = await OperatorLogic.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry", {
        libraries: {
            LinkModuleLogic: linkModuleLogic.address,
            CharacterLogic: characterLogic.address,
            PostLogic: postLogic.address,
            LinkLogic: linkLogic.address,
            OperatorLogic: operatorLogic.address,
        },
    });
    const web3Entry = await Web3Entry.deploy();
    await web3Entry.deployed();

    // proxyWeb3Entry
    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxyWeb3Entry = await Proxy.attach("0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8");
    await proxyWeb3Entry.upgradeTo(web3Entry.address);

    console.log("LinkModuleLogic deployed to:", linkModuleLogic.address);
    console.log("CharacterLogic deployed to:", characterLogic.address);
    console.log("PostLogic deployed to:", postLogic.address);
    console.log("LinkLogic deployed to:", linkLogic.address);
    console.log("OperatorLogic deployed to:", operatorLogic.address);
    console.log("Web3Entry deployed to:", web3Entry.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
