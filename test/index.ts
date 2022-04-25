import { expect } from "chai";
import { ethers } from "hardhat";
import {
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID,
    SECOND_PROFILE_ID,
    MOCK_PROFILE_HANDLE,
    MOCK_PROFILE_URI,
    user,
    deployerAddress,
    userAddress,
    userTwoAddress,
    userThreeAddress,
    web3Entry,
} from "./setup";
import { getTimestamp, matchEvent } from "./utils";

describe("Profile", function () {
    it("Should returns an revision", async function () {
        const revision = await web3Entry.getRevision();
        expect(revision).to.equal(1);
    });

    it("Should emit the new created profile data once it's created", async function () {
        const profileData = {
            to: userAddress,
            handle: MOCK_PROFILE_HANDLE,
            uri: MOCK_PROFILE_URI,
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
        };

        const receipt = await (await web3Entry.createProfile(profileData)).wait();

        matchEvent(receipt, "ProfileCreated", [
            FIRST_PROFILE_ID,
            userAddress,
            profileData.to,
            profileData.handle,
            await getTimestamp(),
        ]);

        const profile = await web3Entry.getProfileByHandle(profileData.handle);
        expect(profile.handle).to.equal(profileData.handle);
        expect(profile.uri).to.equal(profileData.uri);
    });

    it("Should fail when creating profile with existing handle", async function () {
        const profileData = {
            to: userAddress,
            handle: MOCK_PROFILE_HANDLE,
            uri: MOCK_PROFILE_URI,
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
        };

        await expect(web3Entry.createProfile(profileData)).to.not.be.reverted;
        // await expect(web3Entry.createProfile(profileData)).to.not.be.reverted;
        await expect(web3Entry.createProfile(profileData)).to.be.revertedWith("HandleExists");
    });

    it("Created profile with address as handle", async function () {
        const handle = userAddress.toLowerCase();
        const profileData = {
            to: userAddress,
            handle: handle,
            uri: MOCK_PROFILE_URI,
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
        };

        const receipt = await (await web3Entry.createProfile(profileData)).wait();

        matchEvent(receipt, "ProfileCreated", [
            FIRST_PROFILE_ID,
            userAddress,
            profileData.to,
            profileData.handle,
            await getTimestamp(),
        ]);

        const profile = await web3Entry.getProfileByHandle(handle);
        expect(profile.handle).to.equal(profileData.handle);
        expect(profile.uri).to.equal(profileData.uri);
    });

    it("Should emit the follow data once it's linked or unlinked", async function () {
        const profileData = (handle?: string) => {
            return {
                to: userAddress,
                handle: handle ? handle : MOCK_PROFILE_HANDLE,
                uri: MOCK_PROFILE_URI,
                linkModule: ethers.constants.AddressZero,
                linkModuleInitData: [],
            };
        };

        await web3Entry.createProfile(profileData("handle1"));
        await web3Entry.createProfile(profileData("handle2"));

        const followLinkType = ethers.utils.formatBytes32String("follow");

        let receipt = await (
            await web3Entry
                .connect(user)
                .linkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, followLinkType)
        ).wait();
        matchEvent(receipt, "LinkProfile", [
            userAddress,
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
                .connect(user)
                .unlinkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, followLinkType)
        ).wait();

        matchEvent(receipt, "UnlinkProfile", [
            userAddress,
            FIRST_PROFILE_ID,
            SECOND_PROFILE_ID,
            followLinkType,
        ]);

        followings = await web3Entry.getLinkingProfileIds(FIRST_PROFILE_ID, followLinkType);
        expect(followings.length).to.be.eq(0);
    });

    it("Should create and link the profile of an address", async function () {
        const profileData = (handle?: string) => {
            return {
                to: userAddress,
                handle: handle ? handle : MOCK_PROFILE_HANDLE,
                uri: MOCK_PROFILE_URI,
                linkModule: ethers.constants.AddressZero,
                linkModuleInitData: [],
            };
        };

        const followLinkType = ethers.utils.formatBytes32String("follow");

        await web3Entry.createProfile(profileData("handle1"));

        const receipt = await (
            await web3Entry
                .connect(user)
                .createThenLinkProfile(FIRST_PROFILE_ID, userTwoAddress, followLinkType)
        ).wait();

        matchEvent(receipt, "ProfileCreated");
        matchEvent(receipt, "LinkProfile");

        const followings = await web3Entry.getLinkingProfileIds(FIRST_PROFILE_ID, followLinkType);
        expect(followings.length).to.be.eq(1);
        expect(followings[0]).to.be.eq(SECOND_PROFILE_ID);

        // get profile
        let profile = await web3Entry.getProfile(FIRST_PROFILE_ID);
        expect(profile.profileId).to.equal(FIRST_PROFILE_ID);
        expect(profile.handle).to.equal("handle1");

        profile = await web3Entry.getProfile(SECOND_PROFILE_ID);
        expect(profile.profileId).to.equal(SECOND_PROFILE_ID);
        expect(profile.handle).to.equal(userTwoAddress.toLowerCase());

        // get handle
        const handle = await web3Entry.getHandle(SECOND_PROFILE_ID);
        expect(handle).to.equal(userTwoAddress.toLowerCase());
        // get profile by handle
        profile = await web3Entry.getProfileByHandle(userTwoAddress.toLowerCase());
        expect(profile.handle).to.equal(userTwoAddress.toLowerCase());
        expect(profile.profileId).to.equal(SECOND_PROFILE_ID);

        // check profile nft totalSupply
        const totalSupply = await web3Entry.totalSupply();
        expect(totalSupply).to.equal(2);

        // createThenLinkProfile will fail if the profile has been created
        expect(
            web3Entry
                .connect(user)
                .createThenLinkProfile(FIRST_PROFILE_ID, userTwoAddress, followLinkType)
        ).to.be.revertedWith("Target address already has primary profile.");
    });
});
