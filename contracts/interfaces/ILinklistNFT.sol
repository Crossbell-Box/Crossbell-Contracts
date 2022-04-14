pragma solidity 0.8.10;

interface ILinklistNFT {
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

    function addLinking2ProfileId(uint256 tokenId, uint256 toProfileId)
        external;

    function removeLinking2ProfileId(uint256 tokenId, uint256 toProfileId)
        external;

    function getLinking2ProfileIds(uint256 tokenId)
        external
        view
        returns (uint256[] memory);

    function getLinking2ProfileListLength(uint256 tokenId)
        external
        view
        returns (uint256);

    function getCurrentTakeOver(uint256 tokenId)
        external
        view
        returns (uint256);

    function getLinkType(uint256 tokenId) external view returns (bytes32);

    function Uri(uint256 tokenId) external view returns (string memory);
}
