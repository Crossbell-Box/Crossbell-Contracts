// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library Const {
    /* solhint-disable comprehensive-interface */
    uint256 public constant FIRST_CHARACTER_ID = 1;
    uint256 public constant SECOND_CHARACTER_ID = 2;
    uint256 public constant THIRD_CHARACTER_ID = 3;
    uint256 public constant FOURTH_CHARACTER_ID = 4;

    uint256 public constant FIRST_LINKLIST_ID = 1;
    uint256 public constant SECOND_LINKLIST_ID = 2;

    uint256 public constant FIRST_NOTE_ID = 1;
    uint256 public constant SECOND_NOTE_ID = 2;

    uint256 public constant FIRST_CBT_ID = 1;
    uint256 public constant SECOND_CBT_ID = 2;
    uint256 public constant ZERO_CBT_ID = 0;

    uint256 public constant MOCK_FIRST_TOKEN_ID = 0;
    uint256 public constant MOCK_SECOND_TOKEN_ID = 1;

    address public constant AddressZero = address(0);
    address public constant MOCK_TO_ADDRESS = address(0x05004003);

    string public constant WEB3_ENTRY_NFT_NAME = "Web3 Entry Character";
    string public constant WEB3_ENTRY_NFT_SYMBOL = "WEC";
    string public constant LINK_LIST_NFT_NAME = "Link List Token";
    string public constant LINK_LIST_NFT_SYMBOL = "LLT";

    string public constant MOCK_CHARACTER_HANDLE = "0xcrossbell-eth";
    string public constant MOCK_CHARACTER_HANDLE2 = "0xcrossbell-2-eth";
    string public constant MOCK_CHARACTER_HANDLE3 = "0xcrossbell-3-eth";
    string public constant MOCK_CHARACTER_HANDLE4 = "0xcrossbell-4-eth";
    string public constant MOCK_CHARACTER_URI =
        "https://raw.githubusercontent.com/Crossbell-Box/Crossbell-Contracts/main/examples/sampleProfile.json";
    string public constant MOCK_URI = "ipfs://QmadFPhP7n5rJkACMY6QqhtLtKgX1ixoySmxQNrU4Wo5JW";
    string public constant MOCK_CONTENT_URI =
        "ipfs://QmfHKajYAGcaWaBXGsEWory9ensGsesN2GwWedVEuzk5Gg";
    string public constant MOCK_NOTE_URI =
        "https://github.com/Crossbell-Box/Crossbell-Contracts/blob/main/examples/sampleContent.json";
    string public constant MOCK_NEW_NOTE_URI =
        "https://github.com/Crossbell-Box/Crossbell-Contracts/blob/main/examples/sampleContent-new.json";
    string public constant MOCK_TOKEN_URI = "http://ipfs/xxx1.json";
    string public constant MOCK_NEW_TOKEN_URI = "http://ipfs/xxx2.json";

    bytes32 public constant bytes32Zero = bytes32(0);

    bytes32 public constant FollowLinkType = bytes32(bytes("follow"));
    bytes32 public constant LikeLinkType = bytes32(bytes("like"));

    bytes32 public constant LinkItemTypeCharacter =
        0x4368617261637465720000000000000000000000000000000000000000000000;
    bytes32 public constant LinkItemTypeAddress =
        0x4164647265737300000000000000000000000000000000000000000000000000;
    bytes32 public constant LinkItemTypeNote =
        0x4e6f746500000000000000000000000000000000000000000000000000000000;
    bytes32 public constant LinkItemTypeERC721 =
        0x4552433732310000000000000000000000000000000000000000000000000000;
    bytes32 public constant LinkItemTypeLinklist =
        0x4c696e6b6c697374000000000000000000000000000000000000000000000000;
    bytes32 public constant LinkItemTypeAnyUri =
        0x416e795572690000000000000000000000000000000000000000000000000000;

    uint256 public constant PrivateKey0x1 =
        0x0000000000000000000000000000000000000000000000000000000000000001;
}
