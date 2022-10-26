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
        version: "0.8.10",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
    paths: {
        sources: "./contracts",
        cache: "./cache_hardhat",
        artifacts: "./artifacts_hardhat",
    },
    networks: {
        ropsten: {
            url: process.env.ROPSTEN_URL || "",
        },
        crossbell: {
            url: "https://rpc.crossbell.io",
        },
    },

    etherscan: {
        apiKey: {
            ropsten: process.env.ROPSTEN_API_KEY,
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
