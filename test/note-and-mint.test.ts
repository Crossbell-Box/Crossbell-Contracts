import { expect } from "chai";
import { ethers } from "hardhat";
import {
    abiCoder,
    deployerAddress,
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID,
    makeSuiteCleanRoom,
    MOCK_PROFILE_HANDLE,
    MOCK_PROFILE_HANDLE2,
    MOCK_PROFILE_URI,
    FIRST_NOTE_ID,
    SECOND_PROFILE_ID,
    MOCK_NOTE_URI,
    bytes32Zero,
    LinkItemTypeProfile,
    LinkItemTypeAddress,
    LinkItemTypeNote,
    LinkItemTypeERC721,
    LinkItemTypeList,
    LinkItemTypeAny,
    user,
    userAddress,
    userTwo,
    userTwoAddress,
    web3Entry,
    userThree,
    linklist,
    deployer,
    userThreeAddress,
    FollowLinkType,
    LikeLinkType,
    SECOND_LINKLIST_ID,
    feeMintModule,
    approvalMintModule,
} from "./setup.test";
import { makePostNoteData, makeProfileData, matchEvent, matchNote } from "./helpers/utils";
import { ERRORS } from "./helpers/errors";
import { formatBytes32String } from "@ethersproject/strings/src.ts/bytes32";
// eslint-disable-next-line node/no-missing-import,camelcase
import { ApprovalMintModule__factory, MintNFT__factory } from "../typechain";
import { BigNumber } from "ethers";

