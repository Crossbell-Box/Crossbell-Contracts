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
