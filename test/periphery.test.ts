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
    SECOND_PROFILE_ID,
    user,
    userAddress,
    web3Entry,
} from "./setup.test";
import { getTimestamp, makeProfileData, matchEvent } from "./helpers/utils";
import { ethers } from "hardhat";
import { BytesLike } from "@ethersproject/bytes";

describe("Periphery", function () {
    it("User should create profile and then post note", async function () {
        await periphery.createProfileThenPostNote({
            handle: MOCK_PROFILE_HANDLE,
            uri: MOCK_PROFILE_URI,
            profileLinkModule: ethers.constants.AddressZero,
            profileLinkModuleInitData: [],
            contentUri: ethers.constants.AddressZero,
            noteLinkModule: ethers.constants.AddressZero,
            noteLinkModuleInitData: [],
            mintModule: ethers.constants.AddressZero,
            mintModuleInitData: [],
        });
    });
});
