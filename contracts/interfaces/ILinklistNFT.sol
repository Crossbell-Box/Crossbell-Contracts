pragma solidity 0.8.10;

interface ILinklistNFT {
    function mint(address to, uint256 tokenId) external;

    function setURI(uint256 tokenId, string memory URI) external;

    function addLinkList(
        uint256 tokenId,
        bytes32 linkType,
        uint256 toProfileId
    ) external;

    function removeLinkList(
        uint256 tokenId,
        bytes32 linkType,
        uint256 toProfileId
    ) external;

    function getLinkList(uint256 tokenId, bytes32 linkType)
        external
        view
        returns (uint256[] memory);

    function getLinkListLength(uint256 tokenId, bytes32 linkType)
        external
        view
        returns (uint256);

    function getTokenId(uint256 profileId, bytes32 linkType)
        external
        pure
        returns (uint256);

    function getCurrentTakeOver(uint256 tokenId)
        external
        view
        returns (uint256);

    function URI(uint256 tokenId) external view returns (string memory);
}
