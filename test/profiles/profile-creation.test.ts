import { expect } from "chai";
import { ethers } from "hardhat";
import {
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID,
    makeSuiteCleanRoom,
    MOCK_PROFILE_HANDLE,
    MOCK_PROFILE_URI,
    SECOND_PROFILE_ID,
    userAddress,
    userTwo,
    userTwoAddress,
    web3Entry,
} from "../setup.test";
import { getTimestamp, makeProfileData, matchEvent } from "../helpers/utils";
import { ERRORS } from "../helpers/errors";
import { CreateProfileData, ProfileData } from "../helpers/types";
import { BigNumber } from "ethers";

makeSuiteCleanRoom("Profile Creation", function () {
    context("Generic", function () {
        context("Negatives", function () {
            it("User should fail to create profile with handle length > 31", async function () {
                const handle = "da2423cea4f1047556e7a142f81a7eda";
                expect(handle.length).to.gt(31);
                await expect(web3Entry.createProfile(makeProfileData(handle))).to.be.revertedWith(
                    "HandleLengthInvalid"
                );
            });

            it("User should fail to create profile with empty handle", async function () {
                await expect(
                    web3Entry.createProfile({
                        to: userAddress,
                        handle: "",
                        uri: MOCK_PROFILE_URI,
                        linkModule: ethers.constants.AddressZero,
                        linkModuleInitData: [],
                    })
                ).to.be.revertedWith("HandleLengthInvalid");
            });

            it("User should fail to create profile with invalid handle", async function () {
                const arr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()+|[]:",'.split("");
                for (const c of arr) {
                    await expect(
                        web3Entry.createProfile({
                            to: userAddress,
                            handle: c,
                            uri: MOCK_PROFILE_URI,
                            linkModule: ethers.constants.AddressZero,
                            linkModuleInitData: [],
                        })
                    ).to.be.revertedWith("HandleContainsInvalidCharacters");
                }
            });
        });

        context("Scenarios", function () {
            it("User should create profile with handle length == 31", async function () {
                await expect(
                    web3Entry.createProfile(makeProfileData("_ab2423cea4f1047556e7a14-f1.eth"))
                ).to.not.be.revertedWith("HandleLengthInvalid");
            });
            it(`User should be able to create a profile with a handle, uri,
                receive an NFT, and the handle should resolve to the NFT ID,
                and userTwo should do the same.`, async function () {
                let profileData: CreateProfileData;
                let owner: string;
                let totalSupply: BigNumber;
                let profile: ProfileData;

                profileData = makeProfileData();
                await expect(web3Entry.createProfile(profileData)).to.not.be.reverted;

                owner = await web3Entry.ownerOf(FIRST_PROFILE_ID);
                totalSupply = await web3Entry.totalSupply();
                profile = await web3Entry.getProfileByHandle(MOCK_PROFILE_HANDLE);

                expect(owner).to.eq(userAddress);
                expect(totalSupply).to.eq(FIRST_PROFILE_ID);
                expect(profile.profileId).to.equal(FIRST_PROFILE_ID);
                expect(profile.handle).to.equal(MOCK_PROFILE_HANDLE);
                expect(profile.uri).to.equal(MOCK_PROFILE_URI);

                const testHandle = "handle.2";
                profileData = makeProfileData(testHandle, userTwoAddress);
                await expect(
                    web3Entry.connect(userTwo).createProfile(profileData)
                ).to.not.be.reverted;

                owner = await web3Entry.ownerOf(SECOND_PROFILE_ID);
                totalSupply = await web3Entry.totalSupply();
                profile = await web3Entry.getProfileByHandle(testHandle);

                expect(owner).to.eq(userTwoAddress);
                expect(totalSupply).to.eq(SECOND_PROFILE_ID);
                expect(profile.profileId).to.equal(SECOND_PROFILE_ID);
                expect(profile.handle).to.equal(testHandle);
                expect(profile.uri).to.equal(MOCK_PROFILE_URI);
            });

            it("User should create a profile for userTwo", async function () {
                await expect(
                    web3Entry.createProfile(makeProfileData(MOCK_PROFILE_HANDLE, userTwoAddress))
                ).to.not.be.reverted;
                expect(await web3Entry.ownerOf(FIRST_PROFILE_ID)).to.eq(userTwoAddress);
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
