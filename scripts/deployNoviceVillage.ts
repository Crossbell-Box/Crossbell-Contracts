import { ethers } from "hardhat";

async function main() {
    const [owner, addr1] = await ethers.getSigners();
    const admin = owner.address;

    const NoviceVillage = await ethers.getContractFactory("NoviceVillage");
    const noviceVillage = await NoviceVillage.deploy();

    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxyNoviceVillage = await Proxy.deploy(noviceVillage.address, admin, "0x");

    await noviceVillage.deployed();
    await proxyNoviceVillage.deployed();


    const proxyWeb3Entry = await Proxy.attach("0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8");

    await noviceVillage
        .attach(proxyNoviceVillage.address)
        .connect(addr1)
        .initialize(proxyWeb3Entry.address);

    console.log("noviceVillage deployed to:", noviceVillage.address);
    console.log("proxyNoviceVillage deployed to:", proxyNoviceVillage.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});