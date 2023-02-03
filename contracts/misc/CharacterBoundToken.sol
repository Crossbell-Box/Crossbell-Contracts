// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract CharacterBoundToken is
    Context,
    ERC165,
    IERC1155,
    IERC1155MetadataURI,
    AccessControlEnumerable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Mapping from token ID to character balances
    // characterId => tokenId => balance
    mapping(uint256 => mapping(uint256 => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => string) private _tokenURIs;

    address public web3Entry;

    // tokenId => currentTokenNumber
    mapping(uint256 => uint256) private _currentTokenNumbers;

    // events
    event Mint(uint256 indexed to, uint256 indexed tokenId, uint256 indexed tokenNumber);
    event Burn(uint256 indexed from, uint256 indexed tokenId, uint256 indexed amount);

    constructor(address web3Entry_) {
        web3Entry = web3Entry_;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function mint(uint256 characterId, uint256 tokenId) external onlyRole(MINTER_ROLE) {
        require(characterId != 0, "mint to the zero characterId");

        _balances[characterId][tokenId] += 1;

        _currentTokenNumbers[tokenId] = _currentTokenNumbers[tokenId] + 1;
        emit Mint(characterId, tokenId, _currentTokenNumbers[tokenId]);
    }

    function burn(
        uint256 characterId,
        uint256 tokenId,
        uint256 amount
    ) external {
        address account = IERC721Enumerable(web3Entry).ownerOf(characterId);
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "caller is not token owner nor approved"
        );

        uint256 fromBalance = balanceOf(characterId, tokenId);
        require(fromBalance >= amount, "burn amount exceeds balance");
        _balances[characterId][tokenId] = fromBalance - amount;
        emit Burn(characterId, tokenId, amount);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) external onlyRole(MINTER_ROLE) {
        _setURI(tokenId, tokenURI);
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) external virtual override {
        revert("non-transferable");
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) external virtual override {
        revert("non-transferable");
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) external virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory tokenIds)
        external
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == tokenIds.length, "accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], tokenIds[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address account, uint256 tokenId)
        public
        view
        virtual
        override
        returns (uint256 balance)
    {
        uint256 characterCount = IERC721Enumerable(web3Entry).balanceOf(account);
        for (uint256 i = 0; i < characterCount; i++) {
            uint256 characterId = IERC721Enumerable(web3Entry).tokenOfOwnerByIndex(account, i);
            balance += balanceOf(characterId, tokenId);
        }
    }

    function balanceOf(uint256 characterId, uint256 tokenId) public view virtual returns (uint256) {
        require(characterId != 0, "zero is not a valid owner");
        return _balances[characterId][tokenId];
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _setURI(uint256 tokenId, string memory tokenURI) internal virtual {
        _tokenURIs[tokenId] = tokenURI;
        emit URI(uri(tokenId), tokenId);
    }
}
