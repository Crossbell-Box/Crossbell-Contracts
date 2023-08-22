// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

/// @dev Character ID not exists
error ErrCharacterNotExists(uint256 characterId);

/// @dev Not owner of address
error ErrNotAddressOwner();

/// @dev Caller is not the owner of character
error ErrNotCharacterOwner();

/// @dev Note has been locked
error ErrNoteLocked();

/// @dev Handle does not exist
error ErrHandleExists();

/// @dev Social token address does not exist
error ErrSocialTokenExists();

/// @dev Handle length too long or too short
error ErrHandleLengthInvalid();

/// @dev Handle contains invalid characters
error ErrHandleContainsInvalidCharacters();

/// @dev  Operator has not enough permission for this character
error ErrNotEnoughPermission();

/// @dev Operator has not enough permissions for this note
error ErrNotEnoughPermissionForThisNote();

/// @dev Target address already has primary character
error ErrTargetAlreadyHasPrimaryCharacter();

/// @dev Note has been deleted
error ErrNoteIsDeleted();

/// @dev Note does not exist
error ErrNoteNotExists();

/// @dev Array length mismatch
error ErrArrayLengthMismatch();

/// @dev Caller is not web3Entry contract
error ErrCallerNotWeb3Entry();

/// @dev Caller is not web3Entry contract, and not the owner of character
error ErrCallerNotWeb3EntryOrNotOwner();

/// @dev Token id already exists
error ErrTokenIdAlreadyExists();

/// @dev Character does not exist
error ErrNotExistingCharacter();

/// @dev Token id of linklist does not exist
error ErrNotExistingLinklistToken();

/// @dev Invalid web3Entry address
error ErrInvalidWeb3Entry();

/// @dev Not approved by module or exceed the approval amount
error ErrNotApprovedOrExceedApproval();

/// @dev Exceed max supply
error ErrExceedMaxSupply();

/// @dev Exceed the approval amount
error ErrExceedApproval();

/// @dev Signature is expired
error ErrSignatureExpired();

/// @dev Signature is invalid
error ErrSignatureInvalid();

/// @dev Caller not owner
error ErrNotOwner();

/// @dev Token not exists
error ErrTokenNotExists();
