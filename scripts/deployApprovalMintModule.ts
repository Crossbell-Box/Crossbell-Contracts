// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from 'hardhat';

async function main() {
    const proxyWeb3Entry = '0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8';

    const ApprovalMintModule = await ethers.getContractFactory('ApprovalMintModule');
    const approvalMintModule = await ApprovalMintModule.deploy(proxyWeb3Entry);

    console.log('approvalMintModule deployed to:', approvalMintModule.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
