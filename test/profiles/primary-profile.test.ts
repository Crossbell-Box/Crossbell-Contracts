import { expect } from "chai";
import { ethers } from "hardhat";
import {
    bytes32Zero,
    deployerAddress,
    FIRST_LINKLIST_ID,
    FIRST_CHARACTER_ID,
    FOLLOW_LINKTYPE,
    makeSuiteCleanRoom,
    MOCK_CHARACTER_HANDLE,
    MOCK_CHARACTER_HANDLE2,
    MOCK_CHARACTER_URI,
    SECOND_CHARACTER_ID,
    user,
    userAddress,
    userThree,
    userThreeAddress,
    userTwo,
    userTwoAddress,
    web3Entry,
    linklist,
    // eslint-disable-next-line node/no-missing-import
} from "../setup.test";
// eslint-disable-next-line node/no-missing-import
import { makeCharacterData, matchEvent } from "../helpers/utils";
// eslint-disable-next-line node/no-missing-import
import { ERRORS } from "../helpers/errors";

makeSuiteCleanRoom("Primary Character", function () {
    context("Generic", function () {
        beforeEach(async function () {
            const characterData = makeCharacterData();
            await expect(web3Entry.createCharacter(characterData)).to.not.be.reverted;
        });

        context("Negatives", function () {
            it("UserTwo should fail to set the primary character as a character owned by user 1", async function () {
                await expect(
                    web3Entry.connect(userTwo).setPrimaryCharacterId(FIRST_CHARACTER_ID)
                ).to.be.revertedWith(ERRORS.NOT_CHARACTER_OWNER);
            });
        });

        context("Scenarios", function () {
            it("User's first character should be the primary character", async function () {
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(
                    FIRST_CHARACTER_ID
                );
            });

            it("User should set the primary character", async function () {
                await expect(
                    web3Entry.setPrimaryCharacterId(FIRST_CHARACTER_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(
                    FIRST_CHARACTER_ID
                );
            });

            it("User should set new primary character", async function () {
                // create new character
                const newHandle = "handle-2";
                await expect(
                    web3Entry.createCharacter(makeCharacterData(newHandle))
                ).to.not.be.reverted;

                // set new primary character
                await expect(
                    web3Entry.setPrimaryCharacterId(SECOND_CHARACTER_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(
                    SECOND_CHARACTER_ID
                );
            });

            it("User should transfer the primary character, and then their primary character should be unset", async function () {
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(
                    FIRST_CHARACTER_ID
                );

                await expect(
                    web3Entry.transferFrom(userAddress, userTwoAddress, FIRST_CHARACTER_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(0);
            });

            it("User should transfer the primary character, and the operator should be unset", async function () {
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(
                    FIRST_CHARACTER_ID
                );

                // set operator
                await web3Entry.setOperator(FIRST_CHARACTER_ID, userThreeAddress);

                await expect(
                    web3Entry.transferFrom(userAddress, userTwoAddress, FIRST_CHARACTER_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(0);
                expect(await web3Entry.getOperator(FIRST_CHARACTER_ID)).to.eq(
                    ethers.constants.AddressZero
                );
            });

            it("User should transfer the primary character, and the linklist", async function () {
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(
                    FIRST_CHARACTER_ID
                );

                // link character
                await web3Entry.connect(userThree).createCharacter(makeCharacterData("handle3"));
                await web3Entry.linkCharacter({
                    fromCharacterId: FIRST_CHARACTER_ID,
                    toCharacterId: SECOND_CHARACTER_ID,
                    linkType: FOLLOW_LINKTYPE,
                    data: [],
                });
                expect(await web3Entry.getLinklistId(FIRST_CHARACTER_ID, FOLLOW_LINKTYPE)).to.eq(
                    FIRST_LINKLIST_ID
                );

                // transfer character to userTwo
                await expect(
                    web3Entry.transferFrom(userAddress, userTwoAddress, FIRST_CHARACTER_ID)
                ).to.not.be.reverted;

                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(0);
                expect(await web3Entry.getLinklistId(FIRST_CHARACTER_ID, FOLLOW_LINKTYPE)).to.eq(1);

                // check character and linklist owner
                expect(await web3Entry.ownerOf(FIRST_CHARACTER_ID)).to.eq(userTwoAddress);
                expect(await linklist.ownerOf(FIRST_LINKLIST_ID)).to.eq(userTwoAddress);
            });

            it("User without a character, and then receives a character, it should be unset", async function () {
                await expect(
                    web3Entry.transferFrom(userAddress, userTwoAddress, FIRST_CHARACTER_ID)
                ).to.not.be.reverted;
                // user's primary character should be unset
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(0);
                // userTwo's primary character should be unset
                expect(await web3Entry.getPrimaryCharacterId(userTwoAddress)).to.eq(0);

                // userTwo set primary character
                await expect(
                    web3Entry.connect(userTwo).setPrimaryCharacterId(FIRST_CHARACTER_ID)
                ).to.not.be.reverted;
                expect(await web3Entry.getPrimaryCharacterId(userTwoAddress)).to.eq(
                    FIRST_CHARACTER_ID
                );
            });

            it("UserTwo should fail to set handle as a character owned by user 1", async function () {
                await expect(
                    web3Entry.connect(userTwo).setHandle(FIRST_CHARACTER_ID, MOCK_CHARACTER_HANDLE2)
                ).to.be.revertedWith(ERRORS.NOT_CHARACTER_OWNER);
            });

            it("UserTwo should burn primary character", async function () {
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(
                    FIRST_CHARACTER_ID
                );

                await web3Entry.burn(FIRST_CHARACTER_ID);
                expect(await web3Entry.getPrimaryCharacterId(userAddress)).to.eq(0);
                expect(await web3Entry.getHandle(FIRST_CHARACTER_ID)).to.eq("");
                expect(await web3Entry.getOperator(FIRST_CHARACTER_ID)).to.eq(
                    ethers.constants.AddressZero
                );
                const character = await web3Entry.getCharacter(FIRST_CHARACTER_ID);
                expect(character.noteCount).to.be.equal(0);
                expect(character.characterId).to.be.equal(0);
            });
        });
    });
});
