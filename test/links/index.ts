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
    makeSuiteCleanRoom,
} from "../setup.test";
import { getTimestamp, makeProfileData, matchEvent } from "../helpers/utils";
import { FOLLOW_LINKTYPE, userTwo } from "../setup.test";
import { ERRORS } from "../helpers/errors";

makeSuiteCleanRoom("Link", function () {
    context("Generic", function () {
        beforeEach(async function () {
            await web3Entry.createProfile(makeProfileData("handle1"));
            await web3Entry.createProfile(makeProfileData("handle2"));
            await expect(
                web3Entry.linkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, FOLLOW_LINKTYPE)
            ).to.not.be.reverted;
        });
        context("Negatives", function () {
            it("User should fail to link an non-existed profile", async function () {
                await expect(
                    web3Entry
                        .connect(userTwo)
                        .linkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID + 1, FOLLOW_LINKTYPE)
                ).to.be.revertedWith(ERRORS.NOT_PROFILE_OWNER);
            });
            it("UserTwo should fail to emit a link from a profile not owned by him", async function () {
                await expect(
                    web3Entry
                        .connect(userTwo)
                        .linkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, FOLLOW_LINKTYPE)
                ).to.be.revertedWith(ERRORS.PROFILE_NOT_EXISTED);
            });
        });
        // it("Should emit the follow data once it's linked or unlinked", async function () {
        //     let followings = await web3Entry.getLinkingProfileIds(
        //         FIRST_PROFILE_ID,
        //         FOLLOW_LINKTYPE
        //     );
        //     expect(followings.length).to.be.eq(1);
        //     expect(followings[0]).to.be.eq(SECOND_PROFILE_ID);

        //     // unlink
        //     receipt = await (
        //         await web3Entry
        //             .connect(user)
        //             .unlinkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, followLinkType)
        //     ).wait();

        //     matchEvent(receipt, "UnlinkProfile", [
        //         userAddress,
        //         FIRST_PROFILE_ID,
        //         SECOND_PROFILE_ID,
        //         followLinkType,
        //     ]);

        //     followings = await web3Entry.getLinkingProfileIds(FIRST_PROFILE_ID, followLinkType);
        //     expect(followings.length).to.be.eq(0);
        // });

        // it("Should create and link the profile of an address", async function () {
        //     const profileData = (handle?: string) => {
        //         return {
        //             to: userAddress,
        //             handle: handle ? handle : MOCK_PROFILE_HANDLE,
        //             uri: MOCK_PROFILE_URI,
        //             linkModule: ethers.constants.AddressZero,
        //             linkModuleInitData: [],
        //         };
        //     };

        //     const followLinkType = ethers.utils.formatBytes32String("follow");

        //     await web3Entry.createProfile(profileData("handle1"));

        //     const receipt = await (
        //         await web3Entry
        //             .connect(user)
        //             .createThenLinkProfile(FIRST_PROFILE_ID, userTwoAddress, followLinkType)
        //     ).wait();

        //     matchEvent(receipt, "ProfileCreated");
        //     matchEvent(receipt, "LinkProfile");

        //     const followings = await web3Entry.getLinkingProfileIds(
        //         FIRST_PROFILE_ID,
        //         followLinkType
        //     );
        //     expect(followings.length).to.be.eq(1);
        //     expect(followings[0]).to.be.eq(SECOND_PROFILE_ID);

        //     // get profile
        //     let profile = await web3Entry.getProfile(FIRST_PROFILE_ID);
        //     expect(profile.profileId).to.equal(FIRST_PROFILE_ID);
        //     expect(profile.handle).to.equal("handle1");

        //     profile = await web3Entry.getProfile(SECOND_PROFILE_ID);
        //     expect(profile.profileId).to.equal(SECOND_PROFILE_ID);
        //     expect(profile.handle).to.equal(userTwoAddress.toLowerCase());

        //     // get handle
        //     const handle = await web3Entry.getHandle(SECOND_PROFILE_ID);
        //     expect(handle).to.equal(userTwoAddress.toLowerCase());
        //     // get profile by handle
        //     profile = await web3Entry.getProfileByHandle(userTwoAddress.toLowerCase());
        //     expect(profile.handle).to.equal(userTwoAddress.toLowerCase());
        //     expect(profile.profileId).to.equal(SECOND_PROFILE_ID);

        //     // check profile nft totalSupply
        //     const totalSupply = await web3Entry.totalSupply();
        //     expect(totalSupply).to.equal(2);

        //     // createThenLinkProfile will fail if the profile has been created
        //     expect(
        //         web3Entry
        //             .connect(user)
        //             .createThenLinkProfile(FIRST_PROFILE_ID, userTwoAddress, followLinkType)
        //     ).to.be.revertedWith("Target address already has primary profile.");
        // });
    });
});
