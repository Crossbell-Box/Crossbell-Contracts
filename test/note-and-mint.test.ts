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
    LinkItemTypeLinklist,
    LinkItemTypeAnyUri,
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
    THIRD_PROFILE_ID,
    periphery,
    SECOND_NOTE_ID,
    MOCK_NEW_NOTE_URI,
} from "./setup.test";
import { makePostNoteData, makeProfileData, matchEvent, matchNote } from "./helpers/utils";
import { ERRORS } from "./helpers/errors";
import { formatBytes32String } from "@ethersproject/strings/src.ts/bytes32";
// eslint-disable-next-line node/no-missing-import,camelcase
import { ApprovalMintModule__factory, MintNFT__factory } from "../typechain";
import { BigNumber } from "ethers";
import { soliditySha3 } from "web3-utils";

makeSuiteCleanRoom("Note and mint functionality", function () {
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
                        .postNote4Profile(
                            makePostNoteData(FIRST_PROFILE_ID.toString()),
                            SECOND_PROFILE_ID
                        )
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
                    false,
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
                    false,
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

            it("User should set a dispatcher and post note", async function () {
                await web3Entry.setDispatcher(FIRST_PROFILE_ID, userThreeAddress);

                // post note
                const noteData = makePostNoteData(FIRST_PROFILE_ID.toString());
                await expect(web3Entry.connect(userThree).postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                    false,
                ]);
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
                    false,
                ]);
            });

            it("User should post note and then set note uri", async function () {
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
                    false,
                ]);

                // set note uri
                await web3Entry.setNoteUri(noteData.profileId, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI);
                // await expect(
                //     web3Entry.setNoteUri(noteData.profileId, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI)
                // ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    MOCK_NEW_NOTE_URI,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                    false,
                ]);
            });

            it("User should post note and then freeze note", async function () {
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
                    false,
                ]);

                // freeze note
                await expect(
                    web3Entry.freezeNote(noteData.profileId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                    true,
                ]);
            });

            it("User should failed to set note uri after freezing", async function () {
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
                    false,
                ]);

                // freeze note
                await expect(
                    web3Entry.freezeNote(noteData.profileId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                    true,
                ]);

                // set note uri should fail
                await expect(
                    web3Entry.setNoteUri(noteData.profileId, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI)
                ).to.be.revertedWith("NoteFrozen");
            });

            it("User should delete note after freezing", async function () {
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
                    false,
                ]);

                // freeze note
                await expect(
                    web3Entry.freezeNote(noteData.profileId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                    true,
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
                    web3Entry.postNote4Profile(noteData, SECOND_PROFILE_ID)
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
                    web3Entry.postNote4Profile(noteData, userThreeAddress)
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
                    web3Entry.postNote4Linklist(noteData, SECOND_LINKLIST_ID)
                ).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    LinkItemTypeLinklist,
                    ethers.utils.hexZeroPad(ethers.utils.hexlify(SECOND_LINKLIST_ID), 32),
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
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

            it("User should post note on ERC721", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_PROFILE_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                // mint note to get an NFT
                await web3Entry.connect(userThree).mintNote({
                    profileId: FIRST_PROFILE_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });
                let note = await web3Entry.getNote(FIRST_PROFILE_ID, FIRST_NOTE_ID);

                const erc721TokenAddress = note.mintNFT;
                const erc721TokenId = 1;

                // user post note 4 note
                await web3Entry.postNote4ERC721(makePostNoteData(FIRST_PROFILE_ID.toString()), {
                    tokenAddress: erc721TokenAddress,
                    erc721TokenId: erc721TokenId,
                });

                note = await web3Entry.getNote(FIRST_PROFILE_ID, SECOND_NOTE_ID);
                const linkKey = soliditySha3("ERC721", erc721TokenAddress, erc721TokenId);
                matchNote(note, [
                    LinkItemTypeERC721,
                    linkKey,
                    MOCK_NOTE_URI,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                    false,
                ]);

                const erc721 = await periphery.getLinkingERC721(linkKey as string);
                expect(erc721.tokenAddress).to.be.equal(erc721TokenAddress);
                expect(erc721.erc721TokenId).to.be.equal(erc721TokenId);
            });

            it("User should post note on any uri", async function () {
                const uri = "ipfs://QmadFPhP7n5rJkACMY6QqhtLtKgX1ixoySmxQNrU4Wo5JW";

                // user post note 4 uri
                await web3Entry.postNote4AnyUri(makePostNoteData(FIRST_PROFILE_ID.toString()), uri);

                let note = await web3Entry.getNote(FIRST_PROFILE_ID, FIRST_NOTE_ID);
                const linkKey = soliditySha3("AnyUri", uri);
                matchNote(note, [
                    LinkItemTypeAnyUri,
                    linkKey,
                    MOCK_NOTE_URI,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                    false,
                ]);

                const linkingUri = await periphery.getLinkingAnyUri(linkKey as string);
                expect(linkingUri).to.be.equal(uri);
            });

            it("User should post note on note posted by userTwo", async function () {
                // create profile for userTwo
                // profile id is 3
                await web3Entry.createProfile(
                    makeProfileData("b2423cea4f1047556e7a14", userTwoAddress)
                );
                // post note
                const noteData = makePostNoteData(THIRD_PROFILE_ID.toString());
                // await expect(web3Entry.connect(userTwo).postNote(noteData)).to.not.be.reverted;
                await web3Entry.connect(userTwo).postNote(noteData);

                let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
                matchNote(note, [
                    bytes32Zero,
                    bytes32Zero,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                    false,
                ]);

                // user post note 4 note
                await web3Entry.postNote4Note(makePostNoteData(FIRST_PROFILE_ID.toString()), {
                    profileId: THIRD_PROFILE_ID,
                    noteId: FIRST_NOTE_ID,
                });

                note = await web3Entry.getNote(FIRST_PROFILE_ID, FIRST_NOTE_ID);
                const linkKey = soliditySha3("Note", THIRD_PROFILE_ID, FIRST_NOTE_ID);
                matchNote(note, [
                    LinkItemTypeNote,
                    linkKey,
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                    false,
                ]);

                const linkingNote = await periphery.getLinkingNote(linkKey as string);
                expect(linkingNote.profileId).to.be.equal(THIRD_PROFILE_ID);
                expect(linkingNote.noteId).to.be.equal(FIRST_NOTE_ID);
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
                        freeze: false,
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
