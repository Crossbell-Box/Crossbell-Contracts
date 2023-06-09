// SPDX-License-Identifier: MIT
// solhint-disable comprehensive-interface
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Web3Entry} from "../../contracts/Web3Entry.sol";
import {Linklist} from "../../contracts/Linklist.sol";
import {DataTypes} from "../../contracts/libraries/DataTypes.sol";
import {Periphery} from "../../contracts/misc/Periphery.sol";
import {CharacterBoundToken} from "../../contracts/misc/CharacterBoundToken.sol";
import {NewbieVilla} from "../../contracts/misc/NewbieVilla.sol";
import {MiraToken} from "../../contracts/mocks/MiraToken.sol";
import {Tips} from "../../contracts/misc/Tips.sol";
import {MintNFT} from "../../contracts/MintNFT.sol";
import {
    TransparentUpgradeableProxy
} from "../../contracts/upgradeability/TransparentUpgradeableProxy.sol";
import {
    ApprovalLinkModule4Character
} from "../../contracts/modules/link/ApprovalLinkModule4Character.sol";
import {ApprovalMintModule} from "../../contracts/modules/mint/ApprovalMintModule.sol";
import {LimitedMintModule} from "../../contracts/modules/mint/LimitedMintModule.sol";
import {NFT, ERC1155} from "../../contracts/mocks/NFT.sol";
import {Utils} from "./Utils.sol";

