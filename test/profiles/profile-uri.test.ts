import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { ERRORS } from "../helpers/errors";
import {
    FIRST_CHARACTER_ID,
    MOCK_CHARACTER_URI,
    makeSuiteCleanRoom,
    user,
    userTwo,
    userAddress,
    userTwoAddress,
    web3Entry,
    MOCK_URI,
    // eslint-disable-next-line node/no-missing-import
} from "../setup.test";
import { makeCharacterData } from "../helpers/utils";

makeSuiteCleanRoom("Character URI Functionality", function () {
    context("Generic", function () {
        beforeEach(async function () {
            const characterData = makeCharacterData();
            await expect(web3Entry.createCharacter(characterData)).to.not.be.reverted;
        });

        context("Scenarios for Character", function () {
            it("UserTwo should fail to set character uri as a character owned by user 1", async function () {
                await expect(
                    web3Entry.connect(userTwo).setCharacterUri(FIRST_CHARACTER_ID, MOCK_URI)
                ).to.be.revertedWith(ERRORS.NOT_CHARACTER_OWNER);
            });

            it("User should set new character uri", async function () {
                // set character uri
                await expect(
                    web3Entry.setCharacterUri(FIRST_CHARACTER_ID, MOCK_URI)
                ).to.not.be.reverted;

                expect(await web3Entry.getCharacterUri(FIRST_CHARACTER_ID)).to.eq(MOCK_URI);
            });

            it("Should return the correct tokenURI after transfer", async function () {
                await expect(
                    web3Entry.transferFrom(userAddress, userTwoAddress, FIRST_CHARACTER_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getCharacterUri(FIRST_CHARACTER_ID)).to.eq(
                    MOCK_CHARACTER_URI
                );
                expect(await web3Entry.tokenURI(FIRST_CHARACTER_ID)).to.eq(MOCK_CHARACTER_URI);
            });
        });
    });
});
