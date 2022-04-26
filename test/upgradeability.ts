import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import

import {
    // eslint-disable-next-line camelcase
    TransparentUpgradeableProxy__factory,
    MockWeb3EntryV2__factory,
    Web3Entry__factory,
    // eslint-disable-next-line node/no-missing-import
} from "../typechain";

import {
    abiCoder,
    makeSuiteCleanRoom,
    deployer,
    user,
    admin,
    web3Entry,
    // eslint-disable-next-line node/no-missing-import
} from "./setup.test";

makeSuiteCleanRoom("Upgradeability", function () {
    it("Should upgrade and set a new variable, previous storage is unchanged, nad new value is accurate", async function () {
        const valueToSet = 123;

        const NewWeb3Entry = await ethers.getContractFactory("MockWeb3EntryV2");
        const newWeb3EntryImpl = await NewWeb3Entry.deploy();
        await newWeb3EntryImpl.deployed();

        const proxyWeb3Entry = TransparentUpgradeableProxy__factory.connect(
            web3Entry.address,
            deployer
        );

        let prevStorage: string[] = [];
        for (let i = 0; i < 21; i++) {
            const valueAt = await ethers.provider.getStorageAt(proxyWeb3Entry.address, i);
            prevStorage.push(valueAt);
        }

        let prevNextSlot = await ethers.provider.getStorageAt(proxyWeb3Entry.address, 21);
        const formattedZero = abiCoder.encode(["uint256"], [0]);
        expect(prevNextSlot).to.eq(formattedZero);

        await proxyWeb3Entry.connect(admin).upgradeTo(newWeb3EntryImpl.address);
        await expect(
            MockWeb3EntryV2__factory.connect(proxyWeb3Entry.address, user).setAdditionalValue(
                valueToSet
            )
        ).to.not.be.reverted;

        for (let i = 0; i < 21; i++) {
            const valueAt = await ethers.provider.getStorageAt(proxyWeb3Entry.address, i);
            expect(valueAt).to.eq(prevStorage[i]);
        }

        const newNextSlot = await ethers.provider.getStorageAt(proxyWeb3Entry.address, 21);
        const formattedValue = abiCoder.encode(["uint256"], [valueToSet]);
        expect(newNextSlot).to.eq(formattedValue);
    });
});
