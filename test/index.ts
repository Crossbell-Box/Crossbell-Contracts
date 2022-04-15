import { expect } from "chai";
import { ethers } from "hardhat";
import { web3Entry } from "./setup";
import { getTimestamp, matchEvent } from "./utils";
describe("Profile", function () {
    it("Should emit the new created profile data once it's created", async function () {
        const [deployer, addr1] = await ethers.getSigners();

        const profileData = {
            to: await addr1.getAddress(),
            handle: "newHandle",
            uri: "uri",
            linkModule: ethers.constants.AddressZero,
            linkModuleInitData: [],
        };

        const receipt = await (await web3Entry.createProfile(profileData)).wait();

        matchEvent(receipt, "ProfileCreated", [
            1,
            deployer.address,
            profileData.to,
            profileData.handle,
            await getTimestamp(),
        ]);

        const profile = await web3Entry.getProfileByHandle("newHandle");

        expect(profile.handle).to.equal(profileData.handle);
        expect(profile.uri).to.equal(profileData.uri);
    });
});
