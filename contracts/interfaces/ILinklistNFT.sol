pragma solidity 0.8.10;

interface ILinklistNFT {
    function mint(
        uint256 profileId,
        bytes32 linkType,
        address to
    ) external;

    function setURI(uint256 tokenId, string memory URI) external;

    function addLinkList(
        uint256 profileId,
        bytes32 linkType,
        uint256 linkId
    ) external;

    function removeLinkList(
        uint256 profileId,
        bytes32 linkType,
        uint256 linkId
    ) external;

    function getLinkList(uint256 profileId, bytes32 linkType)
        external
        view
        returns (uint256[] memory);

    function getLinkListLength(uint256 profileId, bytes32 linkType)
        external
        view
        returns (uint256);

    function existsLinkList(uint256 profileId, bytes32 linkType)
        external
        view
        returns (bool);

    function getTokenId(uint256 profileId, bytes32 linkType)
        external
        pure
        returns (uint256);

    function URI(uint256 tokenId) external view returns (string memory);
}
