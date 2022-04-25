import { expect } from "chai";
import { ethers } from "hardhat";
import {
    deployerAddress,
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID,
    makeSuiteCleanRoom,
    MOCK_PROFILE_HANDLE,
    MOCK_PROFILE_URI,
    SECOND_PROFILE_ID,
    user,
    userAddress,
    userTwo,
    userTwoAddress,
    web3Entry,
} from "../setup.test";
import { makeProfileData, matchEvent } from "../helpers/utils";
import { ERRORS } from "../helpers/errors";

makeSuiteCleanRoom("Primary Profile", function () {
    context("Generic", function () {
        beforeEach(async function () {
            const profileData = makeProfileData();
            await expect(web3Entry.createProfile(profileData)).to.not.be.reverted;
        });

        context("Negatives", function () {
            it("UserTwo should fail to set the primary profile as a profile owned by user 1", async function () {
                await expect(
                    web3Entry.connect(userTwo).setPrimaryProfileId(FIRST_PROFILE_ID)
                ).to.be.revertedWith(ERRORS.NOT_PROFILE_OWNER);
            });
        });

        context("Scenarios", function () {
            it("User's first profile should be the primary profile", async function () {
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(FIRST_PROFILE_ID);
            });

            it("User should set the primary profile", async function () {
                await expect(
                    web3Entry.connect(user).setPrimaryProfileId(FIRST_PROFILE_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(FIRST_PROFILE_ID);
            });

            it("User should set new primary profile", async function () {
                // create new profile
                const newHandle = "handle.2";
                await expect(
                    web3Entry.createProfile(makeProfileData(newHandle))
                ).to.not.be.reverted;

                // set new primary profile
                await expect(
                    web3Entry.connect(user).setPrimaryProfileId(SECOND_PROFILE_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(SECOND_PROFILE_ID);
            });

            it("User should transfer the primary profile, and then their primary profile should be unset", async function () {
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(FIRST_PROFILE_ID);

                await expect(
                    web3Entry
                        .connect(user)
                        .transferFrom(userAddress, userTwoAddress, FIRST_PROFILE_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(0);
            });

            it("User without a profile, and then receives a profile, it should be unset", async function () {
                await expect(
                    web3Entry
                        .connect(user)
                        .transferFrom(userAddress, userTwoAddress, FIRST_PROFILE_ID)
                ).to.not.be.reverted;
                // user's primary profile should be unset
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(0);
                // userTwo's primary profile should be unset
                expect(await web3Entry.getPrimaryProfileId(userTwoAddress)).to.eq(0);

                // userTwo set primary profile
                await expect(
                    web3Entry.connect(userTwo).setPrimaryProfileId(FIRST_PROFILE_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getPrimaryProfileId(userTwoAddress)).to.eq(FIRST_PROFILE_ID);
            });
        });
    });
});

// describe("Profile Interactions", function () {
//     it("Should emit the follow data once it's linked or unlinked", async function () {
//         await web3EntryImpl.createProfile(makeProfileData("handle1"));
//         await web3EntryImpl.createProfile(makeProfileData("handle2"));

//         const followLinkType = ethers.utils.formatBytes32String("follow");

//         await web3EntryImpl.linkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, followLinkType);

//         let followings = await web3EntryImpl.getLinkingProfileIds(FIRST_PROFILE_ID, followLinkType);
//         expect(followings.length).to.be.eq(1);
//         expect(followings[0]).to.be.eq(SECOND_PROFILE_ID);

//         // unlink
//         receipt = await (
//             await web3EntryImpl
//                 .connect(addr1)
//                 .unlinkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, followLinkType)
//         ).wait();

//         matchEvent(receipt, "UnlinkProfile", [
//             addr1.address,
//             FIRST_PROFILE_ID,
//             SECOND_PROFILE_ID,
//             followLinkType,
//         ]);

//         followings = await web3EntryImpl.getLinkingProfileIds(FIRST_PROFILE_ID, followLinkType);
//         expect(followings.length).to.be.eq(0);
//     });

//     it("Should create and link the profile of an address", async function () {
//         const [deployer, addr1, addr2] = await ethers.getSigners();
//         const profileData = (handle?: string) => {
//             return {
//                 to: addr1.address,
//                 handle: handle ? handle : "newHandle",
//                 uri: "uri",
//                 linkModule: ethers.constants.AddressZero,
//                 linkModuleInitData: [],
//             };
//         };

//         const followLinkType = ethers.utils.formatBytes32String("follow");

//         await web3EntryImpl.createProfile(profileData("handle1"));

//         let receipt = await (
//             await web3EntryImpl
//                 .connect(addr1)
//                 .createThenLinkProfile(FIRST_PROFILE_ID, addr2.address, followLinkType)
//         ).wait();

//         matchEvent(receipt, "ProfileCreated");
//         matchEvent(receipt, "LinkProfile");

//         let followings = await web3EntryImpl.getLinkingProfileIds(FIRST_PROFILE_ID, followLinkType);
//         expect(followings.length).to.be.eq(1);
//         expect(followings[0]).to.be.eq(SECOND_PROFILE_ID);

//         // get profile
//         let profile = await web3EntryImpl.getProfile(FIRST_PROFILE_ID);
//         expect(profile.profileId).to.equal(FIRST_PROFILE_ID);
//         expect(profile.handle).to.equal("handle1");

//         profile = await web3EntryImpl.getProfile(SECOND_PROFILE_ID);
//         expect(profile.profileId).to.equal(SECOND_PROFILE_ID);
//         expect(profile.handle).to.equal(addr2.address.toLowerCase());

//         // get handle
//         const handle = await web3EntryImpl.getHandle(SECOND_PROFILE_ID);
//         expect(handle).to.equal(addr2.address.toLowerCase());

//         // check profile nft totalSupply
//         const totalSupply = await web3EntryImpl.totalSupply();
//         expect(totalSupply).to.equal(2);

//         // createThenLinkProfile will fail if the profile has been created
//         expect(
//             web3EntryImpl
//                 .connect(addr1)
//                 .createThenLinkProfile(FIRST_PROFILE_ID, addr2.address, followLinkType)
//         ).to.be.revertedWith("Target address already has primary profile.");
//     });
// });
