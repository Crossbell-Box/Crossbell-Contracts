// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IMintNFT {
    /**
     * @notice Initialize the mint nft.
     * @param characterId_  The character ID of the note to initialize.
     * @param noteId_  The note ID to initialize.
     * @param web3Entry_  The address of web3Entry contract.
     * @param name_ The name to set for this NFT.
     * @param symbol_ The symbol to set for this NFT.
     */
    function initialize(
        uint256 characterId_,
        uint256 noteId_,
        address web3Entry_,
        string calldata name_,
        string calldata symbol_
    ) external;

    /**
     * @notice Mints a note NFT to the specified address.
     * This can only be called by web3Entry, and is called upon note.
     * @param to The address to mint the NFT to.
     * @return uint256 The minted token ID.
     */
    function mint(address to) external returns (uint256);

    /**
     * @notice Returns the original receiver of specified NFT.
     * @return The address of original receiver.
     */
    function originalReceiver(uint256 tokenId) external view returns (address);

    /**
     * @notice Returns the source note pointer mapped to this note NFT.
     * @return characterId The character ID.
     * @return noteId The note ID.
     */
    function getSourceNotePointer() external view returns (uint256 characterId, uint256 noteId);
}
