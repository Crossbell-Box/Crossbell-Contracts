import { expect } from "chai";
import { ethers } from "hardhat";
import {
    abiCoder,
    deployerAddress,
    FIRST_LINKLIST_ID,
    FIRST_CHARACTER_ID,
    makeSuiteCleanRoom,
    MOCK_CHARACTER_HANDLE,
    MOCK_CHARACTER_HANDLE2,
    MOCK_CHARACTER_URI,
    FIRST_NOTE_ID,
    SECOND_CHARACTER_ID,
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
    THIRD_CHARACTER_ID,
    periphery,
    SECOND_NOTE_ID,
    MOCK_NEW_NOTE_URI,
} from "./setup.test";
import { makePostNoteData, makeCharacterData, matchEvent, matchNote } from "./helpers/utils";
import { ERRORS } from "./helpers/errors";
import { formatBytes32String } from "@ethersproject/strings/src.ts/bytes32";
// eslint-disable-next-line node/no-missing-import,camelcase
import { ApprovalMintModule__factory, MintNFT__factory } from "../typechain";
import { BigNumber } from "ethers";
import { soliditySha3 } from "web3-utils";

makeSuiteCleanRoom("Note and mint functionality", function () {
    context("Generic", function () {
        beforeEach(async function () {
            await web3Entry.createCharacter(makeCharacterData(MOCK_CHARACTER_HANDLE));
            await web3Entry.createCharacter(makeCharacterData(MOCK_CHARACTER_HANDLE2));
        });

        context("Negatives", function () {
            it("UserTwo should fail to post note at a character owned by user 1", async function () {
                await expect(
                    web3Entry
                        .connect(userTwo)
                        .postNote(makePostNoteData(FIRST_CHARACTER_ID.toString()))
                ).to.be.revertedWith(ERRORS.NOT_CHARACTER_OWNER);
            });

            it("UserTwo should fail to post note for character link at a character owned by user 1", async function () {
                // link character
                await web3Entry.linkCharacter({
                    fromCharacterId: SECOND_CHARACTER_ID,
                    toCharacterId: FIRST_CHARACTER_ID,
                    linkType: FollowLinkType,
                    data: [],
                });

                // post note for character link
                await expect(
                    web3Entry
                        .connect(userTwo)
                        .postNote4Character(
                            makePostNoteData(FIRST_CHARACTER_ID.toString()),
                            SECOND_CHARACTER_ID
                        )
                ).to.be.revertedWith(ERRORS.NOT_CHARACTER_OWNER);
            });

            it("User should fail to link a non-existent note", async function () {
                await expect(
                    web3Entry.linkNote({
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: FIRST_CHARACTER_ID,
                        toNoteId: FIRST_NOTE_ID,
                        linkType: FollowLinkType,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.NOTE_NOT_EXISTS);
            });

            it("User should fail to link a deleted note", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    web3Entry.deleteNote(noteData.characterId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: FIRST_CHARACTER_ID,
                        toNoteId: FIRST_NOTE_ID,
                        linkType: FollowLinkType,
                        data: [],
                    })
                ).to.be.revertedWith(ERRORS.NOTE_DELETED);
            });

            it("User should fail to mint a deleted note", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    web3Entry.deleteNote(noteData.characterId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                        characterId: FIRST_CHARACTER_ID,
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
                        characterId: FIRST_CHARACTER_ID,
                        noteId: FIRST_NOTE_ID,
                        to: userTwoAddress,
                        mintModuleData: [],
                    })
                ).to.be.revertedWith(ERRORS.NOTE_NOT_EXISTS);
            });
        });

        context("Scenarios", function () {
            it("User should post note", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    characterId: FIRST_CHARACTER_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });
                await web3Entry.connect(userThree).mintNote({
                    characterId: FIRST_CHARACTER_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userThreeAddress,
                    mintModuleData: [],
                });

                note = await web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
                expect(note.mintNFT).to.not.equal(ethers.constants.AddressZero);
                const mintNFT = MintNFT__factory.connect(note.mintNFT, deployer);
                expect(await mintNFT.ownerOf(1)).to.equal(userTwoAddress);
                expect(await mintNFT.ownerOf(2)).to.equal(userThreeAddress);
            });

            it("User should set a operator and post note", async function () {
                await web3Entry.setOperator(FIRST_CHARACTER_ID, userThreeAddress);

                // post note
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.connect(userThree).postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    web3Entry.deleteNote(noteData.characterId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                await web3Entry.setNoteUri(noteData.characterId, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI);

                note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    web3Entry.lockNote(noteData.characterId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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

            it("User should failed to set note uri or set link module or set mint module after freezing", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    web3Entry.lockNote(noteData.characterId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    web3Entry.setNoteUri(noteData.characterId, FIRST_NOTE_ID, MOCK_NEW_NOTE_URI)
                ).to.be.revertedWith("NoteLocked");

                await expect(
                    web3Entry.setLinkModule4Note({
                        characterId: noteData.characterId,
                        noteId: FIRST_NOTE_ID,
                        linkModule: ethers.constants.AddressZero,
                        linkModuleInitData: [],
                    })
                ).to.be.revertedWith("NoteLocked");

                await expect(
                    web3Entry.setMintModule4Note({
                        characterId: noteData.characterId,
                        noteId: FIRST_NOTE_ID,
                        mintModule: ethers.constants.AddressZero,
                        mintModuleInitData: [],
                    })
                ).to.be.revertedWith("NoteLocked");
            });

            it("User should delete note after freezing", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    web3Entry.lockNote(noteData.characterId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    web3Entry.deleteNote(noteData.characterId, FIRST_NOTE_ID)
                ).to.not.be.reverted;
                note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                        fromCharacterId: FIRST_CHARACTER_ID,
                        toCharacterId: FIRST_CHARACTER_ID,
                        toNoteId: FIRST_NOTE_ID,
                        linkType: FollowLinkType,
                        data: [],
                    })
                ).to.not.be.reverted;
            });

            it("User should post note with character link", async function () {
                // link character
                await web3Entry.linkCharacter({
                    fromCharacterId: FIRST_CHARACTER_ID,
                    toCharacterId: SECOND_CHARACTER_ID,
                    linkType: FollowLinkType,
                    data: [],
                });

                // post note
                const noteData = makePostNoteData("1");
                await expect(
                    web3Entry.postNote4Character(noteData, SECOND_CHARACTER_ID)
                ).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
                matchNote(note, [
                    LinkItemTypeProfile,
                    ethers.utils.hexZeroPad(ethers.utils.hexlify(SECOND_CHARACTER_ID), 32),
                    noteData.contentUri,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    ethers.constants.AddressZero,
                    false,
                    false,
                ]);

                // mint note
                await web3Entry.connect(userThree).mintNote({
                    characterId: FIRST_CHARACTER_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });

                note = await web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
                expect(await MintNFT__factory.connect(note.mintNFT, deployer).ownerOf(1)).to.equal(
                    userTwoAddress
                );
            });

            it("User should post note with address link", async function () {
                // link address
                await web3Entry.linkAddress({
                    fromCharacterId: FIRST_CHARACTER_ID,
                    ethAddress: userThreeAddress,
                    linkType: FollowLinkType,
                    data: [],
                });

                // post note
                const noteData = makePostNoteData();
                await expect(
                    web3Entry.postNote4Character(noteData, userThreeAddress)
                ).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    characterId: FIRST_CHARACTER_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });

                note = await web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
                expect(await MintNFT__factory.connect(note.mintNFT, deployer).ownerOf(1)).to.equal(
                    userTwoAddress
                );
            });

            it("User should post note with linklist link", async function () {
                // link character
                await web3Entry.linkCharacter({
                    fromCharacterId: SECOND_CHARACTER_ID,
                    toCharacterId: FIRST_CHARACTER_ID,
                    linkType: FollowLinkType,
                    data: [],
                });

                // link linklist
                await web3Entry.linkLinklist({
                    fromCharacterId: FIRST_CHARACTER_ID,
                    toLinkListId: FIRST_LINKLIST_ID,
                    linkType: LikeLinkType,
                    data: [],
                });

                // post note
                const noteData = makePostNoteData();
                await expect(
                    web3Entry.postNote4Linklist(noteData, SECOND_LINKLIST_ID)
                ).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                    characterId: FIRST_CHARACTER_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });

                note = await web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
                expect(await MintNFT__factory.connect(note.mintNFT, deployer).ownerOf(1)).to.equal(
                    userTwoAddress
                );
            });

            it("User should post note on ERC721", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());
                await expect(web3Entry.postNote(noteData)).to.not.be.reverted;

                // mint note to get an NFT
                await web3Entry.connect(userThree).mintNote({
                    characterId: FIRST_CHARACTER_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });
                let note = await web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);

                const erc721TokenAddress = note.mintNFT;
                const erc721TokenId = 1;

                // user post note 4 note
                await web3Entry.postNote4ERC721(makePostNoteData(FIRST_CHARACTER_ID.toString()), {
                    tokenAddress: erc721TokenAddress,
                    erc721TokenId: erc721TokenId,
                });

                note = await web3Entry.getNote(FIRST_CHARACTER_ID, SECOND_NOTE_ID);
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
                await web3Entry.postNote4AnyUri(
                    makePostNoteData(FIRST_CHARACTER_ID.toString()),
                    uri
                );

                let note = await web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
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
                // create character for userTwo
                // character id is 3
                await web3Entry.createCharacter(
                    makeCharacterData("b2423cea4f1047556e7a14", userTwoAddress)
                );
                // post note
                const noteData = makePostNoteData(THIRD_CHARACTER_ID.toString());
                // await expect(web3Entry.connect(userTwo).postNote(noteData)).to.not.be.reverted;
                await web3Entry.connect(userTwo).postNote(noteData);

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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
                await web3Entry.postNote4Note(makePostNoteData(FIRST_CHARACTER_ID.toString()), {
                    characterId: THIRD_CHARACTER_ID,
                    noteId: FIRST_NOTE_ID,
                });

                note = await web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
                const linkKey = soliditySha3("Note", THIRD_CHARACTER_ID, FIRST_NOTE_ID);
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
                expect(linkingNote.characterId).to.be.equal(THIRD_CHARACTER_ID);
                expect(linkingNote.noteId).to.be.equal(FIRST_NOTE_ID);
            });
        });

        context("Mint Module", function () {
            it("User should post note with mintModule, and userTwo should mint note", async function () {
                // post note
                const noteData = makePostNoteData(FIRST_CHARACTER_ID.toString());

                await expect(
                    web3Entry.postNote({
                        characterId: FIRST_CHARACTER_ID,
                        contentUri: MOCK_NOTE_URI,
                        linkModule: ethers.constants.AddressZero,
                        linkModuleInitData: [],
                        mintModule: approvalMintModule.address,
                        mintModuleInitData: abiCoder.encode(["address[]"], [[userTwoAddress]]),
                        locked: false,
                    })
                ).to.not.be.reverted;

                let note = await web3Entry.getNote(noteData.characterId, FIRST_NOTE_ID);
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

                // mint note
                await web3Entry.connect(userThree).mintNote({
                    characterId: FIRST_CHARACTER_ID,
                    noteId: FIRST_NOTE_ID,
                    to: userTwoAddress,
                    mintModuleData: [],
                });
                await expect(
                    web3Entry.connect(userThree).mintNote({
                        characterId: FIRST_CHARACTER_ID,
                        noteId: FIRST_NOTE_ID,
                        to: userThreeAddress,
                        mintModuleData: [],
                    })
                ).to.be.revertedWith(ERRORS.NOT_APPROVED);

                note = await web3Entry.getNote(FIRST_CHARACTER_ID, FIRST_NOTE_ID);
                expect(note.mintNFT).to.not.equal(ethers.constants.AddressZero);
                const mintNFT = MintNFT__factory.connect(note.mintNFT, deployer);
                expect(await mintNFT.ownerOf(1)).to.equal(userTwoAddress);
            });
        });
    });
});
