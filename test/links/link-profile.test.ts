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
    userThree,
    userThreeAddress,
} from "../setup.test";
import { makeProfileData, matchLinkingProfileIds } from "../helpers/utils";
import { FOLLOW_LINKTYPE, userTwo } from "../setup.test";
import { ERRORS } from "../helpers/errors";

makeSuiteCleanRoom("Link", function () {
    context("Generic", function () {
        beforeEach(async function () {
            await web3Entry.createProfile(makeProfileData("handle1"));
            await web3Entry.createProfile(makeProfileData("handle2"));
            await expect(
                web3Entry.linkProfile({
                    fromProfileId: FIRST_PROFILE_ID,
                    toProfileId: SECOND_PROFILE_ID,
                    linkType: FOLLOW_LINKTYPE,
                    data: [],
                })
            ).to.not.be.reverted;
        });
        context("Negatives", function () {
            it("User should fail to link a non-existed profile", async function () {
                await expect(
                    web3Entry.linkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID + 1,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.PROFILE_NOT_EXISTED);
            });
            it("UserTwo should fail to emit a link from a profile not owned by him", async function () {
                await expect(
                    web3Entry.connect(userTwo).linkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.NOT_PROFILE_OWNER);
            });
            it("UserTwo should fail to follow a profile that has been burned", async function () {
                await web3Entry
                    .connect(userTwo)
                    .createProfile(makeProfileData("user-2", userTwoAddress));
                const pid = SECOND_PROFILE_ID + 1;
                await expect(
                    web3Entry.connect(userTwo).linkProfile({
                        fromProfileId: pid,
                        toProfileId: FIRST_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.not.be.reverted;
                await expect(web3Entry.burn(FIRST_PROFILE_ID)).to.be.not.reverted;
                await expect(
                    web3Entry.connect(userTwo).linkProfile({
                        fromProfileId: pid,
                        toProfileId: FIRST_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.PROFILE_NOT_EXISTED);
            });
            it("User should fail to unlink a profile with an unattached type", async function () {
                await expect(
                    web3Entry.unlinkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: ARBITRARY_LINKTYPE,
                    })
                ).to.be.revertedWith(ERRORS.UNATTACHED_LINKLIST);
            });
            it("UserTwo should fail to unlink a profile which does not exists", async function () {
                await expect(
                    web3Entry.connect(userTwo).unlinkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.be.revertedWith(ERRORS.NOT_PROFILE_OWNER);
            });
        });
        context("Scenarios", function () {
            it("User should get correct linking profile ids after emit a follow link", async function () {
                await matchLinkingProfileIds(FIRST_PROFILE_ID, FOLLOW_LINKTYPE, [
                    SECOND_PROFILE_ID,
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
                const linklistId = await web3Entry.getLinklistId(FIRST_PROFILE_ID, FOLLOW_LINKTYPE);
                expect(linklistId).to.be.equal(0);
            });
            it("User should get correct linking profile ids after unlink, and linklist nft still exist.", async function () {
                await expect(
                    web3Entry.unlinkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.not.be.reverted;
                await matchLinkingProfileIds(FIRST_PROFILE_ID, FOLLOW_LINKTYPE, []);

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

            it("User should set a dispatcher and the dispatcher should unlink a profile", async function () {
                await web3Entry.setOperator(FIRST_PROFILE_ID, userThreeAddress);

                await expect(
                    web3Entry.connect(userThree).unlinkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.not.be.reverted;
                await matchLinkingProfileIds(FIRST_PROFILE_ID, FOLLOW_LINKTYPE, []);
            });

            it("User could link a profile twice, and get correct linking profile ids.", async function () {
                await expect(
                    web3Entry.linkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                        data: [],
                    })
                ).to.not.reverted;
                await matchLinkingProfileIds(FIRST_PROFILE_ID, FOLLOW_LINKTYPE, [
                    SECOND_PROFILE_ID,
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
            it("User could unlink a profile twice.", async function () {
                await expect(
                    web3Entry.unlinkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.not.be.reverted;
                await expect(
                    web3Entry.unlinkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.not.be.reverted;
                await matchLinkingProfileIds(FIRST_PROFILE_ID, FOLLOW_LINKTYPE, []);

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
            it("User should get correct linking profile ids when the linking profile is burned.", async function () {
                await expect(web3Entry.burn(SECOND_PROFILE_ID)).to.be.not.reverted;
                await matchLinkingProfileIds(FIRST_PROFILE_ID, FOLLOW_LINKTYPE, []);
            });
        });
    });
    context("Create then link profile", function () {
        beforeEach(async function () {
            await expect(web3Entry.createProfile(makeProfileData())).to.not.be.reverted;
            await expect(
                web3Entry.connect(user).createThenLinkProfile({
                    fromProfileId: FIRST_PROFILE_ID,
                    to: userTwoAddress,
                    linkType: FOLLOW_LINKTYPE,
                })
            ).to.not.be.reverted;
        });
        context("Negatives", function () {
            it("createThenLinkProfile will be failed to be called twice.", async function () {
                await expect(
                    web3Entry.connect(user).createThenLinkProfile({
                        fromProfileId: FIRST_PROFILE_ID,
                        to: userTwoAddress,
                        linkType: FOLLOW_LINKTYPE,
                    })
                ).to.be.reverted;
            });
        });
        context("Scenarios", function () {
            it("UserTwo should be created a primary profile when createThenLinkProfile is called, and the profile can be resolved by handle.", async function () {
                await matchLinkingProfileIds(FIRST_PROFILE_ID, FOLLOW_LINKTYPE, [
                    SECOND_PROFILE_ID,
                ]);
                expect(await web3Entry.getPrimaryProfileId(userTwoAddress)).to.be.equal(
                    SECOND_PROFILE_ID
                );
                const userTwoPrimaryProfile = await web3Entry.getProfileByHandle(
                    userTwoAddress.toLocaleLowerCase()
                );
                expect(userTwoPrimaryProfile[0]).to.be.equal(SECOND_PROFILE_ID);
            });
        });
    });
});
