import * as dotenv from "dotenv";

import fs from "fs"
import "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "hardhat-gas-reporter";
import "solidity-docgen";
import "hardhat-preprocessor";
import { HardhatUserConfig, task } from "hardhat/config"
import { chainConfig } from "@nomiclabs/hardhat-etherscan/dist/src/ChainConfig";
import { ChainConfig } from "@nomiclabs/hardhat-etherscan/dist/src/types";

dotenv.config();

function getRemappings() {
    return fs
        .readFileSync("remappings.txt", "utf8")
        .split("\n")
        .filter(Boolean) // remove empty lines
        .map((line) => line.trim().split("="));
}

// hack way to add network support of crossbell
(chainConfig as any).crossbell = {
    chainId: 3737,
    urls: {
        apiURL: "https://scan.crossbell.io/api",
        browserURL: "https://scan.crossbell.io",
    },
};

const config: HardhatUserConfig = {
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
        sources: "./src",
        cache: "./cache_hardhat", // Use a different cache for Hardhat than Foundry
    },
    preprocess: {
        eachLine: hre => ({
            transform: (line: string) => {
                if (line.match(/^\s*import /i)) {
                    getRemappings().forEach(([find, replace]) => {
                        if (line.match('"' + find)) {
                            line = line.replace('"' + find, '"' + replace)
                        }
                    })
                }
                return line
            },
        }),
    },

    networks: {
        crossbell: {
            url: "https://rpc.crossbell.io",
            accounts: [process.env.PRIVATE_KEY as string, process.env.PRIVATE_KEY2 as string],
        },
    },
    gasReporter: {
        enabled: process.env.REPORT_GAS !== undefined,
        currency: "USD",
    },
    etherscan: {
        apiKey: "api key",
    },
};

export default config