makeSuiteCleanRoom("Note and mint functionality ", function () {
    context("Generic", function () {
        beforeEach(async function () {
            await web3Entry.createProfile(makeProfileData(MOCK_PROFILE_HANDLE));
            await web3Entry.createProfile(makeProfileData(MOCK_PROFILE_HANDLE2));
        });

        context("Negatives", function () {
            it("UserTwo should fail to post note at a profile owned by user 1", async function () {
                await expect(
                    web3Entry
                        .connect(userTwo)
                        .postNote(makePostNoteData(FIRST_PROFILE_ID.toString()))
                ).to.be.revertedWith(ERRORS.NOT_PROFILE_OWNER);
            });

            it("UserTwo should fail to post note for profile link at a profile owned by user 1", async function () {
                // link profile
                await web3Entry.linkProfile({
                    fromProfileId: SECOND_PROFILE_ID,
                    toProfileId: FIRST_PROFILE_ID,
                    linkType: FollowLinkType,
                    data: [],
                });

                // post note for profile link
                await expect(
                    web3Entry
                        .connect(userTwo)
                        .postNote4ProfileLink(makePostNoteData(FIRST_PROFILE_ID.toString()), {
                            fromProfileId: FIRST_PROFILE_ID,
                            toProfileId: SECOND_PROFILE_ID,
                            linkType: FollowLinkType,
                            data: [],
                        })
                ).to.be.revertedWith(ERRORS.NOT_PROFILE_OWNER);
            });

            it("User should fail to link a non-existent note", async function () {
                await expect(
                    web3Entry.linkNote({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: FIRST_PROFILE_ID,
                        toNoteId: FIRST_NOTE_ID,
                        linkType: FollowLinkType,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.NOTE_NOT_EXISTs);
            });

            it("User should fail to link a deleted note", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_PROFILE_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                ]);

                // delete note
                await expect(
                    web3Entry.deleteNote(noteData.profileId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    true,
                ]);

                await expect(
                    web3Entry.linkNote({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: FIRST_PROFILE_ID,
                        toNoteId: FIRST_NOTE_ID,
                        linkType: FollowLinkType,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.NOTE_DELETED);
            });

            it("User should fail to mint a deleted note", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_PROFILE_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                ]);

                // delete note
                await expect(
                    web3Entry.deleteNote(noteData.profileId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    true,
                ]);

                // mint note
                await expect(
                    web3Entry.connect(userThree).mintNote({
                        profileId: FIRST_PROFILE_ID,
                        noteId: FIRST_NOTE_ID,
                        to: userTwoAddress,
                        mintModuleData: [],
                    })
                ).to.be.revertedWith(ERRORS.NOTE_DELETED);
            });

            it("User should fail to mint a non-existent note", async function () {
                // mint note
                await expect(
                    web3Entry.connect(userThree).mintNote({
                        profileId: FIRST_PROFILE_ID,
                        noteId: FIRST_NOTE_ID,
                        to: userTwoAddress,
                        mintModuleData: [],
                    })
                ).to.be.revertedWith(ERRORS.NOTE_NOT_EXISTs);
            });
        });

        context("Scenarios", function () {
            it("User should post note", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_PROFILE_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                ]);

                // mint note
                await web3Entry.connect(userThree).mintNote({
                    profileId: FIRST_PROFILE_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });
                await web3Entry.connect(userThree).mintNote({
                    profileId: FIRST_PROFILE_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userThreeAddress,
                    mintModuleData: [],
                });

                note = await web3Entry.getNote(FIRST_PROFILE_ID, FIRST_NOTE_ID);
                expect(note.mintNFT).to.not.equal(ethers.constants.AddressZero);
                const mintNFT = MintNFT__factory.connect(note.mintNFT, deployer);
                expect(await mintNFT.ownerOf(1)).to.equal(userTwoAddress);
                expect(await mintNFT.ownerOf(2)).to.equal(userThreeAddress);
            });

            it("User should post and delete note", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_PROFILE_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                ]);

                // delete note
                await expect(
                    web3Entry.deleteNote(noteData.profileId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    true,
                ]);
            });

            it("User should link note", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_PROFILE_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                ]);

                // delete note
                await expect(
                    web3Entry.linkNote({
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: FIRST_PROFILE_ID,
                        toNoteId: FIRST_NOTE_ID,
                        linkType: FollowLinkType,
                        data: [],
                    })
                ).to.not.be.reverted;
            });

            it("User should post note with profile link", async function () {
                // link profile
                await web3Entry.linkProfile({
                    fromProfileId: FIRST_PROFILE_ID,
                    toProfileId: SECOND_PROFILE_ID,
                    linkType: FollowLinkType,
                    data: [],
                });

                // post note
                const noteData = makePostNoteData("1");
                await expect(
                    web3Entry.postNote4ProfileLink(noteData, {
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: SECOND_PROFILE_ID,
                        linkType: FollowLinkType,
                        data: [],
                    })
                ).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    LinkItemTypeProfile,
                    ethers.utils.hexZeroPad(ethers.utils.hexlify(SECOND_PROFILE_ID), 32),
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                ]);

                // mint note
                await web3Entry.connect(userThree).mintNote({
                    profileId: FIRST_PROFILE_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });

                note = await web3Entry.getNote(FIRST_PROFILE_ID, FIRST_NOTE_ID);
                expect(await MintNFT__factory.connect(note.mintNFT, deployer).ownerOf(1)).to.equal(
                    userTwoAddress
                );
            });

            it("User should post note with address link", async function () {
                // link address
                await web3Entry.linkAddress({
                    fromProfileId: FIRST_PROFILE_ID,
                    ethAddress: userThreeAddress,
                    linkType: FollowLinkType,
                    data: [],
                });

                // post note
                const noteData = makePostNoteData();
                await expect(
                    web3Entry.postNote4ProfileLink(noteData, {
                        fromProfileId: FIRST_PROFILE_ID,
                        toProfileId: userThreeAddress,
                        linkType: FollowLinkType,
                        data: [],
                    })
                ).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    LinkItemTypeProfile,
                    ethers.utils.hexZeroPad(ethers.utils.hexlify(userThreeAddress), 32),
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                ]);

                // mint note
                await web3Entry.connect(userThree).mintNote({
                    profileId: FIRST_PROFILE_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });

                note = await web3Entry.getNote(FIRST_PROFILE_ID, FIRST_NOTE_ID);
                expect(await MintNFT__factory.connect(note.mintNFT, deployer).ownerOf(1)).to.equal(
                    userTwoAddress
                );
            });

            it("User should post note with linklist link", async function () {
                // link profile
                await web3Entry.linkProfile({
                    fromProfileId: SECOND_PROFILE_ID,
                    toProfileId: FIRST_PROFILE_ID,
                    linkType: FollowLinkType,
                    data: [],
                });

                // link linklist
                await web3Entry.linkLinklist({
                    fromProfileId: FIRST_PROFILE_ID,
                    toLinkListId: FIRST_LINKLIST_ID,
                    linkType: LikeLinkType,
                    data: [],
                });

                // post note
                const noteData = makePostNoteData();
                await expect(
                    web3Entry.postNote4LinklistLink(noteData, {
                        fromProfileId: FIRST_PROFILE_ID,
                        toLinkListId: SECOND_LINKLIST_ID,
                        linkType: LikeLinkType,
                        data: [],
                    })
                ).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    LinkItemTypeList,
                    ethers.utils.hexZeroPad(ethers.utils.hexlify(SECOND_LINKLIST_ID), 32),
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                ]);

                // mint note
                await web3Entry.connect(userThree).mintNote({
                    profileId: FIRST_PROFILE_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });

                note = await web3Entry.getNote(FIRST_PROFILE_ID, FIRST_NOTE_ID);
                expect(await MintNFT__factory.connect(note.mintNFT, deployer).ownerOf(1)).to.equal(
                    userTwoAddress
                );
            });
        });

        context("Mint Module", function () {
            it("User should post note with mintModule, and userTwo should mint note", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_PROFILE_ID.toString());

                await expect(
                    web3Entry.postNote({
                        profileId: FIRST_PROFILE_ID,
                        contentUri: MOCK_NOTE_URI,
                        linkModule: ethers.constants.AddressZero,
                        linkModuleInitData: [],
                        mintModule: approvalMintModule.address,
                        mintModuleInitData: abiCoder.encode(["address[]"], [[userTwoAddress]]),
                    })
                ).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    approvalMintModule.address,
                    ethers.constants.AddressZero,
                    false,
                ]);

                const ApproveMint = ApprovalMintModule__factory.connect(
                    approvalMintModule.address,
                    deployer
                );

                // const isApproved = await ApproveMint.isApproved(
                //     userAddress,
                //     FIRST_PROFILE_ID,
                //     FIRST_NOTE_ID,
                //     userTwoAddress
                // );
                // console.log(isApproved);

                // mint note
                await web3Entry.connect(userThree).mintNote({
                    profileId: FIRST_PROFILE_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });
                await expect(
                    web3Entry.connect(userThree).mintNote({
                        profileId: FIRST_PROFILE_ID,
                        noteId: FIRST_NOTE_ID,
                        to: userThreeAddress,
                        mintModuleData: [],
                    })
                ).to.be.revertedWith(ERRORS.NOT_APROVED);

                note = await web3Entry.getNote(FIRST_PROFILE_ID, FIRST_NOTE_ID);
                expect(note.mintNFT).to.not.equal(ethers.constants.AddressZero);
                const mintNFT = MintNFT__factory.connect(note.mintNFT, deployer);
                expect(await mintNFT.ownerOf(1)).to.equal(userTwoAddress);
            });
        });
    });
});
