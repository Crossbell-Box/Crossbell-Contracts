import { expect } from "chai";
import {
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID,
    SECOND_PROFILE_ID,
    user,
    userAddress,
    userTwoAddress,
    web3Entry,
    makeSuiteCleanRoom,
    linklist,
    ARBITRARY_LINKTYPE,
    MOCK_PROFILE_URI,
    approvalLinkModule4Profile,
    abiCoder,
    userThreeAddress,
} from "../setup.test";
import { makeProfileData, matchLinkingProfileIds } from "../helpers/utils";
import { FOLLOW_LINKTYPE, userTwo } from "../setup.test";
import { ERRORS } from "../helpers/errors";
import { ethers } from "hardhat";

makeSuiteCleanRoom("Link Module", function () {
    context("Generic", function () {
        beforeEach(async function () {
            await web3Entry.createProfile(makeProfileData("handle1"));
        });
        context("Negatives", function () {
            it("User not in approval list should fail to link a profile", async function () {
                await web3Entry.createProfile({
                    to: userTwoAddress,
                    handle: "handle2",
                    uri: MOCK_PROFILE_URI,
                    linkModule: approvalLinkModule4Profile.address,
                    linkModuleInitData: abiCoder.encode(["address[]"], [[userThreeAddress]]),
                });

                await expect(
                    web3Entry.linkProfileV2({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.NOT_APROVED);
            });
        });
    });
});
