// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

library Constants {
    string internal constant PROPOSAL_STATUS_PENDING = "Pending";
    string internal constant PROPOSAL_STATUS_DELETED = "Deleted";
    string internal constant PROPOSAL_STATUS_EXECUTED = "Executed";
    address internal constant SENTINEL_OWNER = address(0x1);
    string internal constant PROPOSAL_TYPE_UPGRADE = "Upgrade";
    string internal constant PROPOSAL_TYPE_CHANGE_ADMIN = "ChangeAdmin";
}