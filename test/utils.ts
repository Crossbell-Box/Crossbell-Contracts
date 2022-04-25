import "@nomiclabs/hardhat-ethers";
import { BigNumberish, Bytes, logger, utils, BigNumber, Contract } from "ethers";
// import {
//   eventsLib,
//   helper,
//   lensHub,
//   LENS_HUB_NFT_NAME,
//   peripheryDataProvider,
//   PERIPHERY_DATA_PROVIDER_NAME,
//   testWallet,
// } from '../__setup.spec';
import { eventsLib } from "./setup";
import { expect } from "chai";
// import { HARDHAT_CHAINID, MAX_UINT256 } from './constants';
import { hexlify, keccak256, RLP, toUtf8Bytes } from "ethers/lib/utils";
// import { LensHub__factory } from '../../typechain-types';
import { TransactionReceipt, TransactionResponse } from "@ethersproject/providers";
import hre, { ethers } from "hardhat";

export function matchEvent(
    receipt: TransactionReceipt,
    name: string,
    expectedArgs?: any[],
    eventContract: Contract = eventsLib,
    emitterAddress?: string
) {
    const events = receipt.logs;

    if (events != undefined) {
        // match name from list of events in eventContract, when found, compute the sigHash
        let sigHash: string | undefined;
        for (let contractEvent of Object.keys(eventContract.interface.events)) {
            if (contractEvent.startsWith(name) && contractEvent.charAt(name.length) == "(") {
                sigHash = keccak256(toUtf8Bytes(contractEvent));
                break;
            }
        }
        // Throw if the sigHash was not found
        if (!sigHash) {
            logger.throwError(
                `Event "${name}" not found in provided contract (default: Events libary). \nAre you sure you're using the right contract?`
            );
        }

        // Find the given event in the emitted logs
        let invalidParamsButExists = false;
        for (let emittedEvent of events) {
            // If we find one with the correct sighash, check if it is the one we're looking for
            if (emittedEvent.topics[0] == sigHash) {
                // If an emitter address is passed, validate that this is indeed the correct emitter, if not, continue
                if (emitterAddress) {
                    if (emittedEvent.address != emitterAddress) continue;
                }
                const event = eventContract.interface.parseLog(emittedEvent);
                // If there are expected arguments, validate them, otherwise, return here
                if (expectedArgs) {
                    if (expectedArgs.length != event.args.length) {
                        logger.throwError(
                            `Event "${name}" emitted with correct signature, but expected args are of invalid length`
                        );
                    }
                    invalidParamsButExists = false;
                    // Iterate through arguments and check them, if there is a mismatch, continue with the loop
                    for (let i = 0; i < expectedArgs.length; i++) {
                        // Parse empty arrays as empty bytes
                        if (expectedArgs[i].constructor == Array && expectedArgs[i].length == 0) {
                            expectedArgs[i] = "0x";
                        }

                        // Break out of the expected args loop if there is a mismatch, this will continue the emitted event loop
                        if (BigNumber.isBigNumber(event.args[i])) {
                            if (!event.args[i].eq(BigNumber.from(expectedArgs[i]))) {
                                invalidParamsButExists = true;
                                break;
                            }
                        } else if (event.args[i].constructor == Array) {
                            let params = event.args[i];
                            let expected = expectedArgs[i];
                            for (let j = 0; j < params.length; j++) {
                                if (BigNumber.isBigNumber(params[j])) {
                                    if (!params[j].eq(BigNumber.from(expected[j]))) {
                                        invalidParamsButExists = true;
                                        break;
                                    }
                                } else if (params[j] != expected[j]) {
                                    invalidParamsButExists = true;
                                    break;
                                }
                            }
                            if (invalidParamsButExists) break;
                        } else if (event.args[i] != expectedArgs[i]) {
                            invalidParamsButExists = true;
                            break;
                        }
                    }
                    // Return if the for loop did not cause a break, so a match has been found, otherwise proceed with the event loop
                    if (!invalidParamsButExists) {
                        return;
                    }
                } else {
                    return;
                }
            }
        }
        // Throw if the event args were not expected or the event was not found in the logs
        if (invalidParamsButExists) {
            logger.throwError(`Event "${name}" found in logs but with unexpected args`);
        } else {
            logger.throwError(
                `Event "${name}" not found emitted by "${emitterAddress}" in given transaction log`
            );
        }
    } else {
        logger.throwError("No events were emitted");
    }
}

export async function getTimestamp(): Promise<any> {
    const blockNumber = await hre.ethers.provider.send("eth_blockNumber", []);
    const block = await hre.ethers.provider.send("eth_getBlockByNumber", [blockNumber, false]);
    return block.timestamp;
}

let snapshotId: string = "0x1";
export async function takeSnapshot() {
    snapshotId = await hre.ethers.provider.send("evm_snapshot", []);
}

export async function revertToSnapshot() {
    await hre.ethers.provider.send("evm_revert", [snapshotId]);
}
