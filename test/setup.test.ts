import { AbiCoder } from "@ethersproject/abi";
import { ethers } from "hardhat";
import { Signer } from "ethers";
import { expect } from "chai";

// eslint-disable-next-line node/no-missing-import

// eslint-disable-next-line camelcase,node/no-missing-import
import {
    Events__factory,
    Events,
    Linklist,
    Web3Entry,
    Periphery,
    Resolver,
    Currency,
    FeeMintModule,
    Linklist__factory,
    Web3Entry__factory,
    ApprovalMintModule,
    ApprovalLinkModule4Character,
    // eslint-disable-next-line node/no-missing-import
} from "../typechain";
import { revertToSnapshot, takeSnapshot } from "./helpers/utils";

export const FIRST_CHARACTER_ID = 1;
export const SECOND_CHARACTER_ID = 2;
export const THIRD_CHARACTER_ID = 3;

export const FIRST_LINKLIST_ID = 1;
export const SECOND_LINKLIST_ID = 2;

export const FIRST_NOTE_ID = 1;
export const SECOND_NOTE_ID = 2;

export const WEB3_ENTRY_NFT_NAME = "Web3 Entry Character";
export const WEB3_ENTRY_NFT_SYMBOL = "WEC";
export const LINK_LIST_NFT_NAME = "Link List Token";
export const LINK_LIST_NFT_SYMBOL = "LLT";

export const MOCK_CHARACTER_HANDLE = "0xcrossbell-eth";
export const MOCK_CHARACTER_HANDLE2 = "0xcrossbell-2-eth";
export const MOCK_CHARACTER_URI =
    "https://raw.githubusercontent.com/Crossbell-Box/Crossbell-Contracts/main/examples/sampleProfile.json";
export const MOCK_URI = "ipfs://QmadFPhP7n5rJkACMY6QqhtLtKgX1ixoySmxQNrU4Wo5JW";
export const MOCK_CONTENT_URI = "ipfs://QmfHKajYAGcaWaBXGsEWory9ensGsesN2GwWedVEuzk5Gg";
export const MOCK_NOTE_URI =
    "https://github.com/Crossbell-Box/Crossbell-Contracts/blob/main/examples/sampleContent.json";
export const MOCK_NEW_NOTE_URI =
    "https://github.com/Crossbell-Box/Crossbell-Contracts/blob/main/examples/sampleContent-new.json";
export const bytes32Zero = "0x0000000000000000000000000000000000000000000000000000000000000000";

export const FollowLinkType = ethers.utils.formatBytes32String("follow");
export const LikeLinkType = ethers.utils.formatBytes32String("like");

export const LinkItemTypeProfile =
    "0x50726f66696c6500000000000000000000000000000000000000000000000000";
export const LinkItemTypeAddress =
    "0x4164647265737300000000000000000000000000000000000000000000000000";
export const LinkItemTypeNote =
    "0x4e6f746500000000000000000000000000000000000000000000000000000000";
export const LinkItemTypeERC721 =
    "0x4552433732310000000000000000000000000000000000000000000000000000";
export const LinkItemTypeLinklist =
    "0x4c696e6b6c697374000000000000000000000000000000000000000000000000";
export const LinkItemTypeAnyUri =
    "0x416e795572690000000000000000000000000000000000000000000000000000";

export let eventsLib: Events;
export let linklist: Linklist;
export let web3Entry: Web3Entry;
export let periphery: Periphery;
export let resolver: Resolver;
export let currency: Currency;
export let approvalLinkModule4Character: ApprovalLinkModule4Character;
export let feeMintModule: FeeMintModule;
export let approvalMintModule: ApprovalMintModule;

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

export const FOLLOW_LINKTYPE = ethers.utils.formatBytes32String("follow");
export const ARBITRARY_LINKTYPE = ethers.utils.formatBytes32String("arbitrary");

export let abiCoder: AbiCoder;

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

    abiCoder = ethers.utils.defaultAbiCoder;

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
    const adminAddress = await admin.getAddress();

    const LinkModuleLogic = await ethers.getContractFactory("LinkModuleLogic");
    const linkModuleLogic = await LinkModuleLogic.deploy();

    const CharacterLogic = await ethers.getContractFactory("CharacterLogic");
    const characterLogic = await CharacterLogic.deploy();

    const PostLogic = await ethers.getContractFactory("PostLogic");
    const postLogic = await PostLogic.deploy();

    const LinkLogic = await ethers.getContractFactory("LinkLogic");
    const linkLogic = await LinkLogic.deploy();

    const MintNFT = await ethers.getContractFactory("MintNFT");
    const mintNFT = await MintNFT.deploy();

    const Resolver = await ethers.getContractFactory("Resolver");
    resolver = await Resolver.deploy();

    const Linklist = await ethers.getContractFactory("Linklist");
    linklistImpl = await Linklist.deploy();

    const Web3Entry = await ethers.getContractFactory("Web3Entry", {
        libraries: {
            LinkModuleLogic: linkModuleLogic.address,
            CharacterLogic: characterLogic.address,
            PostLogic: postLogic.address,
            LinkLogic: linkLogic.address,
        },
    });
    web3EntryImpl = await Web3Entry.deploy();

    const Periphery = await ethers.getContractFactory("Periphery");
    periphery = await Periphery.deploy();

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

    web3Entry = Web3Entry__factory.connect(web3EntryProxy.address, user);
    linklist = Linklist__factory.connect(linkListProxy.address, user);

    await linklist.initialize(LINK_LIST_NFT_NAME, LINK_LIST_NFT_SYMBOL, web3Entry.address);
    await web3Entry.initialize(
        WEB3_ENTRY_NFT_NAME,
        WEB3_ENTRY_NFT_SYMBOL,
        linklist.address,
        mintNFT.address,
        periphery.address,
        resolver.address
    );
    await periphery.initialize(web3Entry.address, linklist.address);

    // Currency
    const Currency = await ethers.getContractFactory("Currency");
    currency = await Currency.deploy();

    // Modules
    const ApprovalLinkModule4Character = await ethers.getContractFactory(
        "ApprovalLinkModule4Character"
    );
    approvalLinkModule4Character = await ApprovalLinkModule4Character.deploy(web3Entry.address);

    const FeeMintModule = await ethers.getContractFactory("FeeMintModule");
    feeMintModule = await FeeMintModule.deploy(web3Entry.address);

    const ApprovalMintModule = await ethers.getContractFactory("ApprovalMintModule");
    approvalMintModule = await ApprovalMintModule.deploy(web3Entry.address);

    expect(approvalLinkModule4Character).to.not.be.undefined;
    expect(feeMintModule).to.not.be.undefined;
    expect(approvalMintModule).to.not.be.undefined;
    expect(currency).to.not.be.undefined;
    expect(web3Entry).to.not.be.undefined;
    expect(linklist).to.not.be.undefined;
    expect(periphery).to.not.be.undefined;
    expect(resolver).to.not.be.undefined;

    eventsLib = await new Events__factory(deployer).deploy();
});
