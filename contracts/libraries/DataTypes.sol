// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library DataTypes {
    struct Profile {
        string handle;
        string metadataURI;
    }
    // profile => profile
    struct Profile2ProfileLink {
        uint256 fromProfileId;
        uint256 toProfileId;
        uint256 linkId;
    }
}
