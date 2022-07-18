// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../libraries/DataTypes.sol";
import "./helpers/Const.sol";
import "./helpers/utils.sol";
import "./helpers/SetUp.sol";
import "../misc/CBT1155.sol";

contract CbtTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    uint256 amount = 1;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event Mint(uint256 indexed to, uint256 indexed tokenId, uint256 indexed amount);
    event Burn(uint256 indexed from, uint256 indexed tokenId, uint256 indexed amount);

    function setUp() public {
        _setUp();
    }

    function testCbt() public {
        // alice mint first character
        DataTypes.CreateCharacterData memory characterData = makeCharacterData(
            Const.MOCK_CHARACTER_HANDLE,
            alice
        );
        vm.prank(alice);
        web3Entry.createCharacter(characterData);

        // MINTER_ROLE should mint
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        uint256 balance1Of1 = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CBT_ID
        );
        assertEq(balance1Of1, amount);
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.SECOND_CBT_ID, amount);
        uint256 balance2Of1 = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.SECOND_CBT_ID
        );
        assertEq(balance2Of1, amount);
        // can't mint to the zero characterID
        vm.expectRevert(abi.encodePacked("mint to the zero characterId"));
        cbt.mint(Const.ZERO_CBT_ID, Const.FIRST_CBT_ID, amount);
        // expect correct emit
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        cbt.mint(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);

        //owner should burn
        uint256 preBalance = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CBT_ID
        );
        vm.prank(alice);
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        uint256 postBalance = cbt.balanceOfByCharacterId(
            Const.FIRST_CHARACTER_ID,
            Const.FIRST_CBT_ID
        );
        // approved cbt should burn
        //TODO

        assertEq(preBalance - amount, postBalance);
        // caller is not token owner nor approved
        vm.expectRevert(abi.encodePacked("caller is not token owner nor approved"));
        vm.prank(bob);
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        //burn amount exceeds balance
        vm.prank(alice);
        vm.expectRevert(abi.encodePacked("burn amount exceeds balance"));
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, postBalance + 1);
        // expect correct emit
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);
        vm.prank(alice);
        cbt.burn(Const.FIRST_CHARACTER_ID, Const.FIRST_CBT_ID, amount);

        // setTokenURI
        cbt.setTokenURI(Const.FIRST_CBT_ID, Const.MOCK_TOKEN_URI);
        string memory preUri = cbt.uri(Const.FIRST_CBT_ID);
        assertEq(Const.MOCK_TOKEN_URI, preUri);
        cbt.setTokenURI(Const.FIRST_CBT_ID, Const.MOCK_NEW_TOKEN_URI);
        string memory postUri = cbt.uri(Const.FIRST_CBT_ID);
        assertEq(Const.MOCK_NEW_TOKEN_URI, postUri);

        cbt.setTokenURI(Const.SECOND_CBT_ID, Const.MOCK_TOKEN_URI);
        string memory preUri2 = cbt.uri(Const.SECOND_CBT_ID);
        assertEq(Const.MOCK_TOKEN_URI, preUri2);
        cbt.setTokenURI(Const.SECOND_CBT_ID, Const.MOCK_NEW_TOKEN_URI);
        string memory postUri2 = cbt.uri(Const.SECOND_CBT_ID);
        assertEq(Const.MOCK_NEW_TOKEN_URI, postUri2);

        // only MINTER_ROLE can set uri
        vm.prank(alice);
        vm.expectRevert(
            abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(alice),
                " is missing role ",
                Strings.toHexString(uint256(MINTER_ROLE), 32)
            )
        );
        cbt.setTokenURI(Const.FIRST_CBT_ID, Const.MOCK_TOKEN_URI);

        // cbt cannot be tansferred
        vm.expectRevert(abi.encodePacked("non-transferable"));
        cbt.safeTransferFrom(alice, bob, Const.FIRST_CBT_ID, amount, new bytes(0));
        vm.expectRevert(abi.encodePacked("non-transferable"));
        uint256[] memory ids = new uint256[](1);
        ids[0] = Const.FIRST_CBT_ID;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        cbt.safeBatchTransferFrom(alice, bob, ids, amounts, new bytes(0));
    }
}
