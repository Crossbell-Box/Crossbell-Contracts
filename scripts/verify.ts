import hre, { ethers } from "hardhat";

async function main() {
    const mintNFTAddress = "0x142E361aBc1b641864afd2819398Aa9DF3e6B686";
    const web3EntryAddress = "0x6Be7539Bd64d7533d474d3fd0522b311a1f11407";
    const linklistAddress = "0xa33769B1cDf6d1fee223c778A34D61593143f8F7";
    const linkModuleLogicAddress = "0x315f6A340441878A09692d0D59CeE826ff57CDBb";
    const characterLogicAddress = "0x052d90ee63B6F270223fC1DBA9967E4E5c780909";
    const postLogicAddress = "0xb001f4e804268325a0c78100ab8dc85becf240b1";
    const web3EntryCharacterAddress = "0xa6f969045641Cf486a747A2688F3a5A6d43cd0D8";
    const linklistTokenAddress = "0xFc8C75bD5c26F50798758f387B698f207a016b6A";
    const admin = "0xE01c8D2Abc0f6680cB3eaBD8a77A616Bc5e085f7";

    const contracts = {
        mintNFT: {
            address: mintNFTAddress,
        },
        linklist: {
            address: linklistAddress,
        },
        linkModuleLogic: {
            address: linkModuleLogicAddress,
        },
        characterLogic: {
            address: characterLogicAddress,
        },
        postLogic: {
            address: postLogicAddress,
        },
        web3Entry: {
            address: web3EntryAddress,
            libraries: {
                LinkModuleLogic: linkModuleLogicAddress,
                CharacterLogic: characterLogicAddress,
                PostLogic: postLogicAddress,
            },
        },
        web3EntryCharacter: {
            address: web3EntryCharacterAddress,
            constructorArguments: [web3EntryAddress, admin, "0x"],
        },
        linklistToken: {
            address: linklistTokenAddress,
            constructorArguments: [linklistAddress, admin, "0x"],
        },
    };

    for (const [c, args] of Object.entries(contracts)) {
        try {
            await hre.run("verify:verify", args);
        } catch (e: any) {
            console.log("Error in verification: ", e.message);
        }
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
