import { ethers } from "hardhat";
import { Signer } from "ethers";
// eslint-disable-next-line camelcase,node/no-missing-import
import {
    Events__factory,
    Events,
    Linklist,
    Web3Entry,
    Web3Entry__factory,
    TransparentUpgradeableProxy__factory,
    Linklist__factory
} from "../typechain";

import {
    revertToSnapshot,
    takeSnapshot,
    // eslint-disable-next-line node/no-missing-import
} from "./utils";

export const FIRST_PROFILE_ID = 1;
export const SECOND_PROFILE_ID = 2;
export const FIRST_LINKLIST_ID = 1;
export const FIRST_NOTE_ID = 1;
export const WEB3_ENTRY_NFT_NAME = "Web3 Entry Profile";
export const WEB3_ENTRY_NFT_SYMBOL = "WEP";
export const LINK_LIST_NFT_NAME = "Link List Token";
export const LINK_LIST_NFT_SYMBOL = "LLT";
export const MOCK_PROFILE_HANDLE = "0xcrossbell.eth";
export const MOCK_PROFILE_URI = "ipfs://QmaUqFHcfAjQyr9Eg7XSbeVtJKGv3yf7Ao8Eqp6ScpmxwW";
export const MOCK_CONTENT_URI = "ipfs://QmfHKajYAGcaWaBXGsEWory9ensGsesN2GwWedVEuzk5Gg";
export const bytes32Zero = "0x0000000000000000000000000000000000000000000000000000000000000000";

export let eventsLib: Events;
export let linkList: Linklist;
export let linkListImpl: Linklist;
export let web3Entry: Web3Entry;
export let web3EntryImpl: Web3Entry

export let accounts: Signer[];
export let deployer: Signer;
export let user: Signer;
export let userTwo: Signer;
export let userThree: Signer;
export let admin: Signer;
export let deployerAddress: string;
export let userAddress: string;
export let userTwoAddress: string;
export let userThreeAddress: string;
export let adminAddress: string;

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
    accounts = await ethers.getSigners();
    deployer = accounts[0];
    user = accounts[1];
    userTwo = accounts[2];
    userThree = accounts[3];
    admin = accounts[4];

    deployerAddress = await deployer.getAddress();
    userAddress = await user.getAddress();
    userTwoAddress = await userTwo.getAddress();
    userThreeAddress = await userThree.getAddress();
    adminAddress = await admin.getAddress();

    const InteractionLogic = await ethers.getContractFactory("InteractionLogic");
    const interactionLogic = await InteractionLogic.deploy();

    const ProfileLogic = await ethers.getContractFactory("ProfileLogic");
    const profileLogic = await ProfileLogic.deploy();

    const PostLogic = await ethers.getContractFactory("PostLogic");
    const postLogic = await PostLogic.deploy();

    const MintNFT = await ethers.getContractFactory("MintNFT");
    const mintNFT = await MintNFT.deploy();

    const Linklist = await ethers.getContractFactory("Linklist");
    linkListImpl = await Linklist.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry", {
        libraries: {
            InteractionLogic: interactionLogic.address,
            ProfileLogic: profileLogic.address,
            PostLogic: postLogic.address,
        },
    });
    web3EntryImpl = await Web3Entry.deploy();

    const TransparentUpgradeableProxy = await ethers.getContractFactory("TransparentUpgradeableProxy")
    const web3EntryProxy = await TransparentUpgradeableProxy.deploy(
        web3EntryImpl.address,
        adminAddress,
        []
    );
    const linkListProxy = await TransparentUpgradeableProxy.deploy(
        linkListImpl.address,
        adminAddress,
        []
    );

    await mintNFT.deployed();
    await linkListProxy.deployed();
    await web3EntryProxy.deployed();

    web3Entry = Web3Entry__factory.connect(web3EntryProxy.address, user);
    linkList = Linklist__factory.connect(linkListProxy.address, user);

    await linkList
        .connect(user)
        .initialize(LINK_LIST_NFT_NAME, LINK_LIST_NFT_SYMBOL, web3Entry.address);
    await web3Entry
        .connect(user)
        .initialize(WEB3_ENTRY_NFT_NAME, WEB3_ENTRY_NFT_SYMBOL, linkList.address, mintNFT.address);

    eventsLib = await new Events__factory(deployer).deploy();
});
