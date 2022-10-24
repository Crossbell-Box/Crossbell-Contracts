import { ethers } from "hardhat";

async function main() {
    const [owner, addr1] = await ethers.getSigners();
    const admin = owner.address;

    const NewbieVilla = await ethers.getContractFactory("NewbieVilla");
    const newbieVilla = await NewbieVilla.deploy();

    const Proxy = await ethers.getContractFactory("TransparentUpgradeableProxy");
    const proxyNewbieVilla = await Proxy.deploy(newbieVilla.address, admin, "0x");

    await newbieVilla.deployed();
    await proxyNewbieVilla.deployed();

    const proxyWeb3Entry = await Proxy.attach("0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8");

    await newbieVilla
        .attach(proxyNewbieVilla.address)
        .connect(addr1)
        .initialize(proxyWeb3Entry.address);

    console.log("newbieVilla deployed to:", newbieVilla.address);
    console.log("proxyNewbieVilla deployed to:", proxyNewbieVilla.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
