import { expect } from "chai";
import {
    FIRST_PROFILE_ID,
    SECOND_PROFILE_ID,
    userTwoAddress,
    web3Entry,
    makeSuiteCleanRoom,
    MOCK_PROFILE_URI,
    approvalLinkModule4Profile,
    abiCoder,
    userThreeAddress,
} from "../setup.test";
import { makeProfileData } from "../helpers/utils";
import { FOLLOW_LINKTYPE } from "../setup.test";

makeSuiteCleanRoom("Link Module", function () {
    context("Generic", function () {
        beforeEach(async function () {
            await web3Entry.createProfile(makeProfileData("handle1"));
        });
        context("Negatives", function () {
            it("User not in approval list should not fail to link a profile", async function () {
                await web3Entry.createProfile({
                    to: userTwoAddress,
                    handle: "handle2",
                    uri: MOCK_PROFILE_URI,
                    linkModule: approvalLinkModule4Profile.address,
                    linkModuleInitData: abiCoder.encode(["address[]"], [[userThreeAddress]]),
                });

                await expect(
                    web3Entry.linkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.be.not.reverted;
            });
        });
    });
});
