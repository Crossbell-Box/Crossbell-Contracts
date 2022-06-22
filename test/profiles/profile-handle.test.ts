import { expect } from "chai";
import { ethers } from "hardhat";
import {
    FIRST_CHARACTER_ID,
    makeSuiteCleanRoom,
    MOCK_CHARACTER_HANDLE,
    user,
    userThree,
    userThreeAddress,
    web3Entry,
} from "../setup.test";
import { makeCharacterData, matchEvent } from "../helpers/utils";
import { ERRORS } from "../helpers/errors";

makeSuiteCleanRoom("Character handle Functionality ", function () {
    context("Generic", function () {
        beforeEach(async function () {
            const characterData = makeCharacterData();
            await expect(web3Entry.createCharacter(characterData)).to.not.be.reverted;
        });

        context("Scenarios", function () {
            it("User should fail to create character or set handle with exists handle", async function () {
                const characterData = makeCharacterData();
                await expect(web3Entry.createCharacter(characterData)).to.be.revertedWith(
                    ERRORS.HANDLE_EXISTS
                );

                await expect(
                    web3Entry.setHandle(FIRST_CHARACTER_ID, MOCK_CHARACTER_HANDLE)
                ).to.be.revertedWith(ERRORS.HANDLE_EXISTS);
            });

            it("User should fail to create character or set handle with handle length > 31", async function () {
                // create character
                const handle = "da2423cea4f1047556e7a142f81a7eda";
                const characterData = makeCharacterData(handle);
                await expect(web3Entry.createCharacter(characterData)).to.be.revertedWith(
                    ERRORS.HANDLE_LENGTH_INVALID
                );

                // set handle
                await expect(web3Entry.setHandle(FIRST_CHARACTER_ID, handle)).to.be.revertedWith(
                    ERRORS.HANDLE_LENGTH_INVALID
                );
            });

            it("User should fail to create character set handle with empty handle", async function () {
                // create character
                const handle = "";
                const characterData = makeCharacterData(handle);
                await expect(web3Entry.createCharacter(characterData)).to.be.revertedWith(
                    ERRORS.HANDLE_LENGTH_INVALID
                );

                // set handle
                await expect(web3Entry.setHandle(FIRST_CHARACTER_ID, handle)).to.be.revertedWith(
                    ERRORS.HANDLE_LENGTH_INVALID
                );
            });

            it("User should fail to create character set handle with invalid handle", async function () {
                const arr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()+|[]:",'.split("");
                for (const c of arr) {
                    // create character
                    const characterData = makeCharacterData(c + "ab");
                    await expect(web3Entry.createCharacter(characterData)).to.be.revertedWith(
                        ERRORS.HANDLE_CONTAINS_INVALID_CHARS
                    );

                    // set handle
                    await expect(
                        web3Entry.setHandle(FIRST_CHARACTER_ID, c + "ab")
                    ).to.be.revertedWith(ERRORS.HANDLE_CONTAINS_INVALID_CHARS);
                }
            });

            it("User should create character set handle with handle length == 31", async function () {
                const characterData = makeCharacterData("_ab2423cea4f1047556e7a14-f1-eth");
                await expect(web3Entry.createCharacter(characterData)).to.not.be.reverted;

                await expect(
                    web3Entry.setHandle(FIRST_CHARACTER_ID, "_ab2423cea4f1047556e7a14-f1-btc")
                ).to.not.be.reverted;
            });

            it("User should set a operator and set handle with handle length == 31", async function () {
                const characterData = makeCharacterData("_ab2423cea4f1047556e7a14-f1-eth");
                await expect(web3Entry.createCharacter(characterData)).to.not.be.reverted;

                await web3Entry.setOperator(FIRST_CHARACTER_ID, userThreeAddress);

                await expect(
                    web3Entry
                        .connect(userThree)
                        .setHandle(FIRST_CHARACTER_ID, "_ab2423cea4f1047556e7a14-f1-btc")
                ).to.not.be.reverted;
            });
        });
    });
});
