import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { ERRORS } from "./helpers/errors";
import {
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID,
    SECOND_PROFILE_ID,
    MOCK_PROFILE_HANDLE,
    MOCK_PROFILE_URI,
    makeSuiteCleanRoom,
    deployer,
    user,
    userTwo,
    deployerAddress,
    userAddress,
    userTwoAddress,
    userThreeAddress,
    web3Entry,
    MOCK_PROFILE_HANDLE2,
    // eslint-disable-next-line node/no-missing-import
} from "./setup";
import { getTimestamp, matchEvent } from "./utils";

makeSuiteCleanRoom("Default profile Functionality", function () {
    context("Generic", function () {
        beforeEach(async function () {
            await expect(
                web3Entry.createProfile({
                    to: userAddress,
                    handle: MOCK_PROFILE_HANDLE,
                    uri: MOCK_PROFILE_URI,
                    linkModule: ethers.constants.AddressZero,
                    linkModuleInitData: [],
                })
            ).to.not.be.reverted;
        });

        context("Negatives", function () {
            it("UserTwo should fail to set the primary profile as a profile owned by user 1", async function () {
                await expect(
                    web3Entry.connect(userTwo).setPrimaryProfileId(FIRST_PROFILE_ID)
                ).to.be.revertedWith(ERRORS.NOT_PROFILE_OWNER);
            });
        });

        context("Scenarios for Profile", function () {
            it("User's first profile should be the primary profile", async function () {
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(FIRST_PROFILE_ID);
            });

            it("User should set the primary profile", async function () {
                await expect(web3Entry.setPrimaryProfileId(FIRST_PROFILE_ID)).to.not.be.reverted;
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(FIRST_PROFILE_ID);
            });

            it("User should set new primary profile", async function () {
                // create new profile
                await expect(
                    web3Entry.createProfile({
                        to: userAddress,
                        handle: MOCK_PROFILE_HANDLE2,
                        uri: MOCK_PROFILE_URI,
                        linkModule: ethers.constants.AddressZero,
                        linkModuleInitData: [],
                    })
                ).to.not.be.reverted;

                // set new primary profile
                await expect(web3Entry.setPrimaryProfileId(SECOND_PROFILE_ID)).to.not.be.reverted;
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(SECOND_PROFILE_ID);
            });

            it("User should transfer the primary profile, and then their primary profile should be unset", async function () {
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(FIRST_PROFILE_ID);

                await expect(
                    web3Entry.transferFrom(userAddress, userTwoAddress, FIRST_PROFILE_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getPrimaryProfileId(userAddress)).to.eq(0);
            });

            it("User without a profile, and then receives a profile, it should be unset", async function () {
                await expect(
                    web3Entry.transferFrom(userAddress, userTwoAddress, FIRST_PROFILE_ID)
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

        context("Profile handle test", function () {
            it("User should fail to create profile with handle length > 31", async function () {
                const handle = "da2423cea4f1047556e7a142f81a7eda";
                await expect(
                    web3Entry.createProfile({
                        to: userAddress,
                        handle: handle,
                        uri: MOCK_PROFILE_URI,
                        linkModule: ethers.constants.AddressZero,
                        linkModuleInitData: [],
                    })
                ).to.be.revertedWith("HandleLengthInvalid");
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

            it("User should create profile with handle length == 31", async function () {
                await expect(
                    web3Entry.createProfile({
                        to: userAddress,
                        handle: "_ab2423cea4f1047556e7a14-f1.eth",
                        uri: MOCK_PROFILE_URI,
                        linkModule: ethers.constants.AddressZero,
                        linkModuleInitData: [],
                    })
                ).to.not.be.revertedWith("HandleLengthInvalid");
            });
        });
    });
});
