pragma solidity 0.8.10;

interface ILinklistNFT {
    function mint(address to, uint256 tokenId) external;

    function takeOver(
        uint256 tokenId,
        address to,
        uint256 profileId
    ) external;

    function setURI(uint256 tokenId, string memory URI) external;

    function addLinkedProfileId(
        uint256 tokenId,
        bytes32 linkType,
        uint256 toProfileId
    ) external;

    function removeLinkedProfileId(
        uint256 tokenId,
        bytes32 linkType,
        uint256 toProfileId
    ) external;

    function getLinkedProfileIds(uint256 tokenId, bytes32 linkType)
        external
        view
        returns (uint256[] memory);

    function getLinkedProfileIdsLength(uint256 tokenId, bytes32 linkType)
        external
        view
        returns (uint256);

    function getCurrentTakeOver(uint256 tokenId)
        external
        view
        returns (uint256);

    function URI(uint256 tokenId) external view returns (string memory);
}
