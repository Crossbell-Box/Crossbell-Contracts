import { Signer } from "ethers";
import { ethers } from "hardhat";
import {
    Events__factory,
    Events,
    Linklist,
    Web3Entry,
    Linklist__factory,
    Web3Entry__factory,
} from "../typechain";
import { revertToSnapshot, takeSnapshot } from "./helpers/utils";

export const FIRST_PROFILE_ID = 1;
export const SECOND_PROFILE_ID = 2;

export const FIRST_LINKLIST_ID = 1;
export const FIRST_NOTE_ID = 1;

export const WEB3_ENTRY_NFT_NAME = "Web3 Entry Profile";
export const WEB3_ENTRY_NFT_SYMBOL = "WEP";
export const LINK_LIST_NFT_NAME = "Link List Token";
export const LINK_LIST_NFT_SYMBOL = "LLT";

export const MOCK_PROFILE_URI =
    "https://raw.githubusercontent.com/Crossbell-Box/Crossbell-Contracts/main/examples/sampleProfile.json";
export const MOCK_NOTE_URI =
    "https://github.com/Crossbell-Box/Crossbell-Contracts/blob/main/examples/sampleContent.json";
export const MOCK_PROFILE_HANDLE = "0xcrossbell.eth";
export const MOCK_PROFILE_HANDLE2 = "0xcrossbell-2.eth";
export const bytes32Zero = "0x0000000000000000000000000000000000000000000000000000000000000000";

export let eventsLib: Events;
export let linkList: Linklist;
export let web3Entry: Web3Entry;

export let accounts: Signer[];
export let deployer: Signer;
export let user: Signer;
export let userTwo: Signer;
export let userThree: Signer;
export let deployerAddress: string;
export let userAddress: string;
export let userTwoAddress: string;
export let userThreeAddress: string;

export const FOLLOW_LINKTYPE = ethers.utils.formatBytes32String("follow");

export function makeSuiteCleanRoom(name: string, tests: () => void) {
    describe(name, () => {
        beforeEach(async function () {
            await takeSnapshot();
        });
        tests();
        afterEach(async function () {
            await revertToSnapshot();
        });
    });
}

beforeEach(async () => {
    let linklistImpl: Linklist;
    let web3EntryImpl: Web3Entry;

    accounts = await ethers.getSigners();
    deployer = accounts[0];
    user = accounts[1];
    userTwo = accounts[2];
    userThree = accounts[4];
    let admin = accounts[4];

    deployerAddress = await deployer.getAddress();
    userAddress = await deployer.getAddress();
    userTwoAddress = await userTwo.getAddress();
    userThreeAddress = await userThree.getAddress();
    let adminAddress = await admin.getAddress();

    const InteractionLogic = await ethers.getContractFactory("InteractionLogic");
    const interactionLogic = await InteractionLogic.deploy();

    const ProfileLogic = await ethers.getContractFactory("ProfileLogic");
    const profileLogic = await ProfileLogic.deploy();

    const PostLogic = await ethers.getContractFactory("PostLogic");
    const postLogic = await PostLogic.deploy();

    const MintNFT = await ethers.getContractFactory("MintNFT");
    const mintNFT = await MintNFT.deploy();

    const Linklist = await ethers.getContractFactory("Linklist");
    linklistImpl = await Linklist.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry", {
        libraries: {
            InteractionLogic: interactionLogic.address,
            ProfileLogic: profileLogic.address,
            PostLogic: postLogic.address,
        },
    });
    web3EntryImpl = await Web3Entry.deploy();

    const TransparentUpgradeableProxy = await ethers.getContractFactory(
        "TransparentUpgradeableProxy"
    );
    const web3EntryProxy = await TransparentUpgradeableProxy.connect(admin).deploy(
        web3EntryImpl.address,
        adminAddress,
        []
    );
    const linkListProxy = await TransparentUpgradeableProxy.connect(admin).deploy(
        linklistImpl.address,
        adminAddress,
        []
    );

    await mintNFT.deployed();
    await linkListProxy.deployed();
    await web3EntryProxy.deployed();

    await linklistImpl.initialize(LINK_LIST_NFT_NAME, LINK_LIST_NFT_SYMBOL, web3EntryImpl.address);
    await web3EntryImpl.initialize(
        WEB3_ENTRY_NFT_NAME,
        WEB3_ENTRY_NFT_SYMBOL,
        linklistImpl.address,
        ethers.constants.AddressZero
    );
    eventsLib = await new Events__factory(deployer).deploy();

    web3Entry = Web3Entry__factory.connect(web3EntryProxy.address, user);
    linkList = Linklist__factory.connect(linkListProxy.address, user);
});
