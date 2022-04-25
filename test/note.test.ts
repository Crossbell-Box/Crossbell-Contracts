import { expect } from "chai";
import { ethers } from "hardhat";
import { makeProfileData } from "./helpers/utils";
import {
    bytes32Zero,
    FIRST_NOTE_ID,
    FIRST_PROFILE_ID,
    MOCK_NOTE_URI,
    user,
    web3Entry,
} from "./setup.test";

describe("Note", function () {
    it("User should create profile and then post note", async function () {
        // create profile
        await expect(web3Entry.createProfile(makeProfileData())).to.not.be.reverted;

        // post note
        const noteData = {
            profileId: FIRST_PROFILE_ID,
            contentUri: MOCK_NOTE_URI,
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
            mintModule: ethers.constants.AddressZero,
            mintModuleInitData: [],
        };
        // await expect(web3Entry.postNote(noteData)).to.not.be.reverted;
        await web3Entry.connect(user).postNote(noteData);

        const note = await web3Entry.getNote(noteData.profileId, FIRST_NOTE_ID);
        expect(note.linkItemType).to.equal(bytes32Zero);
        expect(note.linklistId).to.equal(0);
        expect(note.linkKey).to.equal(bytes32Zero);
        expect(note.contentUri).to.equal(noteData.contentUri);
        expect(note.linkModule).to.equal(ethers.constants.AddressZero);
        expect(note.mintModule).to.equal(ethers.constants.AddressZero);
        expect(note.mintNFT).to.equal(ethers.constants.AddressZero);
    });
});
