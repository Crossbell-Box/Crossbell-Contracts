import { ethers } from "hardhat";
import { Events__factory, Events, Linklist, Web3Entry } from "../typechain";

export let eventsLib: Events;
export let linkList: Linklist;
export let web3Entry: Web3Entry;

beforeEach(async () => {
    const [deployer] = await ethers.getSigners();

    const Linklist = await ethers.getContractFactory("Linklist");
    linkList = await Linklist.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry");
    web3Entry = await Web3Entry.deploy();

    await linkList.deployed();
    await web3Entry.deployed();

    await linkList.initialize("Link List Token", "LLT", web3Entry.address);
    await web3Entry.initialize("Web3 Entry Profile", "WEP", linkList.address);

    eventsLib = await new Events__factory(deployer).deploy();
});
