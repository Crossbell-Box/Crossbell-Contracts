pragma solidity 0.8.10;

interface ILinklist {
    function mint(
        address to,
        bytes32 linkType,
        uint256 tokenId
    ) external;

    function setTakeOver(
        uint256 tokenId,
        address to,
        uint256 profileId
    ) external;

    function setUri(uint256 tokenId, string memory uri) external;

    function addLinkingProfileId(uint256 tokenId, uint256 toProfileId) external;

    function removeLinkingProfileId(uint256 tokenId, uint256 toProfileId) external;

    function getLinkingProfileIds(uint256 tokenId) external view returns (uint256[] memory);

    function getLinkingProfileListLength(uint256 tokenId) external view returns (uint256);

    function getCurrentTakeOver(uint256 tokenId) external view returns (uint256);

    function getLinkType(uint256 tokenId) external view returns (bytes32);

    function Uri(uint256 tokenId) external view returns (string memory);
}
