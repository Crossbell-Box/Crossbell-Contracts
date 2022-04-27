import { expect } from "chai";
import { ethers } from "hardhat";
import {
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
    linkList,
    deployer,
    userThreeAddress,
} from "./setup.test";
import { makePostNoteData, makeProfileData, matchEvent, matchNote } from "./helpers/utils";
import { ERRORS } from "./helpers/errors";
import { formatBytes32String } from "@ethersproject/strings/src.ts/bytes32";
// eslint-disable-next-line node/no-missing-import,camelcase
import { MintNFT__factory } from "../typechain";

makeSuiteCleanRoom("Note and mint functionality ", function () {
    context("Generic", function () {
        beforeEach(async function () {
            await web3Entry.createProfile(makeProfileData(MOCK_PROFILE_HANDLE));
            await web3Entry.createProfile(makeProfileData(MOCK_PROFILE_HANDLE2));
        });

        it("User should post note", async function () {
            // post note
            const noteData = makePostNoteData(FIRST_PROFILE_ID.toString());
            await expect(web3Entry.connect(user).postNote(noteData)).to.not.be.reverted;

            let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
            matchNote(note, [
                bytes32Zero,
                0,
                bytes32Zero,
                noteData.contentUri,
                ethers.constants.AddressZero,
                ethers.constants.AddressZero,
                ethers.constants.AddressZero,
            ]);

            // mint note
            await web3Entry
                .connect(userThree)
                .mintNote(FIRST_PROFILE_ID, FIRST_NOTE_ID, userTwoAddress, []);
            await web3Entry
                .connect(userThree)
                .mintNote(FIRST_PROFILE_ID, FIRST_NOTE_ID, userThreeAddress, []);

            note = await web3Entry.getNote(FIRST_PROFILE_ID, FIRST_NOTE_ID);
            expect(note.mintNFT).to.not.equal(ethers.constants.AddressZero);
            const mintNFT = MintNFT__factory.connect(note.mintNFT, deployer);
            expect(await mintNFT.ownerOf(1)).to.equal(userTwoAddress);
            expect(await mintNFT.ownerOf(2)).to.equal(userThreeAddress);
        });

        it("User should post note with profile link", async function () {
            // link profile
            const followLinkType = ethers.utils.formatBytes32String("follow");
            await web3Entry
                .connect(user)
                .linkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, followLinkType);

            // post note
            const noteData = makePostNoteData("1");
            await expect(
                web3Entry
                    .connect(user)
                    .postNote4ProfileLink(
                        noteData,
                        FIRST_PROFILE_ID,
                        SECOND_PROFILE_ID,
                        followLinkType
                    )
            ).to.not.be.reverted;

            let note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
            matchNote(note, [
                LinkItemTypeProfile,
                FIRST_LINKLIST_ID,
                ethers.utils.hexZeroPad(ethers.utils.hexlify(SECOND_PROFILE_ID), 32),
                noteData.contentUri,
                ethers.constants.AddressZero,
                ethers.constants.AddressZero,
                ethers.constants.AddressZero,
            ]);

            // mint note
            await web3Entry
                .connect(userThree)
                .mintNote(FIRST_PROFILE_ID, FIRST_NOTE_ID, userTwoAddress, []);
            await web3Entry
                .connect(userThree)
                .mintNote(FIRST_PROFILE_ID, FIRST_NOTE_ID, userThreeAddress, []);

            note = await web3Entry.getNote(FIRST_PROFILE_ID, FIRST_NOTE_ID);
            expect(note.mintNFT).to.not.equal(ethers.constants.AddressZero);
            const mintNFT = MintNFT__factory.connect(note.mintNFT, deployer);
            expect(await mintNFT.ownerOf(1)).to.equal(userTwoAddress);
            expect(await mintNFT.ownerOf(2)).to.equal(userThreeAddress);
        });
    });
});
