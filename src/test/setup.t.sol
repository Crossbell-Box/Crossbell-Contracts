// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "../Web3Entry.sol";
import "../libraries/DataTypes.sol";
import "../libraries/LinkModuleLogic.sol";
import "../libraries/CharacterLogic.sol";
import "../libraries/PostLogic.sol";
import "../libraries/LinkLogic.sol";
import "../MintNFT.sol";
import "../Resolver.sol";
import "../LinkList.sol";
import "../Web3Entry.sol";
import "../misc/Periphery.sol";
import "./mocks/NFT.sol";

contract setUpTest is Test {
    function setUp() public {
        LinkModuleLogic = new LinkModuleLogic();
        CharacterLogic = new CharacterLogic();
        PostLogic = new PostLogic();
        LinkLogic = new LinkLogic();
        MintNFT = new MintNFT();
        Resolver = new Resolver();
        Linklist = new Linklist();
        Web3Entry = new Web3Entry(address());


    }
}