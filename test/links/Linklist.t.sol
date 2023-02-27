// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../../contracts/Web3Entry.sol";
import "../../contracts/libraries/DataTypes.sol";
import "../../contracts/libraries/Error.sol";
import "../helpers/Const.sol";
import "../helpers/utils.sol";
import "../helpers/SetUp.sol";

contract LinklistTest is Test, SetUp, Utils {
    address public alice = address(0x1111);
    address public bob = address(0x2222);
    address public carol = address(0x3333);

    event Transfer(address indexed from, uint256 indexed characterId, uint256 indexed tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /* solhint-disable comprehensive-interface */
    function setUp() public {
        _setUp();

        // create character
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE, alice));
        web3Entry.createCharacter(makeCharacterData(Const.MOCK_CHARACTER_HANDLE2, bob));

        // alice link bob
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
    }

    function testInitialize() public {
        expectEmit(CheckAll);
        emit Events.BaseInitialized(
            Const.LINK_LIST_NFT_NAME,
            Const.LINK_LIST_NFT_SYMBOL,
            block.timestamp
        );
        emit Events.LinklistNFTInitialized(block.timestamp);

        Linklist linklist = new Linklist();
        // initialize linklist
        linklist.initialize(
            Const.LINK_LIST_NFT_NAME,
            Const.LINK_LIST_NFT_SYMBOL,
            address(web3Entry)
        );
    }

    function testInitializeFail() public {
        vm.expectRevert(abi.encodePacked("Initializable: contract is already initialized"));
        linklist.initialize(
            Const.LINK_LIST_NFT_NAME,
            Const.LINK_LIST_NFT_SYMBOL,
            address(web3Entry)
        );
    }

    function testMint() public {
        // link character
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Transfer(address(0), Const.FIRST_CHARACTER_ID, 2);
        expectEmit(CheckTopic1 | CheckTopic2 | CheckTopic3 | CheckData);
        emit Transfer(address(0), alice, 2);
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        // check state
        // alice should have 2 linklists, because there's already one follow list in setUp.
        assertEq(linklist.totalSupply(), 2);
        assertEq(linklist.balanceOf(alice), 2);
        assertEq(linklist.balanceOf(Const.FIRST_CHARACTER_ID), 2);
        assertEq(linklist.ownerOf(2), alice);
        assertEq(linklist.characterOwnerOf(2), Const.FIRST_CHARACTER_ID);
        assertEq(linklist.getOwnerCharacterId(2), 1);
        assertEq(linklist.Uri(2), "");
    }

    function testMintFail() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        // only web3Entry can mint
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3Entry.selector));
        vm.prank(bob);
        linklist.mint(2, Const.FollowLinkType, 2);

        // mint an existing token id
        vm.expectRevert(abi.encodeWithSelector(ErrTokenIdAlreadyExists.selector));
        vm.prank(address(web3Entry));
        linklist.mint(1, Const.FollowLinkType, 1);
    }

    function testSetUri() public {
        // link character
        vm.startPrank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        // case 1: set linklist uri by alice
        linklist.setUri(1, Const.MOCK_TOKEN_URI);
        // check linklist uri
        assertEq(linklist.Uri(1), Const.MOCK_TOKEN_URI);
        vm.stopPrank();

        // case 2: set linklist uri by web3Entry
        vm.prank(address(web3Entry));
        linklist.setUri(1, Const.MOCK_NEW_TOKEN_URI);
        // check linklist uri
        assertEq(linklist.Uri(1), Const.MOCK_NEW_TOKEN_URI);
    }

    function testSetUriFail() public {
        // link character
        vm.prank(alice);
        web3Entry.linkCharacter(
            DataTypes.linkCharacterData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        // bob sets linklist uri
        vm.expectRevert(abi.encodeWithSelector(ErrCallerNotWeb3EntryOrNotOwner.selector));
        vm.prank(bob);
        linklist.setUri(1, Const.MOCK_TOKEN_URI);
    }

    ////////////////////////////////////////////////////////
    ///      VIEW FUNCTIONS
    ////////////////////////////////////////////////////////

    function testGetLinkingCharacterIds() public {
        uint256[] memory linkingCharacterIds = linklist.getLinkingCharacterIds(1);
        uint[] memory expectedIds = new uint[](1);
        expectedIds[0] = 2;
        assertEq(linkingCharacterIds, expectedIds);

        // add
        // remove
    }

    function testGetLinkingCharacterListLength() public {
        uint256 length = linklist.getLinkingCharacterListLength(1);
        assertEq(length, 1);
    }

    function testGetOwnerCharacterId() public {
        uint256 ownerId = linklist.getOwnerCharacterId(1);
        assertEq(ownerId, 1);
    }

    function testGetLinkingNotes() public {
        // bob post a note and alice link it
        vm.prank(bob);
        web3Entry.postNote(makePostNoteData(Const.SECOND_CHARACTER_ID));
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        DataTypes.NoteStruct[] memory linkingNotes = linklist.getLinkingNotes(1);
        assertEq(linkingNotes.length, 1);
        DataTypes.NoteStruct memory linkingNote = linkingNotes[0];
        assertEq(linkingNote.characterId, 2);
        assertEq(linkingNote.noteId, 1);
    }

    function testGetLinkingNote() public {
        // bob post a note and alice link it
        vm.prank(bob);
        web3Entry.postNote(makePostNoteData(Const.SECOND_CHARACTER_ID));
        vm.prank(alice);
        web3Entry.linkNote(
            DataTypes.linkNoteData(
                Const.FIRST_CHARACTER_ID,
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_NOTE_ID,
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        bytes32 linkKey = keccak256(
            abi.encodePacked("Note", Const.SECOND_CHARACTER_ID, Const.FIRST_NOTE_ID)
        );
        DataTypes.NoteStruct memory linkingNote = linklist.getLinkingNote(linkKey);
        assertEq(linkingNote.characterId, 2);
        assertEq(linkingNote.noteId, 1);
    }

    function testGetLinkingNoteListLength() public {
        uint256 length = linklist.getLinkingNoteListLength(1);
        assertEq(length, 0);
    }

    function testGetLinkingCharacterLinks() public {
        // bob link alice's FollowLink
        /**  
            linkCharacterLink is commented out because of web3Entry's code size, so for now we call 
        `addLinkingCharacterLink` directly
        */
        vm.startPrank(address(web3Entry));
        linklist.mint(Const.SECOND_CHARACTER_ID, Const.FollowLinkType, 2);
        linklist.addLinkingCharacterLink(
            2,
            DataTypes.CharacterLinkStruct(
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FollowLinkType
            )
        );
        // web3Entry.linkCharacterLink(
        //     DataTypes.linkLinklistData(
        //         Const.SECOND_CHARACTER_ID,
        //         Const.FIRST_CHARACTER_ID,
        //         Const.FollowLinkType,
        //         new bytes(0)
        //     )
        // );

        DataTypes.CharacterLinkStruct[] memory linkingCharacterLinks = linklist
            .getLinkingCharacterLinks(2);
        assertEq(linkingCharacterLinks.length, 1);
        assertEq(linkingCharacterLinks[0].fromCharacterId, Const.SECOND_CHARACTER_ID);
        assertEq(linkingCharacterLinks[0].toCharacterId, Const.FIRST_CHARACTER_ID);
        assertEq(linkingCharacterLinks[0].linkType, Const.FollowLinkType);
    }

    function testGetLinkingCharacterLinkListLength() public {
        // bob link alice's FollowLink
        /**  
            linkCharacterLink is commented out because of web3Entry's code size, so for now we call 
        `addLinkingCharacterLink` directly
        */
        vm.startPrank(address(web3Entry));
        linklist.mint(Const.SECOND_CHARACTER_ID, Const.FollowLinkType, 2);
        linklist.addLinkingCharacterLink(
            2,
            DataTypes.CharacterLinkStruct(
                Const.SECOND_CHARACTER_ID,
                Const.FIRST_CHARACTER_ID,
                Const.FollowLinkType
            )
        );

        uint256 length = linklist.getLinkingCharacterLinkListLength(2);
        assertEq(length, 1);
    }

    function testGetLinkingERC721s() public {
        // alice link a nft
        vm.prank(address(web3Entry));
        nft.mint(bob);
        vm.prank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
        DataTypes.ERC721Struct[] memory linkingERC721s = linklist.getLinkingERC721s(2);
        assertEq(linkingERC721s[0].tokenAddress, address(nft));
        assertEq(linkingERC721s[0].erc721TokenId, 1);
    }

    function testGetLinkingERC721() public {
        // alice link a nft
        vm.prank(address(web3Entry));
        nft.mint(bob);
        vm.prank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
        bytes32 linkKey = keccak256(abi.encodePacked("ERC721", address(nft), uint256(1)));
        DataTypes.ERC721Struct memory linkingERC721 = linklist.getLinkingERC721(linkKey);
        assertEq(linkingERC721.tokenAddress, address(nft));
        assertEq(linkingERC721.erc721TokenId, 1);
    }

    function testGetLinkingERC721ListLength() public {
        // alice link a nft
        vm.prank(address(web3Entry));
        nft.mint(bob);
        vm.prank(alice);
        web3Entry.linkERC721(
            DataTypes.linkERC721Data(
                Const.FIRST_CHARACTER_ID,
                address(nft),
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );
        uint256 length = linklist.getLinkingERC721ListLength(2);
        assertEq(length, 1);
    }

    function testGetLinkingAddresses() public {
        // alice link an address
        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        address[] memory linkingAddress = linklist.getLinkingAddresses(1);
        assertEq(linkingAddress.length, 1);
        assertEq(linkingAddress[0], address(0x1232414));
    }

    function testGetLinkingAddressesLength() public {
        // alice link an address
        vm.prank(alice);
        web3Entry.linkAddress(
            DataTypes.linkAddressData(
                Const.FIRST_CHARACTER_ID,
                address(0x1232414),
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        uint256 length = linklist.getLinkingAddressListLength(1);
        assertEq(length, 1);
    }

    function testGetLinkingAnyUris() public {
        // alice link an uri
        vm.prank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType,
                new bytes(0)
            )
        );

        string[] memory linkingUris = linklist.getLinkingAnyUris(1);
        assertEq(linkingUris.length, 1);
        assertEq(linkingUris[0], "ipfs://anyURI");
    }

    function testGetLinkingAnyUri() public {
        // alice link an uri
        vm.prank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", "ipfs://anyURI"));
        string memory linkingUri = linklist.getLinkingAnyUri(linkKey);
        assertEq(linkingUri, "ipfs://anyURI");
    }

    function testGetLinkingAnyUriKeys() public {
        // alice link an uri
        vm.prank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        bytes32 linkKey = keccak256(abi.encodePacked("AnyUri", "ipfs://anyURI"));
        bytes32[] memory linkingUriKeys = linklist.getLinkingAnyUriKeys(1);
        assertEq(linkingUriKeys.length, 1);
        assertEq(linkingUriKeys[0], linkKey);
    }

    function testGetLinkingAnyListLength() public {
        // alice link an uri
        vm.prank(alice);
        web3Entry.linkAnyUri(
            DataTypes.linkAnyUriData(
                Const.FIRST_CHARACTER_ID,
                "ipfs://anyURI",
                Const.FollowLinkType,
                new bytes(0)
            )
        );
        uint256 length = linklist.getLinkingAnyListLength(1);
        assertEq(length, 1);
    }

    function testGetLinkingLinklistIds() public {
        // alice link a linklist
        vm.prank(alice);
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                Const.FIRST_CHARACTER_ID,
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        uint256[] memory linkingLinkListIds = linklist.getLinkingLinklistIds(2);
        assertEq(linkingLinkListIds.length, 1);
        assertEq(linkingLinkListIds[0], 1);
    }

    function testGetLinkingLinklistLength() public {
        // alice link a linklist
        vm.prank(alice);
        web3Entry.linkLinklist(
            DataTypes.linkLinklistData(
                Const.FIRST_CHARACTER_ID,
                1,
                Const.LikeLinkType,
                new bytes(0)
            )
        );

        uint256 length = linklist.getLinkingLinklistLength(2);
        assertEq(length, 1);
    }

    function testGetLinkType() public {
        bytes32 linkType = linklist.getLinkType(1);
        assertEq(linkType, Const.FollowLinkType);
    }

    function testUri() public {
        vm.prank(alice);
        linklist.setUri(1, Const.MOCK_NEW_TOKEN_URI);
        string memory uri = linklist.Uri(1);
        assertEq(uri, Const.MOCK_NEW_TOKEN_URI);
    }

    function testTotalSupply() public {
        // TODO add fuzz test
        uint256 totalSupply = linklist.totalSupply();
        assertEq(totalSupply, 1);
    }

    function testBalanceOf() public {
        uint256 balanceOfCharacter = linklist.balanceOf(1);
        assertEq(balanceOfCharacter, 1);

        uint256 balanceOfAddress = linklist.balanceOf(alice);
        assertEq(balanceOfAddress, 1);
    }
}
