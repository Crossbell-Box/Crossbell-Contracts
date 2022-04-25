import { expect } from "chai";
import { ethers } from "hardhat";
import { ERRORS } from "./helpers/errors";
import {
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID,
    SECOND_PROFILE_ID,
    MOCK_PROFILE_HANDLE,
    MOCK_PROFILE_URI,
    makeSuiteCleanRoom,
    user,
    userTwo,
    deployerAddress,
    userAddress,
    userTwoAddress,
    userThreeAddress,
    web3Entry,
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

        context("Scenarios", function () {});
    });
});
