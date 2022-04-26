import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { ERRORS } from "../helpers/errors";
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
    userAddress,
    userTwoAddress,
    userThreeAddress,
    web3Entry,
    MOCK_PROFILE_HANDLE2,
    MOCK_URI,
    // eslint-disable-next-line node/no-missing-import
} from "../setup.test";
import { makeProfileData } from "../helpers/utils";

makeSuiteCleanRoom("Profile URI Functionality", function () {
    context("Generic", function () {
        beforeEach(async function () {
            const profileData = makeProfileData();
            await expect(web3Entry.createProfile(profileData)).to.not.be.reverted;
        });

        context("Scenarios for Profile", function () {
            it("UserTwo should fail to set profile uri as a profile owned by user 1", async function () {
                await expect(
                    web3Entry.connect(userTwo).setProfileUri(FIRST_PROFILE_ID, MOCK_URI)
                ).to.be.revertedWith(ERRORS.NOT_PROFILE_OWNER);
            });

            it("User should set new profile uri", async function () {
                // set profile uri
                await expect(
                    web3Entry.connect(user).setProfileUri(FIRST_PROFILE_ID, MOCK_URI)
                ).to.not.be.reverted;

                expect(await web3Entry.getProfileUri(FIRST_PROFILE_ID)).to.eq(MOCK_URI);
            });

            it("Should return the correct tokenURI after transfer", async function () {
                await expect(
                    web3Entry
                        .connect(user)
                        .transferFrom(userAddress, userTwoAddress, FIRST_PROFILE_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getProfileUri(FIRST_PROFILE_ID)).to.eq(MOCK_PROFILE_URI);
                expect(await web3Entry.tokenURI(FIRST_PROFILE_ID)).to.eq(MOCK_PROFILE_URI);
            });
        });
    });
});
