import {
    deployer,
    deployerAddress,
    FIRST_LINKLIST_ID,
    FIRST_PROFILE_ID,
    FOLLOW_LINKTYPE,
    MOCK_PROFILE_HANDLE,
    SECOND_PROFILE_ID,
    user,
    userAddress,
    web3Entry,
} from "./setup.test";
import { getTimestamp, makeProfileData, matchEvent } from "./helpers/utils";

describe("Profile Events", function () {
    it("Should emit the new created profile data once it's created", async function () {
        const profileData = makeProfileData();

        const receipt = await (await web3Entry.createProfile(profileData)).wait();

        matchEvent(receipt, "ProfileCreated", [
            FIRST_PROFILE_ID,
            userAddress,
            userAddress,
            MOCK_PROFILE_HANDLE,
            await getTimestamp(),
        ]);
    });

    it("Should emit the follow data once it's linked or unlinked", async function () {
        await web3Entry.createProfile(makeProfileData("handle1"));
        await web3Entry.createProfile(makeProfileData("handle2"));

<<<<<<< HEAD
        let receipt = await (
            await web3Entry.linkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, FOLLOW_LINKTYPE)
        ).wait();
=======
        // let receipt = await (
        await web3Entry.linkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, FOLLOW_LINKTYPE);
        // ).wait();
>>>>>>> 1693f0c1055fb1cde27eebaeea48d4c4f7194420

        matchEvent(receipt, "LinkProfile", [
            userAddress,
            FIRST_PROFILE_ID,
            SECOND_PROFILE_ID,
            FOLLOW_LINKTYPE,
            FIRST_LINKLIST_ID,
        ]);

        receipt = await (
            await web3Entry
                .connect(user)
                .unlinkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, FOLLOW_LINKTYPE)
        ).wait();

        await web3Entry.unlinkProfile(FIRST_PROFILE_ID, SECOND_PROFILE_ID, FOLLOW_LINKTYPE);

        matchEvent(receipt, "UnlinkProfile", [
            userAddress,
            FIRST_PROFILE_ID,
            SECOND_PROFILE_ID,
            FOLLOW_LINKTYPE,
        ]);
    });
});
