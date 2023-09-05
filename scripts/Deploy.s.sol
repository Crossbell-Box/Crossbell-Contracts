// SPDX-License-Identifier: MIT
// solhint-disable no-console,ordering
pragma solidity 0.8.18;

import {Deployer} from "./Deployer.sol";
import {DeployConfig} from "./DeployConfig.s.sol";
import {MintNFT} from "../contracts/MintNFT.sol";
import {Web3Entry} from "../contracts/Web3Entry.sol";
import {Linklist} from "../contracts/Linklist.sol";
import {Periphery} from "../contracts/misc/Periphery.sol";
import {NewbieVilla} from "../contracts/misc/NewbieVilla.sol";
import {Tips} from "../contracts/misc/Tips.sol";
import {TipsWithFee} from "../contracts/misc/TipsWithFee.sol";
import {TipsWithConfig} from "../contracts/misc/TipsWithConfig.sol";
import {LimitedMintModule} from "../contracts/modules/mint/LimitedMintModule.sol";
import {ApprovalMintModule} from "../contracts/modules/mint/ApprovalMintModule.sol";
import {console2 as console} from "forge-std/console2.sol";
import {
    TransparentUpgradeableProxy
} from "../contracts/upgradeability/TransparentUpgradeableProxy.sol";

contract Deploy is Deployer {
    // solhint-disable private-vars-leading-underscore
    DeployConfig internal cfg;

    /// @notice Modifier that wraps a function in broadcasting.
    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    /// @notice The name of the script, used to ensure the right deploy artifacts
    ///         are used.
    function name() public pure override returns (string memory name_) {
        name_ = "Deploy";
    }

    function setUp() public override {
        super.setUp();
        string memory path = string.concat(
            vm.projectRoot(),
            "/deploy-config/",
            deploymentContext,
            ".json"
        );
        cfg = new DeployConfig(path);

        console.log("Deploying from %s", deployScript);
        console.log("Deployment context: %s", deploymentContext);
    }

    /* solhint-disable comprehensive-interface */
    function run() external {
        deployImplementations();

        deployProxies();

        initialize();

        // deploy mint modules
        deployApprovalMintModule();
        deployLimitedMintModule();
    }

    /// @notice Initialize all of the proxies
    function initialize() public {
        initializeWeb3Entry();
        initializeLinklist();
        initializePeriphery();
        initializeNewbieVilla();
        initializeTips();
        initializeTipsWithFee();
        initializeTipsWithConfig();
    }

    /// @notice Deploy all of the proxies
    function deployProxies() public {
        deployProxy("Web3Entry");
        deployProxy("Linklist");
        deployProxy("Periphery");
        deployProxy("NewbieVilla");
        deployProxy("Tips");
        deployProxy("TipsWithFee");
        deployProxy("TipsWithConfig");
    }

    /// @notice Deploy all of the logic contracts
    function deployImplementations() public {
        deployWeb3Entry();
        deployLinklist();
        deployPeriphery();

        deployMintNFTImpl();

        deployNewbieVilla();

        deployTips();
        deployTipsWithFee();
        deployTipsWithConfig();
    }

    function deployProxy(string memory _name) public broadcast returns (address addr_) {
        address logic = mustGetAddress(_stripSemver(_name));
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy({
            _logic: logic,
            admin_: cfg.proxyAdminOwner(),
            _data: ""
        });

        address admin = address(uint160(uint256(vm.load(address(proxy), OWNER_KEY))));
        require(admin == cfg.proxyAdminOwner(), "proxy admin assert error");

        string memory proxyName = string.concat(_name, "Proxy");
        save(proxyName, address(proxy));
        console.log("%s deployed at %s", proxyName, address(proxy));

        addr_ = address(proxy);
    }

    function deployWeb3Entry() public broadcast returns (address addr_) {
        Web3Entry web3Entry = new Web3Entry();

        save("Web3Entry", address(web3Entry));
        console.log("Web3Entry deployed at %s", address(web3Entry));
        addr_ = address(web3Entry);
    }

    function deployLinklist() public broadcast returns (address addr_) {
        Linklist linklist = new Linklist();

        save("Linklist", address(linklist));
        console.log("Linklist deployed at %s", address(linklist));
        addr_ = address(linklist);
    }

    function deployPeriphery() public broadcast returns (address addr_) {
        Periphery periphery = new Periphery();

        save("Periphery", address(periphery));
        console.log("Periphery deployed at %s", address(periphery));
        addr_ = address(periphery);
    }

    function deployNewbieVilla() public broadcast returns (address addr_) {
        NewbieVilla newbieVilla = new NewbieVilla();

        save("NewbieVilla", address(newbieVilla));
        console.log("NewbieVilla deployed at %s", address(newbieVilla));
        addr_ = address(newbieVilla);
    }

    function deployTips() public broadcast returns (address addr_) {
        Tips tips = new Tips();

        save("Tips", address(tips));
        console.log("Tips deployed at %s", address(tips));
        addr_ = address(tips);
    }

    function deployTipsWithFee() public broadcast returns (address addr_) {
        TipsWithFee tips = new TipsWithFee();

        save("TipsWithFee", address(tips));
        console.log("TipsWithFee deployed at %s", address(tips));
        addr_ = address(tips);
    }

    function deployTipsWithConfig() public broadcast returns (address addr_) {
        TipsWithConfig tips = new TipsWithConfig();

        save("TipsWithConfig", address(tips));
        console.log("TipsWithConfig deployed at %s", address(tips));
        addr_ = address(tips);
    }

    function deployMintNFTImpl() public broadcast returns (address addr_) {
        MintNFT nft = new MintNFT();

        save("MintNFT", address(nft));
        console.log("MintNFT deployed at %s", address(nft));
        addr_ = address(nft);
    }

    function deployApprovalMintModule() public broadcast returns (address addr_) {
        address web3EntryProxy = mustGetAddress("Web3EntryProxy");

        ApprovalMintModule module = new ApprovalMintModule(web3EntryProxy);

        save("ApprovalMintModule", address(module));
        console.log("ApprovalMintModule deployed at %s", address(module));
        addr_ = address(module);
    }

    function deployLimitedMintModule() public broadcast returns (address addr_) {
        address web3EntryProxy = mustGetAddress("Web3EntryProxy");

        LimitedMintModule module = new LimitedMintModule(web3EntryProxy);

        save("LimitedMintModule", address(module));
        console.log("LimitedMintModule deployed at %s", address(module));
        addr_ = address(module);
    }

    function initializeWeb3Entry() public broadcast {
        Web3Entry web3EntryProxy = Web3Entry(mustGetAddress("Web3EntryProxy"));
        address mintNFTImpl = mustGetAddress("MintNFT");
        address linklistProxy = mustGetAddress("LinklistProxy");
        address peripheryProxy = mustGetAddress("PeripheryProxy");
        address newbieVillaProxy = mustGetAddress("NewbieVillaProxy");

        web3EntryProxy.initialize(
            cfg.web3EntryTokenName(),
            cfg.web3EntryTokenSymbol(),
            linklistProxy,
            mintNFTImpl,
            peripheryProxy,
            newbieVillaProxy
        );
    }

    function initializeLinklist() public broadcast {
        Linklist linklistProxy = Linklist(mustGetAddress("LinklistProxy"));
        address web3EntryProxy = mustGetAddress("Web3EntryProxy");

        linklistProxy.initialize(
            cfg.linklistTokenName(),
            cfg.linklistTokenSymbol(),
            web3EntryProxy
        );
    }

    function initializePeriphery() public broadcast {
        Periphery peripheryProxy = Periphery(mustGetAddress("PeripheryProxy"));
        address web3EntryProxy = mustGetAddress("Web3EntryProxy");
        address linklistProxy = mustGetAddress("LinklistProxy");

        peripheryProxy.initialize(web3EntryProxy, linklistProxy);
    }

    function initializeNewbieVilla() public broadcast {
        NewbieVilla newbieVillaProxy = NewbieVilla(mustGetAddress("NewbieVillaProxy"));
        address web3EntryProxy = mustGetAddress("Web3EntryProxy");
        address tipsProxy = mustGetAddress("TipsProxy");

        newbieVillaProxy.initialize(
            web3EntryProxy,
            cfg.xsyncOperator(),
            cfg.miraToken(),
            cfg.newbieVillaAdmin(),
            tipsProxy
        );
    }

    function initializeTips() public broadcast {
        Tips tipsProxy = Tips(mustGetAddress("TipsProxy"));
        address web3EntryProxy = mustGetAddress("Web3EntryProxy");

        tipsProxy.initialize(web3EntryProxy, cfg.miraToken());
    }

    function initializeTipsWithFee() public broadcast {
        TipsWithFee tipsProxy = TipsWithFee(mustGetAddress("TipsWithFeeProxy"));
        address web3EntryProxy = mustGetAddress("Web3EntryProxy");

        tipsProxy.initialize(web3EntryProxy, cfg.miraToken());
    }

    function initializeTipsWithConfig() public broadcast {
        TipsWithConfig tipsProxy = TipsWithConfig(mustGetAddress("TipsWithConfigProxy"));
        address web3EntryProxy = mustGetAddress("Web3EntryProxy");

        tipsProxy.initialize(web3EntryProxy);
    }
}
