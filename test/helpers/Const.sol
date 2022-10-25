// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library Const {
    uint256 constant FIRST_CHARACTER_ID = 1;
    uint256 constant SECOND_CHARACTER_ID = 2;
    uint256 constant THIRD_CHARACTER_ID = 3;

    uint256 constant FIRST_LINKLIST_ID = 1;
    uint256 constant SECOND_LINKLIST_ID = 2;

    uint256 constant FIRST_NOTE_ID = 1;
    uint256 constant SECOND_NOTE_ID = 2;

    uint256 constant FIRST_CBT_ID = 1;
    uint256 constant SECOND_CBT_ID = 2;
    uint256 constant ZERO_CBT_ID = 0;

    address constant AddressZero = address(0);

    string constant WEB3_ENTRY_NFT_NAME = "Web3 Entry Character";
    string constant WEB3_ENTRY_NFT_SYMBOL = "WEC";
    string constant LINK_LIST_NFT_NAME = "Link List Token";
    string constant LINK_LIST_NFT_SYMBOL = "LLT";

    string constant MOCK_CHARACTER_HANDLE = "0xcrossbell-eth";
    string constant MOCK_CHARACTER_HANDLE2 = "0xcrossbell-2-eth";
    string constant MOCK_CHARACTER_HANDLE3 = "0xcrossbell-3-eth";
    string constant MOCK_CHARACTER_HANDLE4 = "0xcrossbell-4-eth";
    string constant MOCK_CHARACTER_URI =
        "https://raw.githubusercontent.com/Crossbell-Box/Crossbell-Contracts/main/examples/sampleProfile.json";
    string constant MOCK_URI = "ipfs://QmadFPhP7n5rJkACMY6QqhtLtKgX1ixoySmxQNrU4Wo5JW";
    string constant MOCK_CONTENT_URI = "ipfs://QmfHKajYAGcaWaBXGsEWory9ensGsesN2GwWedVEuzk5Gg";
    string constant MOCK_NOTE_URI =
        "https://github.com/Crossbell-Box/Crossbell-Contracts/blob/main/examples/sampleContent.json";
    string constant MOCK_NEW_NOTE_URI =
        "https://github.com/Crossbell-Box/Crossbell-Contracts/blob/main/examples/sampleContent-new.json";
    string constant MOCK_TOKEN_URI = "http://ipfs/xxx1.json";
    string constant MOCK_NEW_TOKEN_URI = "http://ipfs/xxx2.json";

    bytes32 constant bytes32Zero = bytes32(0);

    bytes32 constant FollowLinkType = bytes32(bytes("follow"));
    bytes32 constant LikeLinkType = bytes32(bytes("like"));

    bytes32 constant LinkItemTypeCharacter =
        0x4368617261637465720000000000000000000000000000000000000000000000;
    bytes32 constant LinkItemTypeAddress =
        0x4164647265737300000000000000000000000000000000000000000000000000;
    bytes32 constant LinkItemTypeNote =
        0x4e6f746500000000000000000000000000000000000000000000000000000000;
    bytes32 constant LinkItemTypeERC721 =
        0x4552433732310000000000000000000000000000000000000000000000000000;
    bytes32 constant LinkItemTypeLinklist =
        0x4c696e6b6c697374000000000000000000000000000000000000000000000000;
    bytes32 constant LinkItemTypeAnyUri =
        0x416e795572690000000000000000000000000000000000000000000000000000;

    uint256 constant PrivateKey0x1 =
        0x0000000000000000000000000000000000000000000000000000000000000001;
}
