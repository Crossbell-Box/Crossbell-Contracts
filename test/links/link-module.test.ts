import { expect } from "chai";
import {
    FIRST_CHARACTER_ID,
    SECOND_CHARACTER_ID,
    userTwoAddress,
    web3Entry,
    makeSuiteCleanRoom,
    MOCK_CHARACTER_URI,
    approvalLinkModule4Character,
    abiCoder,
    userThreeAddress,
} from "../setup.test";
import { makeCharacterData } from "../helpers/utils";
import { FOLLOW_LINKTYPE } from "../setup.test";

makeSuiteCleanRoom("Link Module", function () {
    context("Generic", function () {
        beforeEach(async function () {
            await web3Entry.createCharacter(makeCharacterData("handle1"));
        });
        context("Negatives", function () {
            it("User not in approval list should not fail to link a character", async function () {
                await web3Entry.createCharacter({
                    to: userTwoAddress,
                    handle: "handle2",
                    uri: MOCK_CHARACTER_URI,
                    linkModule: approvalLinkModule4Character.address,
                    linkModuleInitData: abiCoder.encode(["address[]"], [[userThreeAddress]]),
                });

                await expect(
                    web3Entry.linkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: SECOND_CHARACTER_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.be.not.reverted;
            });
        });
    });
});
