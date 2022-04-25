import { expect } from "chai";
import { ethers } from "hardhat";
import {
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID, MOCK_CONTENT_URI,
    MOCK_PROFILE_HANDLE,
    MOCK_PROFILE_URI,
    SECOND_PROFILE_ID,
    web3Entry,
    bytes32Zero, user, userAddress, FIRST_NOTE_ID
} from "./setup";
import { getTimestamp, matchEvent } from "./utils";

describe("Post", function () {
    it("User should create profile and then post note", async function () {
        const profileData = {
            to: userAddress,
            handle: MOCK_PROFILE_HANDLE,
            uri: MOCK_PROFILE_URI,
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
        };

        // create profile
        await expect(web3Entry.createProfile(profileData)).to.not.be.reverted;

        // post note
        const noteData = {
            profileId: FIRST_PROFILE_ID,
            contentUri: MOCK_CONTENT_URI,
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
