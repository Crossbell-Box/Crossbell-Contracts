import { expect } from "chai";
import { ethers } from "hardhat";
import {
    FIRST_LINKLIST_ID,
    FIRST_CHARACTER_ID,
    makeSuiteCleanRoom,
    MOCK_CHARACTER_HANDLE,
    MOCK_CHARACTER_URI,
    SECOND_CHARACTER_ID,
    userAddress,
    userTwo,
    userTwoAddress,
    web3Entry,
} from "../setup.test";
import { getTimestamp, makeCharacterData, matchEvent } from "../helpers/utils";
import { ERRORS } from "../helpers/errors";
import { CreateCharacterData, CharacterData } from "../helpers/types";
import { BigNumber } from "ethers";

makeSuiteCleanRoom("Character Creation", function () {
    context("Generic", function () {
        context("Negatives", function () {
            it("User should fail to create character with handle length > 31", async function () {
                const handle = "da2423cea4f1047556e7a142f81a7eda";
                expect(handle.length).to.gt(31);
                await expect(
                    web3Entry.createCharacter(makeCharacterData(handle))
                ).to.be.revertedWith("HandleLengthInvalid");
            });

            it("User should fail to create character with empty handle", async function () {
                await expect(
                    web3Entry.createCharacter({
                        to: userAddress,
                        handle: "",
                        uri: MOCK_CHARACTER_URI,
                        linkModule: ethers.constants.AddressZero,
                        linkModuleInitData: [],
                    })
                ).to.be.revertedWith("HandleLengthInvalid");
            });

            it("User should fail to create character with handle too short", async function () {
                await expect(
                    web3Entry.createCharacter({
                        to: userAddress,
                        handle: "a",
                        uri: MOCK_CHARACTER_URI,
                        linkModule: ethers.constants.AddressZero,
                        linkModuleInitData: [],
                    })
                ).to.be.revertedWith("HandleLengthInvalid");

                await expect(
                    web3Entry.createCharacter({
                        to: userAddress,
                        handle: "ab",
                        uri: MOCK_CHARACTER_URI,
                        linkModule: ethers.constants.AddressZero,
                        linkModuleInitData: [],
                    })
                ).to.be.revertedWith("HandleLengthInvalid");
            });

            it("User should fail to create character with invalid handle", async function () {
                const arr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()+|[]:",'.split("");
                for (const c of arr) {
                    await expect(
                        web3Entry.createCharacter({
                            to: userAddress,
                            handle: c + "ab",
                            uri: MOCK_CHARACTER_URI,
                            linkModule: ethers.constants.AddressZero,
                            linkModuleInitData: [],
                        })
                    ).to.be.revertedWith("HandleContainsInvalidCharacters");
                }
            });
        });

        context("Scenarios", function () {
            it("User should create character with handle length == 31", async function () {
                await expect(
                    web3Entry.createCharacter(makeCharacterData("_b2423cea4f1047556e7a14-f1-eth"))
                ).to.not.be.reverted;
            });
            it(`User should be able to create a character with a handle, uri,
                receive an NFT, and the handle should resolve to the NFT ID,
                and userTwo should do the same.`, async function () {
                let characterData: CreateCharacterData;
                let owner: string;
                let totalSupply: BigNumber;
                let character: CharacterData;

                characterData = makeCharacterData();
                await expect(web3Entry.createCharacter(characterData)).to.not.be.reverted;

                owner = await web3Entry.ownerOf(FIRST_CHARACTER_ID);
                totalSupply = await web3Entry.totalSupply();
                character = await web3Entry.getCharacterByHandle(MOCK_CHARACTER_HANDLE);

                expect(owner).to.eq(userAddress);
                expect(totalSupply).to.eq(FIRST_CHARACTER_ID);
                expect(character.characterId).to.equal(FIRST_CHARACTER_ID);
                expect(character.handle).to.equal(MOCK_CHARACTER_HANDLE);
                expect(character.uri).to.equal(MOCK_CHARACTER_URI);

                const testHandle = "handle-2";
                characterData = makeCharacterData(testHandle, userTwoAddress);
                await expect(
                    web3Entry.connect(userTwo).createCharacter(characterData)
                ).to.not.be.reverted;

                owner = await web3Entry.ownerOf(SECOND_CHARACTER_ID);
                totalSupply = await web3Entry.totalSupply();
                character = await web3Entry.getCharacterByHandle(testHandle);

                expect(owner).to.eq(userTwoAddress);
                expect(totalSupply).to.eq(SECOND_CHARACTER_ID);
                expect(character.characterId).to.equal(SECOND_CHARACTER_ID);
                expect(character.handle).to.equal(testHandle);
                expect(character.uri).to.equal(MOCK_CHARACTER_URI);
            });

            it("User should create a character for userTwo", async function () {
                await expect(
                    web3Entry.createCharacter(
                        makeCharacterData(MOCK_CHARACTER_HANDLE, userTwoAddress)
                    )
                ).to.not.be.reverted;
                expect(await web3Entry.ownerOf(FIRST_CHARACTER_ID)).to.eq(userTwoAddress);
            });
        });
    });
});
