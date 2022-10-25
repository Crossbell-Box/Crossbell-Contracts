import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { NewbieVilla, NFT } from "../../typechain";

export const FIRST_CHARACTER_ID = 1;
export const SECOND_CHARACTER_ID = 2;
export const THIRD_CHARACTER_ID = 3;

let newbieVilla: NewbieVilla;
let mockNft: NFT;
let owner: SignerWithAddress;
let receiver: SignerWithAddress;

let nonce: number;
let expires: number;
let proof: string;

beforeEach(async () => {
    [owner, receiver] = await ethers.getSigners();
    const NewbieVilla = await ethers.getContractFactory("NewbieVilla");
    newbieVilla = await NewbieVilla.deploy();
    mockNft = await (await ethers.getContractFactory("NFT")).deploy();
    await newbieVilla.connect(owner).initialize(mockNft.address);
    // mockNft doesn't implement "setOperator", but here's not safeTransfer
    // so the onERC721Received will not be triggered
    await mockNft.connect(owner).mint(newbieVilla.address);

    nonce = 0x77c614;
    expires = Math.floor((Date.now() + 1000 * 60) / 1000);
    const digest = ethers.utils.arrayify(
        ethers.utils.solidityKeccak256(
            ["address", "uint256", "uint256", "uint256"],
            [newbieVilla.address, FIRST_CHARACTER_ID, nonce, expires]
        )
    );
    proof = await owner.signMessage(digest);
});

describe("NewbieVilla contract", function () {
    it("Admin should be able to transfer the newbie out", async function () {
        expect(await mockNft.balanceOf(receiver.address)).to.be.eq(0);
        await newbieVilla
            .connect(receiver)
            .withdraw(receiver.address, FIRST_CHARACTER_ID, nonce, expires, proof);

        expect(await mockNft.balanceOf(receiver.address)).to.be.eq(1);
    });

    it("Double withdraw will fail", async function () {
        await newbieVilla
            .connect(receiver)
            .withdraw(receiver.address, FIRST_CHARACTER_ID, nonce, expires, proof);
        try {
            await newbieVilla
                .connect(receiver)
                .withdraw(receiver.address, FIRST_CHARACTER_ID, nonce, expires, proof);
        } catch (e) {
            expect(true);
        }
    });
});
