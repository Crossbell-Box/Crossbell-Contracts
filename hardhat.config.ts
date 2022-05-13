import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";
import "solidity-coverage";
import { chainConfig } from "@nomiclabs/hardhat-etherscan/dist/src/ChainConfig";
import { ChainConfig } from "@nomiclabs/hardhat-etherscan/dist/src/types";

dotenv.config();

// hack way to add network support of crossbell
(chainConfig as any).crossbell = {
    chainId: 3737,
    urls: {
        apiURL: "https://scan.crossbell.io/api",
        browserURL: "https://scan.crossbell.io",
    },
};

type CsbEtherscanApiKeys = {
    [P in keyof Required<ChainConfig> & {
        crossbell: string;
    }]: string;
};

interface CsbHardhatUserConfig extends HardhatUserConfig {
    etherscan: CsbEtherscanApiKeys | undefined;
}

const config: CsbHardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: "0.8.10",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                        details: {
                            yul: true,
                        },
                    },
                },
            },
        ],
    },
    networks: {
        ropsten: {
            url: process.env.ROPSTEN_URL || "",
            accounts: [process.env.PRIVATE_KEY as string, process.env.PRIVATE_KEY2 as string],
        },
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
        apiKey: {
            crossbell: "api key",
            ropsten: process.env.ROPSTEN_API_KEY,
        },
    },
};

export default config;