contract CommonTest is Utils {
    Web3Entry public web3Entry;
    Linklist public linklist;
    Periphery public periphery;
    NewbieVilla public newbieVilla;
    MiraToken public token;
    Tips public tips;
    MintNFT public mintNFTImpl;
    ApprovalLinkModule4Character public linkModule4Character;
    ApprovalMintModule public approvalMintModule;
    LimitedMintModule public limitedMintModule;
    NFT public nft;
    CharacterBoundToken public cbt;
    TransparentUpgradeableProxy public proxyWeb3Entry;

    address public constant admin = address(0x999999999999999999999999999999);

    address public constant xsyncOperator = address(0xffff4444);
    uint256 public constant newbieAdminPrivateKey = 1;
    address public newbieAdmin = vm.addr(newbieAdminPrivateKey);
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 public constant alicePrivateKey = 0x1111;
    uint256 public constant bobPrivateKey = 0x2222;
    uint256 public constant carolPrivateKey = 0x3333;
    uint256 public constant dickPrivateKey = 0x4444;
    uint256 public constant erikPrivateKey = 0x5555;

    address public alice = vm.addr(alicePrivateKey);
    address public bob = vm.addr(bobPrivateKey);
    address public carol = vm.addr(carolPrivateKey);
    address public dick = vm.addr(dickPrivateKey);
    address public erik = vm.addr(erikPrivateKey);

    function _setUp() internal {
        // deploy erc1820
        vm.etch(
            address(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24),
            bytes( // solhint-disable-next-line max-line-length
                hex"608060405234801561001057600080fd5b50600436106100a5576000357c010000000000000000000000000000000000000000000000000000000090048063a41e7d5111610078578063a41e7d51146101d4578063aabbb8ca1461020a578063b705676514610236578063f712f3e814610280576100a5565b806329965a1d146100aa5780633d584063146100e25780635df8122f1461012457806365ba36c114610152575b600080fd5b6100e0600480360360608110156100c057600080fd5b50600160a060020a038135811691602081013591604090910135166102b6565b005b610108600480360360208110156100f857600080fd5b5035600160a060020a0316610570565b60408051600160a060020a039092168252519081900360200190f35b6100e06004803603604081101561013a57600080fd5b50600160a060020a03813581169160200135166105bc565b6101c26004803603602081101561016857600080fd5b81019060208101813564010000000081111561018357600080fd5b82018360208201111561019557600080fd5b803590602001918460018302840111640100000000831117156101b757600080fd5b5090925090506106b3565b60408051918252519081900360200190f35b6100e0600480360360408110156101ea57600080fd5b508035600160a060020a03169060200135600160e060020a0319166106ee565b6101086004803603604081101561022057600080fd5b50600160a060020a038135169060200135610778565b61026c6004803603604081101561024c57600080fd5b508035600160a060020a03169060200135600160e060020a0319166107ef565b604080519115158252519081900360200190f35b61026c6004803603604081101561029657600080fd5b508035600160a060020a03169060200135600160e060020a0319166108aa565b6000600160a060020a038416156102cd57836102cf565b335b9050336102db82610570565b600160a060020a031614610339576040805160e560020a62461bcd02815260206004820152600f60248201527f4e6f7420746865206d616e616765720000000000000000000000000000000000604482015290519081900360640190fd5b6103428361092a565b15610397576040805160e560020a62461bcd02815260206004820152601a60248201527f4d757374206e6f7420626520616e204552433136352068617368000000000000604482015290519081900360640190fd5b600160a060020a038216158015906103b85750600160a060020a0382163314155b156104ff5760405160200180807f455243313832305f4143434550545f4d4147494300000000000000000000000081525060140190506040516020818303038152906040528051906020012082600160a060020a031663249cb3fa85846040518363ffffffff167c01000000000000000000000000000000000000000000000000000000000281526004018083815260200182600160a060020a0316600160a060020a031681526020019250505060206040518083038186803b15801561047e57600080fd5b505afa158015610492573d6000803e3d6000fd5b505050506040513d60208110156104a857600080fd5b5051146104ff576040805160e560020a62461bcd02815260206004820181905260248201527f446f6573206e6f7420696d706c656d656e742074686520696e74657266616365604482015290519081900360640190fd5b600160a060020a03818116600081815260208181526040808320888452909152808220805473ffffffffffffffffffffffffffffffffffffffff19169487169485179055518692917f93baa6efbd2244243bfee6ce4cfdd1d04fc4c0e9a786abd3a41313bd352db15391a450505050565b600160a060020a03818116600090815260016020526040812054909116151561059a5750806105b7565b50600160a060020a03808216600090815260016020526040902054165b919050565b336105c683610570565b600160a060020a031614610624576040805160e560020a62461bcd02815260206004820152600f60248201527f4e6f7420746865206d616e616765720000000000000000000000000000000000604482015290519081900360640190fd5b81600160a060020a031681600160a060020a0316146106435780610646565b60005b600160a060020a03838116600081815260016020526040808220805473ffffffffffffffffffffffffffffffffffffffff19169585169590951790945592519184169290917f605c2dbf762e5f7d60a546d42e7205dcb1b011ebc62a61736a57c9089d3a43509190a35050565b600082826040516020018083838082843780830192505050925050506040516020818303038152906040528051906020012090505b92915050565b6106f882826107ef565b610703576000610705565b815b600160a060020a03928316600081815260208181526040808320600160e060020a031996909616808452958252808320805473ffffffffffffffffffffffffffffffffffffffff19169590971694909417909555908152600284528181209281529190925220805460ff19166001179055565b600080600160a060020a038416156107905783610792565b335b905061079d8361092a565b156107c357826107ad82826108aa565b6107b85760006107ba565b815b925050506106e8565b600160a060020a0390811660009081526020818152604080832086845290915290205416905092915050565b6000808061081d857f01ffc9a70000000000000000000000000000000000000000000000000000000061094c565b909250905081158061082d575080155b1561083d576000925050506106e8565b61084f85600160e060020a031961094c565b909250905081158061086057508015155b15610870576000925050506106e8565b61087a858561094c565b909250905060018214801561088f5750806001145b1561089f576001925050506106e8565b506000949350505050565b600160a060020a0382166000908152600260209081526040808320600160e060020a03198516845290915281205460ff1615156108f2576108eb83836107ef565b90506106e8565b50600160a060020a03808316600081815260208181526040808320600160e060020a0319871684529091529020549091161492915050565b7bffffffffffffffffffffffffffffffffffffffffffffffffffffffff161590565b6040517f01ffc9a7000000000000000000000000000000000000000000000000000000008082526004820183905260009182919060208160248189617530fa90519096909550935050505056fea165627a7a72305820377f4a2d4301ede9949f163f319021a6e9c687c292a5e2b2c4734c126b524e6c0029"
            )
        );

        // deploy web3Entry related contracts
        _deployContracts();

        // initialize
        _initialize();
    }

    function _deployContracts() internal {
        // deploy mintNFT
        mintNFTImpl = new MintNFT();

        // deploy web3Entry
        Web3Entry web3EntryImpl = new Web3Entry();
        proxyWeb3Entry = new TransparentUpgradeableProxy(address(web3EntryImpl), admin, "");
        web3Entry = Web3Entry(address(proxyWeb3Entry));

        // deploy Linklist
        Linklist linklistImpl = new Linklist();
        TransparentUpgradeableProxy proxyLinklist = new TransparentUpgradeableProxy(
            address(linklistImpl),
            admin,
            ""
        );
        linklist = Linklist(address(proxyLinklist));

        // deploy periphery
        periphery = new Periphery();

        // deploy newbieVilla
        newbieVilla = new NewbieVilla();

        // deploy tips
        tips = new Tips();

        // deploy token
        token = new MiraToken("Mira Token", "MIRA", address(this));

        // deploy linkModule4Character
        linkModule4Character = new ApprovalLinkModule4Character(address(web3Entry));
        // deploy mintModule4Note
        approvalMintModule = new ApprovalMintModule(address(web3Entry));
        limitedMintModule = new LimitedMintModule(address(web3Entry));

        // deploy cbt
        cbt = new CharacterBoundToken(address(web3Entry));
    }

    function _initialize() internal {
        // initialize web3Entry
        web3Entry.initialize(
            WEB3_ENTRY_NFT_NAME,
            WEB3_ENTRY_NFT_SYMBOL,
            address(linklist),
            address(mintNFTImpl),
            address(periphery),
            address(newbieVilla)
        );
        // initialize linklist
        linklist.initialize(LINK_LIST_NFT_NAME, LINK_LIST_NFT_SYMBOL, address(web3Entry));
        // initialize periphery
        periphery.initialize(address(web3Entry), address(linklist));

        // initialize newbieVilla
        newbieVilla.initialize(
            address(web3Entry),
            xsyncOperator,
            address(token),
            newbieAdmin,
            address(tips)
        );
        vm.prank(newbieAdmin);
        newbieVilla.grantRole(ADMIN_ROLE, newbieAdmin);

        // initialize tips
        tips.initialize(address(web3Entry), address(token));

        // deploy NFT for test
        nft = new NFT();
        nft.initialize("NFT", "NFT");
    }

    function _createCharacter(string memory handle, address to) internal {
        web3Entry.createCharacter(makeCharacterData(handle, to));
    }

    function _mintNote(
        uint256 characterId,
        uint256 noteId,
        address to,
        bytes memory data
    ) internal {
        web3Entry.mintNote(DataTypes.MintNoteData(characterId, noteId, to, data));
    }

    function _postNote(uint256 characterId, string memory noteUri) internal {
        web3Entry.postNote(
            DataTypes.PostNoteData(
                characterId,
                noteUri,
                address(0x0),
                new bytes(0),
                address(0),
                "",
                false
            )
        );
    }

    function _postNoteWithMintModule(
        uint256 characterId,
        string memory noteUri,
        address mintModule,
        bytes memory initData
    ) internal {
        web3Entry.postNote(
            DataTypes.PostNoteData(
                characterId,
                noteUri,
                address(0x0),
                new bytes(0),
                mintModule,
                initData,
                false
            )
        );
    }
}
