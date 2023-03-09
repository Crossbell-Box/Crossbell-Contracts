// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import {IWeb3Entry} from "../interfaces/IWeb3Entry.sol";
import {OP} from "../libraries/OP.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC777Recipient} from "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC777} from "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC1820Registry} from "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";

/**
 * @dev Implementation of a contract to keep characters for others. The address with
 * the ADMIN_ROLE are expected to issue the proof to users. Then users could use the
 * proof to withdraw the corresponding character.
 */

contract NewbieVilla is Initializable, AccessControlEnumerable, IERC721Receiver, IERC777Recipient {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IERC1820Registry public constant ERC1820_REGISTRY =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    bytes32 public constant TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    address public web3Entry;
    address public xsyncOperator;
    // slither-disable-next-line naming-convention
    address internal _token; // mira token, erc777 standard
    // characterId => balance
    // slither-disable-next-line naming-convention
    mapping(uint256 => uint256) internal _balances;

    // events
    /**
     * @dev Emitted when the web3Entry character nft is withdrawn.
     * @param to The receiver of web3Entry character nft.
     * @param characterId The character ID.
     * @param token Addresses of token withdrawn.
     * @param amount Amount of token withdrawn.
     */
    event Withdraw(address to, uint256 characterId, address token, uint256 amount);

    modifier notExpired(uint256 expires) {
        require(expires >= block.timestamp, "NewbieVilla: receipt has expired");
        _;
    }

    /**
     * @notice Initialize the Newbie Villa contract.
     * @dev msg.sender will be granted `DEFAULT_ADMIN_ROLE`.
     * @param web3Entry_ Address of web3Entry contract.
     * @param xsyncOperator_ Address of xsyncOperator.
     * @param token_ Address of ERC777 token.
     * @param admin_ Address of admin.
     */
    function initialize(
        address web3Entry_,
        address xsyncOperator_,
        address token_,
        address admin_
    ) external reinitializer(2) {
        web3Entry = web3Entry_;
        xsyncOperator = xsyncOperator_;
        _token = token_;

        // grants `DEFAULT_ADMIN_ROLE`
        _setupRole(DEFAULT_ADMIN_ROLE, admin_);

        // register interfaces
        ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }

    /**
    
     * @notice  Withdraw character#`characterId` to `to` using the nonce, expires and the proof. <br>
     * Emits the `Withdraw` event. <br>
     * @dev Proof is the signature from someone with the ADMIN_ROLE. The message to sign is
     * the packed data of this contract's address, `characterId`, `nonce` and `expires`. <br>
     *
     * Here's an example to generate a proof: <br>
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
     * <b> Requirements: </b>:
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
        bytes calldata proof
    ) external notExpired(expires) {
        bytes32 signedData = ECDSA.toEthSignedMessageHash(
            keccak256(abi.encodePacked(address(this), characterId, nonce, expires))
        );
        require(
            hasRole(ADMIN_ROLE, ECDSA.recover(signedData, proof)),
            "NewbieVilla: unauthorized withdraw"
        );

        uint256 amount = _balances[characterId];
        _balances[characterId] = 0;
        // send token
        IERC777(_token).send(to, amount, ""); // solhint-disable-line check-send-result

        // transfer web3Entry nft
        IERC721(web3Entry).safeTransferFrom(address(this), to, characterId);

        emit Withdraw(to, characterId, _token, amount);
    }

    /**
     * @dev  Whenever a character `tokenId` is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called. `data` will be decoded as an address and set as
     * the operator of the character. If the `data` is empty, the `operator` will be default operator of the
     * character. <br>
     *
     * <b> Requirements: </b>:
     *
     * - `msg.sender` must be address of Web3Entry.
     * - `operator` must has ADMIN_ROLE.
     *
     * @param data bytes encoded from the operator address to set for the incoming character.
     *
     */
    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        // Only character nft could be received, other nft, e.g. mint nft would be reverted
        require(msg.sender == web3Entry, "NewbieVilla: receive unknown token");
        // Only admin role could send character to this contract
        require(hasRole(ADMIN_ROLE, operator), "NewbieVilla: receive unknown character");

        if (data.length == 0) {
            IWeb3Entry(web3Entry).grantOperatorPermissions(
                tokenId,
                operator,
                OP.DEFAULT_PERMISSION_BITMAP
            );
        } else {
            address selectedOperator = abi.decode(data, (address));
            IWeb3Entry(web3Entry).grantOperatorPermissions(
                tokenId,
                selectedOperator,
                OP.DEFAULT_PERMISSION_BITMAP
            );
        }
        IWeb3Entry(web3Entry).grantOperatorPermissions(
            tokenId,
            xsyncOperator,
            OP.POST_NOTE_DEFAULT_PERMISSION_BITMAP
        );
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @inheritdoc IERC777Recipient
    /**
     * @notice  Receives tokens. Only specific tokens are accepted, so be careful not to send tokens to this 
     address randomly.
     * @dev     The userData/operatorData should be an abi-encoded bytes of `fromCharacterId` and `toCharacter`,
     * which are both uint256 type, so the length of data is 64.
     * @param   to  The Newbie Villa contract address.
     * @param   amount  The amount of token sent.
     * @param   userData  The abi-encoded bytes of `fromCharacterId` and `toCharacter`.
     * @param   operatorData  The abi-encoded bytes of `fromCharacterId` and `toCharacter`.
     */
    function tokensReceived(
        address,
        address,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override(IERC777Recipient) {
        require(msg.sender == _token, "NewbieVilla: invalid token");
        require(address(this) == to, "NewbieVilla: invalid receiver");
        bytes memory data = userData.length > 0 ? userData : operatorData;

        if (data.length == 64) {
            (, uint256 toCharacterId) = abi.decode(data, (uint256, uint256));
            _balances[toCharacterId] += amount;
        } else {
            revert("NewbieVilla: unknown receiving");
        }
    }

    /**
     * @notice  Returns the amount of tokens owned by `characterId`.
     * @param   characterId  The character ID to query.
     * @return  uint256  The amount of tokens owned by the character.
     */
    function balanceOf(uint256 characterId) external view returns (uint256) {
        return _balances[characterId];
    }

    /**
     * @notice Returns the address of mira token contract.
     * @return The address of mira token contract.
     */
    function getToken() external view returns (address) {
        return _token;
    }
}
