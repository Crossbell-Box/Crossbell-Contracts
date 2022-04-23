import { expect } from "chai";
import { ethers } from "hardhat";
import { FIRST_LINKLIST_ID, FIRST_PROFILE_ID, SECOND_PROFILE_ID, web3Entry } from "./setup";
import { getTimestamp, matchEvent } from "./utils";
describe("Profile", function () {
    it("Should returns an revision", async function () {
        const revision = await web3Entry.getRevision();
        expect(revision).to.equal(1);
    });

    it("Should emit the new created profile data once it's created", async function () {
        const [deployer, addr1] = await ethers.getSigners();
        const profileData = {
            to: await addr1.address,
            handle: "new.handle",
            uri: "uri",
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
        };

        const receipt = await (await web3Entry.createProfile(profileData)).wait();

        matchEvent(receipt, "ProfileCreated", [
            FIRST_PROFILE_ID,
            deployer.address,
            profileData.to,
            profileData.handle,
            await getTimestamp(),
        ]);

        const profile = await web3Entry.getProfileByHandle("new.handle");

        expect(profile.handle).to.equal(profileData.handle);
        expect(profile.uri).to.equal(profileData.uri);
    });

    it("Should fail when creating profile with existing handle", async function () {
        const [deployer, addr1] = await ethers.getSigners();

        const profileData = {
            to: await addr1.address,
            handle: "new.handle",
            uri: "uri",
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
        };

        await expect(web3Entry.createProfile(profileData)).to.not.be.reverted;
        // await expect(web3Entry.createProfile(profileData)).to.not.be.reverted;
        await expect(web3Entry.createProfile(profileData)).to.be.revertedWith("HandleExists");
    });

    it("Created profile with address as handle", async function () {
        const [deployer, addr1, addr2] = await ethers.getSigners();
        const handle = addr2.address.toString().toLowerCase();
        console.log("handle:", handle);
        const profileData = {
            to: await addr1.address,
            handle: handle,
            uri: "uri",
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
        };

        const receipt = await (await web3Entry.createProfile(profileData)).wait();

        matchEvent(receipt, "ProfileCreated", [
            FIRST_PROFILE_ID,
            deployer.address,
            profileData.to,
            profileData.handle,
            await getTimestamp(),
        ]);

        const profile = await web3Entry.getProfileByHandle(handle);
        expect(profile.handle).to.equal(profileData.handle);
        expect(profile.uri).to.equal(profileData.uri);
    });

    it("Should emit the follow data once it's linked or unlinked", async function () {
        const [deployer, addr1] = await ethers.getSigners();
        const profileData = (handle?: string) => {
            return {
                to: addr1.address,
                handle: handle ? handle : "new.handle",
                uri: "uri",
                linkModule: ethers.constants.AddressZero,
                linkModuleInitData: [],
            };
        };

        await web3Entry.createProfile(profileData("handle1"));
        await web3Entry.createProfile(profileData("handle2"));

        const followLinkType = ethers.utils.formatBytes32String("follow");

        let receipt = await (
            await web3Entry
                .connect(addr1)
                .linkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, followLinkType)
        ).wait();
        matchEvent(receipt, "LinkProfile", [
            addr1.address,
            FIRST_PROFILE_ID,
            SECOND_PROFILE_ID,
            followLinkType,
            FIRST_LINKLIST_ID,
        ]);

        let followings = await web3Entry.getLinkingProfileIds(FIRST_PROFILE_ID, followLinkType);
        expect(followings.length).to.be.eq(1);
        expect(followings[0]).to.be.eq(SECOND_PROFILE_ID);

        // unlink
        receipt = await (
            await web3Entry
                .connect(addr1)
                .unlinkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, followLinkType)
        ).wait();

        matchEvent(receipt, "UnlinkProfile", [
            addr1.address,
            FIRST_PROFILE_ID,
            SECOND_PROFILE_ID,
            followLinkType,
        ]);

        followings = await web3Entry.getLinkingProfileIds(FIRST_PROFILE_ID, followLinkType);
        expect(followings.length).to.be.eq(0);
    });

    it("Should create and link the profile of an address", async function () {
        const [deployer, addr1, addr2] = await ethers.getSigners();
        const profileData = (handle?: string) => {
            return {
                to: addr1.address,
                handle: handle ? handle : "new.handle",
                uri: "uri",
                linkModule: ethers.constants.AddressZero,
                linkModuleInitData: [],
            };
        };

        const followLinkType = ethers.utils.formatBytes32String("follow");

        await web3Entry.createProfile(profileData("handle1"));

        let receipt = await (
            await web3Entry
                .connect(addr1)
                .createThenLinkProfile(FIRST_PROFILE_ID, addr2.address, followLinkType)
        ).wait();

        matchEvent(receipt, "ProfileCreated");
        matchEvent(receipt, "LinkProfile");

        let followings = await web3Entry.getLinkingProfileIds(FIRST_PROFILE_ID, followLinkType);
        expect(followings.length).to.be.eq(1);
        expect(followings[0]).to.be.eq(SECOND_PROFILE_ID);

        // get profile
        let profile = await web3Entry.getProfile(FIRST_PROFILE_ID);
        expect(profile.profileId).to.equal(FIRST_PROFILE_ID);
        expect(profile.handle).to.equal("handle1");

        profile = await web3Entry.getProfile(SECOND_PROFILE_ID);
        expect(profile.profileId).to.equal(SECOND_PROFILE_ID);
        expect(profile.handle).to.equal(addr2.address.toLowerCase());

        // get handle
        const handle = await web3Entry.getHandle(SECOND_PROFILE_ID);
        expect(handle).to.equal(addr2.address.toLowerCase());
        // get profile by handle
        profile = await web3Entry.getProfileByHandle(addr2.address.toLowerCase());
        expect(profile.handle).to.equal(addr2.address.toLowerCase());
        expect(profile.profileId).to.equal(SECOND_PROFILE_ID);

        // check profile nft totalSupply
        const totalSupply = await web3Entry.totalSupply();
        expect(totalSupply).to.equal(2);

        // createThenLinkProfile will fail if the profile has been created
        expect(
            web3Entry
                .connect(addr1)
                .createThenLinkProfile(FIRST_PROFILE_ID, addr2.address, followLinkType)
        ).to.be.revertedWith("Target address already has primary profile.");
    });
});
