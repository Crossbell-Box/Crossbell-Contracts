// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../interfaces/IWeb3Entry.sol";

contract NewbieVilla is Initializable, AccessControlEnumerable, IERC721Receiver {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address public web3Entry;

    modifier _notExpired(uint256 expires) {
        require(expires >= block.timestamp, "NewbieVilla: receipt has expired");
        _;
    }

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

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        require(hasRole(ADMIN_ROLE, operator), "NewbieVilla: receive unknown character");
        if (data.length == 0) {
            IWeb3Entry(web3Entry).setOperator(tokenId, operator);
        } else {
            address selectedOperator = address(bytes20(data));
            IWeb3Entry(web3Entry).setOperator(tokenId, selectedOperator);
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}
