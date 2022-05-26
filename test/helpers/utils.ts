import "@nomiclabs/hardhat-ethers";
import { BigNumberish, Bytes, logger, utils, BigNumber, Contract } from "ethers";

// eslint-disable-next-line node/no-missing-import
import {
    eventsLib,
    FIRST_PROFILE_ID,
    MOCK_NOTE_URI,
    MOCK_PROFILE_HANDLE,
    MOCK_PROFILE_URI,
    periphery,
    userAddress,
    web3Entry,
} from "../setup.test";
import { expect } from "chai";
// import { HARDHAT_CHAINID, MAX_UINT256 } from './constants';
import { BytesLike, hexlify, keccak256, RLP, toUtf8Bytes } from "ethers/lib/utils";
// import { LensHub__factory } from '../../typechain-types';
import { TransactionReceipt, TransactionResponse } from "@ethersproject/providers";
import hre, { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { CreateProfileData, PostNoteData, NoteStruct } from "./types";
export const makeProfileData = (handle: string = MOCK_PROFILE_HANDLE, to: string = userAddress) => {
    return {
        to,
        handle,
        uri: MOCK_PROFILE_URI,
        linkModule: ethers.constants.AddressZero,
        linkModuleInitData: [],
    } as CreateProfileData;
};

export const makePostNoteData = (num: string = "1") => {
    return {
        profileId: BigNumber.from(num),
        contentUri: MOCK_NOTE_URI,
        linkModule: ethers.constants.AddressZero,
        linkModuleInitData: [],
        mintModule: ethers.constants.AddressZero,
        mintModuleInitData: [],
        freeze: false,
    } as PostNoteData;
};

let snapshotId: string = "0x1";
export async function takeSnapshot() {
    snapshotId = await hre.ethers.provider.send("evm_snapshot", []);
}

export async function revertToSnapshot() {
    await hre.ethers.provider.send("evm_revert", [snapshotId]);
}

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
                                logger.info("The " + i + " th param:");
                                logger.info("Received: " + event.args[i]);
                                logger.info("Expected: " + expectedArgs[i]);
                                invalidParamsButExists = true;
                                break;
                            }
                        } else if (event.args[i].constructor == Array) {
                            let params = event.args[i];
                            let expected = expectedArgs[i];
                            for (let j = 0; j < params.length; j++) {
                                if (BigNumber.isBigNumber(params[j])) {
                                    if (!params[j].eq(BigNumber.from(expected[j]))) {
                                        logger.info("The " + i + " th param:");
                                        logger.info("Received: " + params[i]);
                                        logger.info("Expected: " + expected[i]);
                                        invalidParamsButExists = true;
                                        break;
                                    }
                                } else if (params[j] != expected[j]) {
                                    logger.info("The " + i + " th param:");
                                    logger.info("Received: " + params[i]);
                                    logger.info("Expected: " + expected[i]);
                                    invalidParamsButExists = true;
                                    break;
                                }
                            }
                            if (invalidParamsButExists) break;
                        } else if (event.args[i] != expectedArgs[i]) {
                            logger.info("The " + i + " th param:");
                            logger.info("Received: " + event.args[i]);
                            logger.info("Expected: " + expectedArgs[i]);
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

export function matchNote(note: NoteStruct, expectedArgs?: any[]) {
    if (expectedArgs) {
        if (expectedArgs.length != 8) {
            logger.throwError(`Note expected args are of invalid length`);
        }
        if (note.linkItemType !== expectedArgs[0]) {
            logger.throwError(
                `linkItemType, Received: "${note.linkItemType}" Expected: "${expectedArgs[0]}`
            );
        }
        if (note.linkKey !== expectedArgs[1]) {
            logger.throwError(`linkKey, Received: "${note.linkKey}" Expected: "${expectedArgs[1]}`);
        }
        if (note.contentUri !== expectedArgs[2]) {
            logger.throwError(
                `contentUri, Received: "${note.contentUri}" Expected: "${expectedArgs[2]}`
            );
        }
        if (note.linkModule !== expectedArgs[3]) {
            logger.throwError(
                `linkModule, Received: "${note.linkModule}" Expected: "${expectedArgs[3]}`
            );
        }
        if (note.mintModule !== expectedArgs[4]) {
            logger.throwError(
                `mintModule, Received: "${note.mintModule}" Expected: "${expectedArgs[4]}`
            );
        }
        if (note.mintNFT !== expectedArgs[5]) {
            logger.throwError(`mintNFT, Received: "${note.mintNFT}" Expected: "${expectedArgs[5]}`);
        }
        if (note.deleted !== expectedArgs[6]) {
            logger.throwError(`deleted, Received: "${note.deleted}" Expected: "${expectedArgs[6]}`);
        }
        if (note.frozen !== expectedArgs[7]) {
            logger.throwError(`frozen, Received: "${note.frozen}" Expected: "${expectedArgs[7]}`);
        }
    }
}

export async function matchLinkingProfileIds(
    fromProfileId: BigNumberish,
    linkType: BytesLike,
    expectedArgs: number[]
) {
    const linkingProfileIds = await periphery.getLinkingProfileIds(fromProfileId, linkType);
    if (linkingProfileIds.length !== expectedArgs.length) {
        logger.throwError(`linkingProfileIds mismatched. Expected args are of invalid length`);
    }
    for (let i = 0; i < linkingProfileIds.length; i++) {
        expect(linkingProfileIds[i]).to.eq(expectedArgs[i]);
    }
}
