import { expect } from "chai";
import { ethers } from "hardhat";
import { FIRST_LINKLIST_ID, FIRST_PROFILE_ID, SECOND_PROFILE_ID, web3Entry } from "./setup";
import { getTimestamp, matchEvent } from "./utils";

describe("Post", function () {
    it("User should create profile and then post note", async function () {
        const [owner, addr1] = await ethers.getSigners();

        const profileData = {
            to: addr1.address,
            handle: "new.handle",
            uri: "uri",
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
        };

        // create profile
        await expect(web3Entry.createProfile(profileData)).to.not.be.reverted;

        // post note
        const noteData = {
            profileId: 1,
            contentUri: "this is content",
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
            mintModule: ethers.constants.AddressZero,
            mintModuleInitData: [],
        };
        // await expect(web3Entry.postNote(noteData)).to.not.be.reverted;
        await web3Entry.connect(addr1).postNote(noteData);

        const bytes32Zero = "0x0000000000000000000000000000000000000000000000000000000000000000";

        const note = await web3Entry.getNote(noteData.profileId, 1);
        expect(note.linkItemType).to.equal(bytes32Zero);
        expect(note.linklistId).to.equal(0);
        expect(note.linkKey).to.equal(bytes32Zero);
        expect(note.contentUri).to.equal(noteData.contentUri);
        expect(note.linkModule).to.equal(ethers.constants.AddressZero);
        expect(note.mintModule).to.equal(ethers.constants.AddressZero);
        expect(note.mintNFT).to.equal(ethers.constants.AddressZero);
    });
});
