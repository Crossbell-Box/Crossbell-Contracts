import { expect } from "chai";
import {
    FIRST_LINKLIST_ID,
    FIRST_CHARACTER_ID,
    SECOND_CHARACTER_ID,
    user,
    userAddress,
    userTwoAddress,
    web3Entry,
    makeSuiteCleanRoom,
    linklist,
    ARBITRARY_LINKTYPE,
    userThree,
    userThreeAddress,
} from "../setup.test";
import { makeCharacterData, matchLinkingCharacterIds } from "../helpers/utils";
import { FOLLOW_LINKTYPE, userTwo } from "../setup.test";
import { ERRORS } from "../helpers/errors";

makeSuiteCleanRoom("Link", function () {
    context("Generic", function () {
        beforeEach(async function () {
            await web3Entry.createCharacter(makeCharacterData("handle1"));
            await web3Entry.createCharacter(makeCharacterData("handle2"));
            await expect(
                web3Entry.linkCharacter({
                    fromCharacterId: FIRST_CHARACTER_ID,
                    toCharacterId: SECOND_CHARACTER_ID,
                    linkType: FOLLOW_LINKTYPE,
                    data: [],
                })
            ).to.not.be.reverted;
        });
        context("Negatives", function () {
            it("User should fail to link a non-existed character", async function () {
                await expect(
                    web3Entry.linkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: SECOND_CHARACTER_ID + 1,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.CHARACTER_NOT_EXISTED);
            });
            it("UserTwo should fail to emit a link from a character not owned by him", async function () {
                await expect(
                    web3Entry.connect(userTwo).linkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: SECOND_CHARACTER_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.NOT_CHARACTER_OWNER);
            });
            it("UserTwo should fail to follow a character that has been burned", async function () {
                await web3Entry
                    .connect(userTwo)
                    .createCharacter(makeCharacterData("user-2", userTwoAddress));
                const pid = SECOND_CHARACTER_ID + 1;
                await expect(
                    web3Entry.connect(userTwo).linkCharacter({
                        fromCharacterId: pid,
                        toCharacterId: FIRST_CHARACTER_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.not.be.reverted;
                await expect(web3Entry.burn(FIRST_CHARACTER_ID)).to.be.not.reverted;
                await expect(
                    web3Entry.connect(userTwo).linkCharacter({
                        fromCharacterId: pid,
                        toCharacterId: FIRST_CHARACTER_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.CHARACTER_NOT_EXISTED);
            });
            it("User should fail to unlink a character with an unattached type", async function () {
                await expect(
                    web3Entry.unlinkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: SECOND_CHARACTER_ID,
                        linkType: ARBITRARY_LINKTYPE,
                    })
                ).to.be.revertedWith(ERRORS.UNATTACHED_LINKLIST);
            });
            it("UserTwo should fail to unlink a character which does not exists", async function () {
                await expect(
                    web3Entry.connect(userTwo).unlinkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: SECOND_CHARACTER_ID,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.be.revertedWith(ERRORS.NOT_CHARACTER_OWNER);
            });
        });
        context("Scenarios", function () {
            it("User should get correct linking character ids after emit a follow link", async function () {
                await matchLinkingCharacterIds(FIRST_CHARACTER_ID, FOLLOW_LINKTYPE, [
                    SECOND_CHARACTER_ID,
                ]);
            });
            it("User should get a linklist nft after emit a follow link, linklist nft properties should be correct", async function () {
                const id = await linklist.tokenOfOwnerByIndex(userAddress, 0);
                // const name = await followNFT.name(); //TODO
                // const symbol = await followNFT.symbol();
                const owner = await linklist.ownerOf(id);
                const linklistUri = await linklist.tokenURI(id);
                const total = await linklist.totalSupply();

                expect(id).to.eq(FIRST_LINKLIST_ID);
                expect(owner).to.eq(userAddress);
                expect(linklistUri).to.eq("");
                expect(total).to.eq(1);
            });
            it("User should get and transfer linklist nft", async function () {
                const id = await linklist.tokenOfOwnerByIndex(userAddress, 0);
                const owner = await linklist.ownerOf(id);
                const linklistUri = await linklist.tokenURI(id);
                const total = await linklist.totalSupply();

                expect(id).to.eq(FIRST_LINKLIST_ID);
                expect(owner).to.eq(userAddress);
                expect(linklistUri).to.eq("");
                expect(total).to.eq(1);

                // transfer and  check owner
                await linklist.transferFrom(userAddress, userTwoAddress, FIRST_LINKLIST_ID);
                expect(await linklist.ownerOf(FIRST_LINKLIST_ID)).to.eq(userTwoAddress);

                // check linklist id
                const linklistId = await web3Entry.getLinklistId(
                    FIRST_CHARACTER_ID,
                    FOLLOW_LINKTYPE
                );
                expect(linklistId).to.be.equal(0);
            });
            it("User should get correct linking character ids after unlink, and linklist nft still exist.", async function () {
                await expect(
                    web3Entry.unlinkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: SECOND_CHARACTER_ID,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.not.be.reverted;
                await matchLinkingCharacterIds(FIRST_CHARACTER_ID, FOLLOW_LINKTYPE, []);

                const id = await linklist.tokenOfOwnerByIndex(userAddress, 0);
                const total = await linklist.totalSupply();
                // const name = await followNFT.name(); //TODO
                // const symbol = await followNFT.symbol();
                const owner = await linklist.ownerOf(id);
                const linklistUri = await linklist.tokenURI(id);

                expect(id).to.eq(FIRST_LINKLIST_ID);
                expect(owner).to.eq(userAddress);
                expect(linklistUri).to.eq("");
                expect(total).to.eq(1);
            });

            it("User should set a dispatcher and the dispatcher should unlink a character", async function () {
                await web3Entry.setOperator(FIRST_CHARACTER_ID, userThreeAddress);

                await expect(
                    web3Entry.connect(userThree).unlinkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: SECOND_CHARACTER_ID,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.not.be.reverted;
                await matchLinkingCharacterIds(FIRST_CHARACTER_ID, FOLLOW_LINKTYPE, []);
            });

            it("User could link a character twice, and get correct linking character ids.", async function () {
                await expect(
                    web3Entry.linkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: SECOND_CHARACTER_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.not.reverted;
                await matchLinkingCharacterIds(FIRST_CHARACTER_ID, FOLLOW_LINKTYPE, [
                    SECOND_CHARACTER_ID,
                ]);

                const id = await linklist.tokenOfOwnerByIndex(userAddress, 0);
                const total = await linklist.totalSupply();
                // const name = await followNFT.name(); //TODO
                // const symbol = await followNFT.symbol();
                const owner = await linklist.ownerOf(id);
                const linklistUri = await linklist.tokenURI(id);

                expect(id).to.eq(FIRST_LINKLIST_ID);
                expect(owner).to.eq(userAddress);
                expect(linklistUri).to.eq("");
                expect(total).to.eq(1);
            });
            it("User could unlink a character twice.", async function () {
                await expect(
                    web3Entry.unlinkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: SECOND_CHARACTER_ID,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.not.be.reverted;

                await expect(
                    web3Entry.unlinkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: SECOND_CHARACTER_ID,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.not.be.reverted;
                await matchLinkingCharacterIds(FIRST_CHARACTER_ID, FOLLOW_LINKTYPE, []);

                const id = await linklist.tokenOfOwnerByIndex(userAddress, 0);
                const total = await linklist.totalSupply();
                const owner = await linklist.ownerOf(id);
                const linklistUri = await linklist.tokenURI(id);

                expect(id).to.eq(FIRST_LINKLIST_ID);
                expect(owner).to.eq(userAddress);
                expect(linklistUri).to.eq("");
                expect(total).to.eq(1);
            });
            it("User should get correct linking character ids when the linking character is burned.", async function () {
                await expect(web3Entry.burn(SECOND_CHARACTER_ID)).to.be.not.reverted;
                await matchLinkingCharacterIds(FIRST_CHARACTER_ID, FOLLOW_LINKTYPE, []);
            });
        });
    });
    context("Create then link character", function () {
        beforeEach(async function () {
            await expect(web3Entry.createCharacter(makeCharacterData())).to.not.be.reverted;
            await expect(
                web3Entry.connect(user).createThenLinkCharacter({
                    fromCharacterId: FIRST_CHARACTER_ID,
                    to: userTwoAddress,
                    linkType: FOLLOW_LINKTYPE,
                })
            ).to.not.be.reverted;
        });
        context("Negatives", function () {
            it("createThenLinkCharacter will be failed to be called twice.", async function () {
                await expect(
                    web3Entry.connect(user).createThenLinkCharacter({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        to: userTwoAddress,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.be.reverted;
            });
        });
        context("Scenarios", function () {
            it("UserTwo should be created a primary character when createThenLinkCharacter is called, and the character can be resolved by handle.", async function () {
                await matchLinkingCharacterIds(FIRST_CHARACTER_ID, FOLLOW_LINKTYPE, [
                    SECOND_CHARACTER_ID,
                ]);
                expect(await web3Entry.getPrimaryCharacterId(userTwoAddress)).to.be.equal(
                    SECOND_CHARACTER_ID
                );
                const userTwoPrimaryCharacter = await web3Entry.getCharacterByHandle(
                    userTwoAddress.toLocaleLowerCase()
                );
                expect(userTwoPrimaryCharacter[0]).to.be.equal(SECOND_CHARACTER_ID);
            });
        });
    });
});
