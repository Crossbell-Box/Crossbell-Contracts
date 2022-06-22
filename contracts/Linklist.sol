// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./interfaces/ILinklist.sol";
import "./interfaces/IWeb3Entry.sol";
import "./base/NFTBase.sol";
import "./libraries/Events.sol";
import "./libraries/DataTypes.sol";
import "./libraries/Constants.sol";
import "./storage/LinklistStorage.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Linklist is ILinklist, NFTBase, LinklistStorage, Initializable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    function initialize(
        string calldata _name,
        string calldata _symbol,
        address _web3Entry
    ) external initializer {
        Web3Entry = _web3Entry;

        super._initialize(_name, _symbol);
        emit Events.LinklistNFTInitialized(block.timestamp);
    }

    function mint(
        address to,
        bytes32 linkType,
        uint256 tokenId
    ) external override {
        _validateCallerIsWeb3Entry();

        linkTypes[tokenId] = linkType;
        _mint(to, tokenId);
    }

    function setTakeOver(
        uint256 tokenId,
        address to,
        uint256 characterId
    ) external {
        _validateCallerIsWeb3Entry();
        require(to == ownerOf(tokenId), "Linklist: not token owner");

        currentTakeOver[tokenId] = characterId;
    }

    function setUri(uint256 tokenId, string memory _uri) external {
        require(_exists(tokenId), "Linklist: setUri for nonexistent token");
        _validateCallerIsWeb3EntryOrOwner(tokenId);

        _uris[tokenId] = _uri;
    }

    /////////////////////////////////
    // linking Character
    /////////////////////////////////
    function addLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external {
        _validateCallerIsWeb3Entry();
        linkingCharacterList[tokenId].add(toCharacterId);
    }

    function removeLinkingCharacterId(uint256 tokenId, uint256 toCharacterId) external {
        _validateCallerIsWeb3Entry();
        linkingCharacterList[tokenId].remove(toCharacterId);
    }

    function getLinkingCharacterIds(uint256 tokenId) external view returns (uint256[] memory) {
        return linkingCharacterList[tokenId].values();
    }

    function getLinkingCharacterListLength(uint256 tokenId) external view returns (uint256) {
        return linkingCharacterList[tokenId].length();
    }

    /////////////////////////////////
    // linking Note
    /////////////////////////////////
    function addLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId
    ) external returns (bytes32) {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("Note", toCharacterId, toNoteId));
        if (tokenId != 0) {
            linkNoteKeys[tokenId].add(linkKey);
        }
        linkNoteList[linkKey] = DataTypes.NoteStruct({
            characterId: toCharacterId,
            noteId: toNoteId
        });

        return linkKey;
    }

    function removeLinkingNote(
        uint256 tokenId,
        uint256 toCharacterId,
        uint256 toNoteId
    ) external {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("Note", toCharacterId, toNoteId));
        linkNoteKeys[tokenId].remove(linkKey);

        // do note delete
        // delete linkNoteList[linkKey];
    }

    function getLinkingNotes(uint256 tokenId)
        external
        view
        returns (DataTypes.NoteStruct[] memory results)
    {
        bytes32[] memory linkKeys = linkNoteKeys[tokenId].values();
        results = new DataTypes.NoteStruct[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            results[i] = linkNoteList[linkKeys[i]];
        }
    }

    function getLinkingNote(bytes32 linkKey) external view returns (DataTypes.NoteStruct memory) {
        return linkNoteList[linkKey];
    }

    function getLinkingNoteListLength(uint256 tokenId) external view returns (uint256) {
        return linkNoteKeys[tokenId].length();
    }

    /////////////////////////////////
    // linking CharacterLink
    /////////////////////////////////
    function addLinkingCharacterLink(
        uint256 tokenId,
        DataTypes.CharacterLinkStruct calldata linkData
    ) external {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(
            abi.encodePacked(
                "ProfileLink",
                linkData.fromCharacterId,
                linkData.toCharacterId,
                linkData.linkType
            )
        );
        if (tokenId != 0) {
            linkingCharacterLinkKeys[tokenId].add(linkKey);
        }
        linkingCharacterLinkList[linkKey] = linkData;
    }

    function removeLinkingCharacterLink(
        uint256 tokenId,
        DataTypes.CharacterLinkStruct calldata linkData
    ) external {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(
            abi.encodePacked(
                "ProfileLink",
                linkData.fromCharacterId,
                linkData.toCharacterId,
                linkData.linkType
            )
        );
        linkingCharacterLinkKeys[tokenId].remove(linkKey);

        // do note delete
        // delete linkingCharacterLinkList[linkKey];
    }

    function getLinkingCharacterLinks(uint256 tokenId)
        external
        view
        returns (DataTypes.CharacterLinkStruct[] memory results)
    {
        bytes32[] memory linkKeys = linkingCharacterLinkKeys[tokenId].values();
        results = new DataTypes.CharacterLinkStruct[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = linkingCharacterLinkList[key];
        }
    }

    function getLinkingCharacterLink(bytes32 linkKey)
        external
        view
        returns (DataTypes.CharacterLinkStruct memory)
    {
        return linkingCharacterLinkList[linkKey];
    }

    function getLinkingCharacterLinkListLength(uint256 tokenId) external view returns (uint256) {
        return linkingCharacterLinkKeys[tokenId].length();
    }

    /////////////////////////////////
    // linking ERC721
    /////////////////////////////////
    function addLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external returns (bytes32) {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("ERC721", tokenAddress, erc721TokenId));
        if (tokenId != 0) {
            linkingERC721Keys[tokenId].add(linkKey);
        }
        linkingERC721List[linkKey] = DataTypes.ERC721Struct({
            tokenAddress: tokenAddress,
            erc721TokenId: erc721TokenId
        });

        return linkKey;
    }

    function removeLinkingERC721(
        uint256 tokenId,
        address tokenAddress,
        uint256 erc721TokenId
    ) external {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("ERC721", tokenAddress, erc721TokenId));
        linkingERC721Keys[tokenId].remove(linkKey);

        // do not delete, maybe others link the same token
        // delete linkingERC721List[linkKey];
    }

    function getLinkingERC721s(uint256 tokenId)
        external
        view
        returns (DataTypes.ERC721Struct[] memory results)
    {
        bytes32[] memory linkKeys = linkingERC721Keys[tokenId].values();
        results = new DataTypes.ERC721Struct[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            results[i] = linkingERC721List[linkKeys[i]];
        }
    }

    function getLinkingERC721(bytes32 linkKey)
        external
        view
        returns (DataTypes.ERC721Struct memory)
    {
        return linkingERC721List[linkKey];
    }

    function getLinkingERC721ListLength(uint256 tokenId) external view returns (uint256) {
        return linkingERC721Keys[tokenId].length();
    }

    /////////////////////////////////
    // linking Address
    /////////////////////////////////
    function addLinkingAddress(uint256 tokenId, address ethAddress) external {
        _validateCallerIsWeb3Entry();
        linkingAddressList[tokenId].add(ethAddress);
    }

    function removeLinkingAddress(uint256 tokenId, address ethAddress) external {
        _validateCallerIsWeb3Entry();
        linkingAddressList[tokenId].remove(ethAddress);
    }

    function getLinkingAddresses(uint256 tokenId) external view returns (address[] memory) {
        return linkingAddressList[tokenId].values();
    }

    function getLinkingAddressListLength(uint256 tokenId) external view returns (uint256) {
        return linkingAddressList[tokenId].length();
    }

    /////////////////////////////////
    // linking Any Uri
    /////////////////////////////////
    function addLinkingAnyUri(uint256 tokenId, string memory toUri) external returns (bytes32) {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", toUri));
        if (tokenId != 0) {
            linkingAnyKeys[tokenId].add(linkKey);
        }
        linkingAnylist[linkKey] = toUri;
        return linkKey;
    }

    function removeLinkingAnyUri(uint256 tokenId, string memory toUri) external {
        _validateCallerIsWeb3Entry();

        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", toUri));
        linkingAnyKeys[tokenId].remove(linkKey);

        // do note delete
        // delete linkingAnylist[linkKey];
    }

    function getLinkingAnyUris(uint256 tokenId) external view returns (string[] memory results) {
        bytes32[] memory linkKeys = linkingAnyKeys[tokenId].values();
        results = new string[](linkKeys.length);
        for (uint256 i = 0; i < linkKeys.length; i++) {
            bytes32 key = linkKeys[i];
            results[i] = linkingAnylist[key];
        }
    }

    function getLinkingAnyUri(bytes32 linkKey) external view returns (string memory) {
        return linkingAnylist[linkKey];
    }

    function getLinkingAnyUriKeys(uint256 tokenId) external view returns (bytes32[] memory) {
        return linkingAnyKeys[tokenId].values();
    }

    function getLinkingAnyListLength(uint256 tokenId) external view returns (uint256) {
        return linkingAnyKeys[tokenId].length();
    }

    /////////////////////////////////
    // linking Linklist
    /////////////////////////////////
    function addLinkingLinklistId(uint256 tokenId, uint256 linklistId) external {
        _validateCallerIsWeb3Entry();
        linkingLinklists[tokenId].add(linklistId);
    }

    function removeLinkingLinklistId(uint256 tokenId, uint256 linklistId) external {
        _validateCallerIsWeb3Entry();
        linkingLinklists[tokenId].remove(linklistId);
    }

    function getLinkingLinklistIds(uint256 tokenId) external view returns (uint256[] memory) {
        return linkingLinklists[tokenId].values();
    }

    function getLinkingLinklistLength(uint256 tokenId) external view returns (uint256) {
        return linkingLinklists[tokenId].length();
    }

    /////////////////////////////////
    // common
    /////////////////////////////////
    function getCurrentTakeOver(uint256 tokenId) external view returns (uint256 characterId) {
        characterId = currentTakeOver[tokenId];
    }

    function getLinkType(uint256 tokenId) external view returns (bytes32) {
        return linkTypes[tokenId];
    }

    function Uri(uint256 tokenId) external view returns (string memory) {
        return _getTokenUri(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return _getTokenUri(tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        // only web3Entry can transfer linklist token
        _validateCallerIsWeb3Entry();

        super._transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        // approve for Web3Entry
        if (!isApprovedForAll(from, Web3Entry)) {
            _setApprovalForAll(from, Web3Entry, true);
        }

        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function _getTokenUri(uint256 tokenId) internal view returns (string memory) {
        require(_exists(tokenId), "Linklist: URI query for nonexistent token");

        return _uris[tokenId];
    }

    function _validateCallerIsWeb3Entry() internal view {
        require(msg.sender == Web3Entry, "Linklist: NotWeb3Entry");
    }

    function _validateCallerIsWeb3EntryOrOwner(uint256 tokenId) internal view {
        require(
            msg.sender == Web3Entry || msg.sender == ownerOf(tokenId),
            "Linklist: NotWeb3EntryOrNotOwner"
        );
    }
}
