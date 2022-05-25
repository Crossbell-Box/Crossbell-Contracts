import {
    deployer,
    deployerAddress,
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID,
    FOLLOW_LINKTYPE,
    MOCK_NOTE_URI,
    MOCK_PROFILE_HANDLE,
    MOCK_PROFILE_URI,
    periphery,
    resolver,
    SECOND_PROFILE_ID,
    user,
    userAddress,
    userThree,
    userThreeAddress,
    userTwo,
    userTwoAddress,
    web3Entry,
} from "./setup.test";
import { getTimestamp, makeProfileData, matchEvent } from "./helpers/utils";
import { ethers } from "hardhat";
import { BytesLike } from "@ethersproject/bytes";
import { expect } from "chai";

describe("Resolver", function () {
    it("Admin should add ENS and delete ENS", async function () {
        await resolver.addENSRecords(
            ["vitalik", "atlas", "albert"],
            [userTwoAddress, userThreeAddress, userThreeAddress]
        );
        expect(await resolver.getTotalENSCount()).to.be.equal(3);
        expect(await resolver.getTotalRNSCount()).to.be.equal(0);

        await resolver.deleteENSRecords(["vitalik", "albert"]);
        expect(await resolver.getTotalENSCount()).to.be.equal(1);
        expect(await resolver.getTotalRNSCount()).to.be.equal(0);
    });

    it("Admin should add RNS and delete RNS", async function () {
        await resolver.addRNSRecords(
            ["vitalik", "atlas", "albert"],
            [userTwoAddress, userThreeAddress, userThreeAddress]
        );
        expect(await resolver.getTotalRNSCount()).to.be.equal(3);
        expect(await resolver.getTotalENSCount()).to.be.equal(0);

        await resolver.deleteRNSRecords(["vitalik", "albert"]);
        expect(await resolver.getTotalRNSCount()).to.be.equal(1);
        expect(await resolver.getTotalENSCount()).to.be.equal(0);
    });

    it("Admin should add RNS and ENS and delete", async function () {
        await resolver.addRNSRecords(
            ["vitalik", "atlas", "albert"],
            [userTwoAddress, userThreeAddress, userThreeAddress]
        );
        await resolver.addENSRecords(
            ["vitalik", "atlas", "albert"],
            [userTwoAddress, userThreeAddress, userThreeAddress]
        );
        expect(await resolver.getTotalRNSCount()).to.be.equal(3);
        expect(await resolver.getTotalENSCount()).to.be.equal(3);

        await resolver.deleteRNSRecords(["albert"]);
        expect(await resolver.getTotalRNSCount()).to.be.equal(2);
        await resolver.deleteENSRecords(["vitalik"]);
        expect(await resolver.getTotalENSCount()).to.be.equal(2);

        await resolver.deleteENSRecords(["atlas", "albert"]);
        expect(await resolver.getTotalENSCount()).to.be.equal(0);
        expect(await resolver.getTotalRNSCount()).to.be.equal(2);
    });

    it("User should failed to create profile reserved for ENS", async function () {
        await resolver.addENSRecords(
            ["vitalik", "atlas", "albert"],
            [userTwoAddress, userThreeAddress, userThreeAddress]
        );

        await expect(
            web3Entry.connect(user).createProfile(makeProfileData("vitalik"))
        ).to.be.revertedWith("HandleNotEligible");
        await expect(
            web3Entry.connect(user).createProfile(makeProfileData("atlas"))
        ).to.be.revertedWith("HandleNotEligible");
        await expect(
            web3Entry.connect(user).createProfile(makeProfileData("albert"))
        ).to.be.revertedWith("HandleNotEligible");
    });

    it("User should failed to create profile reserved for RNS", async function () {
        await resolver.addRNSRecords(
            ["vitalik", "atlas", "albert"],
            [userTwoAddress, userThreeAddress, userThreeAddress]
        );

        await expect(
            web3Entry.connect(user).createProfile(makeProfileData("vitalik"))
        ).to.be.revertedWith("HandleNotEligible");
        await expect(
            web3Entry.connect(user).createProfile(makeProfileData("atlas"))
        ).to.be.revertedWith("HandleNotEligible");
        await expect(
            web3Entry.connect(user).createProfile(makeProfileData("albert"))
        ).to.be.revertedWith("HandleNotEligible");
    });

    it("User should create profile reserved for ENS or RNS", async function () {
        await resolver.addRNSRecords(
            ["vitalik", "atlas", "albert"],
            [userTwoAddress, userTwoAddress, userThreeAddress]
        );

        await resolver.addENSRecords(
            ["vitalik", "atlas", "albert"],
            [userThreeAddress, userTwoAddress, userTwoAddress]
        );

        await expect(web3Entry.createProfile(makeProfileData("albert", userThreeAddress))).to.not.be
            .reverted;
        await expect(web3Entry.createProfile(makeProfileData("vitalik", userThreeAddress))).to.not
            .be.reverted;
    });
});
