import {
    deployer,
    deployerAddress,
    FIRST_LINKLIST_ID,
    FIRST_CHARACTER_ID,
    FOLLOW_LINKTYPE,
    MOCK_CHARACTER_HANDLE,
    SECOND_CHARACTER_ID,
    user,
    userAddress,
    web3Entry,
} from "./setup.test";
import { getTimestamp, makeCharacterData, matchEvent } from "./helpers/utils";

describe("Character Events", function () {
    it("Should emit the new created character data once it's created", async function () {
        const characterData = makeCharacterData();

        const receipt = await (await web3Entry.createCharacter(characterData)).wait();

        matchEvent(receipt, "CharacterCreated", [
            FIRST_CHARACTER_ID,
            userAddress,
            userAddress,
            MOCK_CHARACTER_HANDLE,
            await getTimestamp(),
        ]);
    });

    it("Should emit the follow data once it's linked or unlinked", async function () {
        await web3Entry.createCharacter(makeCharacterData("handle1"));
        await web3Entry.createCharacter(makeCharacterData("handle2"));

        let receipt = await (
            await web3Entry.linkCharacter({
                fromCharacterId: FIRST_CHARACTER_ID,
                toCharacterId: SECOND_CHARACTER_ID,
                linkType: FOLLOW_LINKTYPE,
                data: [],
            })
        ).wait();

        matchEvent(receipt, "LinkCharacter", [
            userAddress,
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            FOLLOW_LINKTYPE,
            FIRST_LINKLIST_ID,
        ]);

        receipt = await (
            await web3Entry.unlinkCharacter({
                fromCharacterId: FIRST_CHARACTER_ID,
                toCharacterId: SECOND_CHARACTER_ID,
                linkType: FOLLOW_LINKTYPE,
            })
        ).wait();

        await web3Entry.unlinkCharacter({
            fromCharacterId: FIRST_CHARACTER_ID,
            toCharacterId: SECOND_CHARACTER_ID,
            linkType: FOLLOW_LINKTYPE,
        });

        matchEvent(receipt, "UnlinkCharacter", [
            userAddress,
            FIRST_CHARACTER_ID,
            SECOND_CHARACTER_ID,
            FOLLOW_LINKTYPE,
        ]);
    });
});
