import { BigNumber, BytesLike } from "ethers";

export interface CreateProfileData {
    to: string;
    handle: string;
    uri: string;
    linkModule: string;
    linkModuleInitData: BytesLike;
}

export interface ProfileData {
    profileId: BigNumber;
    handle: string;
    uri: string;
    noteCount: BigNumber;
    socialToken: string;
    linkModule: string;
}

export interface PostNoteData {
    profileId: BigNumber;
    contentUri: string;
    linkModule: string;
    linkModuleInitData: BytesLike;
    mintModule: string;
    mintModuleInitData: BytesLike;
    locked: boolean;
}

export interface NoteStruct {
    linkItemType: BytesLike;
    linkKey: BytesLike;
    contentUri: string;
    linkModule: string;
    mintModule: string;
    mintNFT: string;
    deleted: boolean;
    locked: boolean;
}
