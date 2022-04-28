import { expect } from "chai";
import { ethers } from "hardhat";
import {
    deployerAddress,
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID,
    makeSuiteCleanRoom,
    MOCK_PROFILE_HANDLE,
    MOCK_PROFILE_HANDLE2,
    MOCK_PROFILE_URI,
    SECOND_PROFILE_ID,
    user,
    userAddress,
    userTwo,
    userTwoAddress,
    web3Entry,
    // eslint-disable-next-line node/no-missing-import
} from "../setup.test";
// eslint-disable-next-line node/no-missing-import
import { makeProfileData, matchEvent } from "../helpers/utils";
// eslint-disable-next-line node/no-missing-import
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

            it("UserTwo should fail to set handle as a profile owned by user 1", async function () {
                await expect(
                    web3Entry.connect(userTwo).setHandle(FIRST_PROFILE_ID, MOCK_PROFILE_HANDLE2)
                ).to.be.revertedWith(ERRORS.NOT_PROFILE_OWNER);
            });
        });
    });
});
