import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";
import "solidity-docgen";
import * as dotenv from "dotenv";

dotenv.config();

module.exports = {
    solidity: {
        version: "0.8.16",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    docgen: {
        output: "docs",
        pages: "files",
    },
    paths: {
        sources: "./contracts",
        cache: "./cache",
        artifacts: "./artifacts",
    },
    networks: {
        crossbell: {
            url: "https://rpc.crossbell.io",
            // accounts: [process.env.PRIVATE_KEY]
        },
    },

    etherscan: {
        apiKey: {
            crossbell: "your API key",
        },
        customChains: [
            {
                network: "crossbell",
                chainId: 3737,
                urls: {
                    apiURL: "https://scan.crossbell.io/api",
                    browserURL: "https://scan.crossbell.io",
                },
            },
        ],
    },
} as HardhatUserConfig;
