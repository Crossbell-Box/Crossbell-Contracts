// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/IWeb3Entry.sol";

/**
 * @dev Implementation of a contract to keep characters for others. The address with
 * the ADMIN_ROLE are expected to issue the proof to users. Then users could use the
 * proof to withdraw the corresponding character.
 */

contract NewbieVilla is Initializable, AccessControlEnumerable, IERC721Receiver {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address public web3Entry;

    modifier _notExpired(uint256 expires) {
        require(expires >= block.timestamp, "NewbieVilla: receipt has expired");
        _;
    }

    /**
     * @notice  Initialize the Newbie Villa contract.
     * @dev     msg.sender will be granted both DEFAULT_ADMIN_ROLE and ADMIN_ROLE.
     * @param   _web3Entry  Address of Web3Entry.
     */
    function initialize(address _web3Entry) external initializer {
        web3Entry = _web3Entry;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        require(sig.length == 65, "NewbieVilla: Wrong signature length");

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @notice  Withdraw character#`characterId` to `to` using the nonce, expires and the proof.
     * @dev     Proof is the signature from someone with the ADMIN_ROLE. The message to sign is
     * the packed data of this contract's address, `characterId`, `nonce` and `expires`.
     *
     * Here's an example to generate a proof:
     * ```
     *     digest = ethers.utils.arrayify(
     *          ethers.utils.solidityKeccak256(
     *              ["address", "uint256", "uint256", "uint256"],
     *              [newbieVilla.address, characterId, nonce, expires]
     *          )
     *      );
     *      proof = await owner.signMessage(digest);
     * ```
     *
     * Requirements:
     * - `expires` is greater than the current timestamp
     * - `proof` is signed by the one with the ADMIN_ROLE
     *
     * @param   to  Receiver of the withdrawn character.
     * @param   characterId  The token id of the character to withdraw.
     * @param   nonce  Random nonce used to generate the proof.
     * @param   expires  Expire time of the proof, Unix timestamp in seconds.
     * @param   proof  The proof using to withdraw the character.
     */
    function withdraw(
        address to,
        uint256 characterId,
        uint256 nonce,
        uint256 expires,
        bytes memory proof
    ) external _notExpired(expires) {
        bytes32 signedData = prefixed(
            keccak256(abi.encodePacked(address(this), characterId, nonce, expires))
        );
        require(
            hasRole(ADMIN_ROLE, recoverSigner(signedData, proof)),
            "NewbieVilla: Unauthorized withdraw"
        );

        IERC721(web3Entry).safeTransferFrom(address(this), to, characterId);
    }

    /**
     * @dev  Whenever a character `tokenId` is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called. `data` will be decoded as an address and set as
     * the operator of the character. If the `data` is empty, the `operator` will be default operator of the
     * character.
     *
     * Requirements:
     *
     * - `msg.sender` must be address of Web3Entry.
     * - `operator` must has ADMIN_ROLE.
     *
     * @param data bytes encoded from the operator address to set for the incoming character.
     *
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        require(msg.sender == web3Entry, "NewbieVilla: receive unknown token");
        require(hasRole(ADMIN_ROLE, operator), "NewbieVilla: receive unknown character");
        if (data.length == 0) {
            IWeb3Entry(web3Entry).setOperator(tokenId, operator);
        } else {
            address selectedOperator = abi.decode(data, (address));
            IWeb3Entry(web3Entry).setOperator(tokenId, selectedOperator);
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}
