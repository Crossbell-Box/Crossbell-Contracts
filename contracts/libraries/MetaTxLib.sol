// SPDX-License-Identifier: MIT
// solhint-disable private-vars-leading-underscore
pragma solidity 0.8.18;

import {StorageLib} from "./StorageLib.sol";
import {DataTypes} from "./DataTypes.sol";
import {ErrSignatureInvalid, ErrSignatureExpired} from "./Error.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

library MetaTxLib {
    // solhint-disable-next-line private-vars-leading-underscore, var-name-mixedcase
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    // solhint-disable-next-line private-vars-leading-underscore, var-name-mixedcase
    bytes32 internal constant GRANT_OPERATOR_PERMISSIONS_WITH_SIG_TYPEHASH =
        keccak256( // solhint-disable-next-line max-line-length
            "grantOperatorPermissions(uint256 characterId,address operator,uint256 permissionBitMap,uint256 nonce,uint256 deadline)"
        );
    // the `isValidSignature` function returns the bytes4 magic value 0x1626ba7e when function passes
    bytes4 public constant EIP1271_MAGIC_VALUE = 0x1626ba7e;

    function validateGrantOperatorPermissionsSignature(
        DataTypes.EIP712Signature calldata signature,
        uint256 characterId,
        address operator,
        uint256 permissionBitMap
    ) external {
        bytes32 hashedMessage = keccak256(
            abi.encode(
                GRANT_OPERATOR_PERMISSIONS_WITH_SIG_TYPEHASH,
                characterId,
                operator,
                permissionBitMap,
                _getAndIncrementNonce(signature.signer),
                signature.deadline
            )
        );
        _validateRecoveredAddress(
            ECDSA.toTypedDataHash(_calculateDomainSeparator(), hashedMessage),
            signature
        );
    }

    /**
     * @dev This fetches a user's signing nonce and increments it, akin to `sigNonces++`.
     */
    function _getAndIncrementNonce(address user) internal returns (uint256) {
        unchecked {
            return StorageLib.nonces()[user]++;
        }
    }

    /**
     * @dev Calculates EIP712 DOMAIN_SEPARATOR based on the current contract and chain ID.
     */
    function _calculateDomainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN_TYPEHASH,
                    keccak256(bytes(IERC721Metadata(address(this)).name())),
                    1,
                    block.chainid,
                    address(this)
                )
            );
    }

    /**
     * @dev Wrapper for ecrecover to reduce code size, used in meta-tx specific functions.
     */
    function _validateRecoveredAddress(
        bytes32 digest,
        DataTypes.EIP712Signature calldata signature
    ) internal view {
        if (signature.deadline < block.timestamp) revert ErrSignatureExpired();

        if (signature.signer.code.length != 0) {
            bytes memory concatenatedSig = abi.encodePacked(signature.r, signature.s, signature.v);
            if (
                IERC1271(signature.signer).isValidSignature(digest, concatenatedSig) !=
                EIP1271_MAGIC_VALUE
            ) {
                revert ErrSignatureInvalid();
            }
        } else {
            address recoveredAddress = ecrecover(digest, signature.v, signature.r, signature.s);
            if (recoveredAddress == address(0) || recoveredAddress != signature.signer) {
                revert ErrSignatureInvalid();
            }
        }
    }
}
