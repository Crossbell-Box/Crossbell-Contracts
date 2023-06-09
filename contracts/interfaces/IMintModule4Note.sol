// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IMintModule4Note {
    /**
     * @notice  Initialize the MintModule for a specific note.
     * @param   characterId  The character ID of the note to initialize.
     * @param   noteId  The note ID to initialize.
     * @param   data  The data passed from the user to be decoded.
     * @return  bytes  The returned data of calling initializeMintModule.
     */
    function initializeMintModule(
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external returns (bytes memory);

    /**
     * @notice Processes the mint logic. <br>
     * Triggered when the `mintNote` of web3Entry is called, if mint module of note is set.
     * @param   to  The receive address of the NFT.
     * @param   characterId  The character ID of the note owner.
     * @param   noteId  The note ID.
     * @param   data  The data passed from the user to be decoded.
     */
    function processMint(
        address to,
        uint256 characterId,
        uint256 noteId,
        bytes calldata data
    ) external;
}
