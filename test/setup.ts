import { ethers } from "hardhat";
import { Events__factory, Events, Linklist, Web3Entry } from "../typechain";

export const FIRST_PROFILE_ID = 1;
export const SECOND_PROFILE_ID = 2;

export const FIRST_LINKLIST_ID = 1;

export let eventsLib: Events;
export let linkList: Linklist;
export let web3Entry: Web3Entry;

beforeEach(async () => {
    const [deployer] = await ethers.getSigners();

    const InteractionLogic = await ethers.getContractFactory("InteractionLogic");
    const interactionLogic = await InteractionLogic.deploy();

    const ProfileLogic = await ethers.getContractFactory("ProfileLogic");
    const profileLogic = await ProfileLogic.deploy();

    const PostLogic = await ethers.getContractFactory("PostLogic");
    const postLogic = await PostLogic.deploy();

    const Linklist = await ethers.getContractFactory("Linklist");
    linkList = await Linklist.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry", {
        libraries: {
            InteractionLogic: interactionLogic.address,
            ProfileLogic: profileLogic.address,
            PostLogic: postLogic.address,
        },
    });
    web3Entry = await Web3Entry.deploy();

    await linkList.deployed();
    await web3Entry.deployed();

    await linkList.initialize("Link List Token", "LLT", web3Entry.address);
    await web3Entry.initialize(
        "Web3 Entry Profile",
        "WEP",
        linkList.address,
        ethers.constants.AddressZero
    );

    eventsLib = await new Events__factory(deployer).deploy();
});
