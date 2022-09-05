import { ethers } from "hardhat";

async function main() {
    const [owner, addr1] = await ethers.getSigners();
    const admin = owner.address;

    const proxyWeb3Entry = "0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8";

    const CharacterBoundToken = await ethers.getContractFactory("CharacterBoundToken");
    const characterBoundToken = await CharacterBoundToken.deploy(proxyWeb3Entry);
    await characterBoundToken.deployed();

     console.log("characterBoundToken deployed to:", characterBoundToken.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});