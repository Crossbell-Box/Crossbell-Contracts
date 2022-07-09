// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import  "../Web3Entry.sol";
import "../libraries/DataTypes.sol";


contract CreateCharacterTest is Test {
    Web3Entry web3entry;

    uint256 public characterId = 1;
    address public creator = address(this);
    address public to = address(this);
    string public handle = "0xcrossbell-eth";
    uint public timestamp = block.timestamp;

    // define a event we're expecting for:
    event CharacterCreated(
        uint256 indexed characterId,
        address indexed creator,
        address indexed to,
        string handle,
        uint256 timestamp
    );

    function testWeb3Emit() public {
        Web3Entry web3entryemitter = new Web3Entry();
        vm.expectEmit(true, true, true, false);
        // The event we expect
        emit CharacterCreated(characterId, creator, to, handle, timestamp);
        // The event we get;
        address _this = address(this);
        address _zero = address(0);
        string memory _handle = "0xcrossbell-eth";
        string memory _uri = "https://raw.githubusercontent.com/Crossbell-Box/Crossbell-Contracts/main/examples/sampleProfile.json";
        bytes memory bs = new bytes(0);
        DataTypes.CreateCharacterData memory characterData = DataTypes.CreateCharacterData(_this, _handle, _uri, _zero, bs);
        web3entryemitter.createCharacter(characterData);
    }
}
