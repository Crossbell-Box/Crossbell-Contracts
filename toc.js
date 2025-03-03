// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item "><a href="index.html">Home</a></li><li class="chapter-item affix "><li class="part-title">contracts</li><li class="chapter-item "><a href="contracts/base/index.html">❱ base</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/base/ERC721.sol/contract.ERC721.html">ERC721</a></li><li class="chapter-item "><a href="contracts/base/ERC721Enumerable.sol/abstract.ERC721Enumerable.html">ERC721Enumerable</a></li><li class="chapter-item "><a href="contracts/base/LinklistBase.sol/abstract.LinklistBase.html">LinklistBase</a></li><li class="chapter-item "><a href="contracts/base/NFTBase.sol/abstract.NFTBase.html">NFTBase</a></li></ol></li><li class="chapter-item "><a href="contracts/interfaces/index.html">❱ interfaces</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/interfaces/IERC20Mintable.sol/interface.IERC20Mintable.html">IERC20Mintable</a></li><li class="chapter-item "><a href="contracts/interfaces/ILinkModule.sol/interface.ILinkModule.html">ILinkModule</a></li><li class="chapter-item "><a href="contracts/interfaces/ILinkModule4Address.sol/interface.ILinkModule4Address.html">ILinkModule4Address</a></li><li class="chapter-item "><a href="contracts/interfaces/ILinkModule4Character.sol/interface.ILinkModule4Character.html">ILinkModule4Character</a></li><li class="chapter-item "><a href="contracts/interfaces/ILinkModule4ERC721.sol/interface.ILinkModule4ERC721.html">ILinkModule4ERC721</a></li><li class="chapter-item "><a href="contracts/interfaces/ILinkModule4Linklist.sol/interface.ILinkModule4Linklist.html">ILinkModule4Linklist</a></li><li class="chapter-item "><a href="contracts/interfaces/ILinkModule4Note.sol/interface.ILinkModule4Note.html">ILinkModule4Note</a></li><li class="chapter-item "><a href="contracts/interfaces/ILinklist.sol/interface.ILinklist.html">ILinklist</a></li><li class="chapter-item "><a href="contracts/interfaces/IMintModule4Note.sol/interface.IMintModule4Note.html">IMintModule4Note</a></li><li class="chapter-item "><a href="contracts/interfaces/IMintNFT.sol/interface.IMintNFT.html">IMintNFT</a></li><li class="chapter-item "><a href="contracts/interfaces/ITipsWithConfig.sol/interface.ITipsWithConfig.html">ITipsWithConfig</a></li><li class="chapter-item "><a href="contracts/interfaces/ITipsWithFee.sol/interface.ITipsWithFee.html">ITipsWithFee</a></li><li class="chapter-item "><a href="contracts/interfaces/IWeb3Entry.sol/interface.IWeb3Entry.html">IWeb3Entry</a></li></ol></li><li class="chapter-item "><a href="contracts/libraries/index.html">❱ libraries</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/libraries/CharacterLib.sol/library.CharacterLib.html">CharacterLib</a></li><li class="chapter-item "><a href="contracts/libraries/Constants.sol/library.Constants.html">Constants</a></li><li class="chapter-item "><a href="contracts/libraries/DataTypes.sol/library.DataTypes.html">DataTypes</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrCharacterNotExists.html">ErrCharacterNotExists</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNotAddressOwner.html">ErrNotAddressOwner</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNotCharacterOwner.html">ErrNotCharacterOwner</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNoteLocked.html">ErrNoteLocked</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrHandleExists.html">ErrHandleExists</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrSocialTokenExists.html">ErrSocialTokenExists</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrHandleLengthInvalid.html">ErrHandleLengthInvalid</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrHandleContainsInvalidCharacters.html">ErrHandleContainsInvalidCharacters</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNotEnoughPermission.html">ErrNotEnoughPermission</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNotEnoughPermissionForThisNote.html">ErrNotEnoughPermissionForThisNote</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrTargetAlreadyHasPrimaryCharacter.html">ErrTargetAlreadyHasPrimaryCharacter</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNoteIsDeleted.html">ErrNoteIsDeleted</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNoteNotExists.html">ErrNoteNotExists</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrArrayLengthMismatch.html">ErrArrayLengthMismatch</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrCallerNotWeb3Entry.html">ErrCallerNotWeb3Entry</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrCallerNotWeb3EntryOrNotOwner.html">ErrCallerNotWeb3EntryOrNotOwner</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrTokenIdAlreadyExists.html">ErrTokenIdAlreadyExists</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNotExistingCharacter.html">ErrNotExistingCharacter</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNotExistingLinklistToken.html">ErrNotExistingLinklistToken</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrInvalidWeb3Entry.html">ErrInvalidWeb3Entry</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNotApprovedOrExceedApproval.html">ErrNotApprovedOrExceedApproval</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrExceedMaxSupply.html">ErrExceedMaxSupply</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrExceedApproval.html">ErrExceedApproval</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrSignatureExpired.html">ErrSignatureExpired</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrSignatureInvalid.html">ErrSignatureInvalid</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrNotOwner.html">ErrNotOwner</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrTokenNotExists.html">ErrTokenNotExists</a></li><li class="chapter-item "><a href="contracts/libraries/Error.sol/error.ErrLinkTypeExists.html">ErrLinkTypeExists</a></li><li class="chapter-item "><a href="contracts/libraries/Events.sol/library.Events.html">Events</a></li><li class="chapter-item "><a href="contracts/libraries/LinkLib.sol/library.LinkLib.html">LinkLib</a></li><li class="chapter-item "><a href="contracts/libraries/LinklistLib.sol/library.LinklistLib.html">LinklistLib</a></li><li class="chapter-item "><a href="contracts/libraries/MetaTxLib.sol/library.MetaTxLib.html">MetaTxLib</a></li><li class="chapter-item "><a href="contracts/libraries/OP.sol/library.OP.html">OP</a></li><li class="chapter-item "><a href="contracts/libraries/OperatorLib.sol/library.OperatorLib.html">OperatorLib</a></li><li class="chapter-item "><a href="contracts/libraries/PostLib.sol/library.PostLib.html">PostLib</a></li><li class="chapter-item "><a href="contracts/libraries/StorageLib.sol/library.StorageLib.html">StorageLib</a></li><li class="chapter-item "><a href="contracts/libraries/ValidationLib.sol/library.ValidationLib.html">ValidationLib</a></li></ol></li><li class="chapter-item "><a href="contracts/misc/index.html">❱ misc</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/misc/CharacterBoundToken.sol/contract.CharacterBoundToken.html">CharacterBoundToken</a></li><li class="chapter-item "><a href="contracts/misc/NewbieVilla.sol/contract.NewbieVilla.html">NewbieVilla</a></li><li class="chapter-item "><a href="contracts/misc/Periphery.sol/contract.Periphery.html">Periphery</a></li><li class="chapter-item "><a href="contracts/misc/Tips.sol/contract.Tips.html">Tips</a></li><li class="chapter-item "><a href="contracts/misc/TipsWithConfig.sol/contract.TipsWithConfig.html">TipsWithConfig</a></li><li class="chapter-item "><a href="contracts/misc/TipsWithFee.sol/contract.TipsWithFee.html">TipsWithFee</a></li></ol></li><li class="chapter-item "><a href="contracts/mocks/index.html">❱ mocks</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/mocks/linkModule/index.html">❱ linkModule</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/mocks/linkModule/ApprovalLinkModule4Character.sol/contract.ApprovalLinkModule4Character.html">ApprovalLinkModule4Character</a></li><li class="chapter-item "><a href="contracts/mocks/linkModule/ApprovalLinkModule4Note.sol/contract.ApprovalLinkModule4Note.html">ApprovalLinkModule4Note</a></li></ol></li><li class="chapter-item "><a href="contracts/mocks/Currency.sol/contract.Currency.html">Currency</a></li><li class="chapter-item "><a href="contracts/mocks/ERC1271WalletMock.sol/contract.ERC1271WalletMock.html">ERC1271WalletMock</a></li><li class="chapter-item "><a href="contracts/mocks/ERC1271WalletMock.sol/contract.ERC1271MaliciousMock.html">ERC1271MaliciousMock</a></li><li class="chapter-item "><a href="contracts/mocks/MiraToken.sol/contract.MiraToken.html">MiraToken</a></li><li class="chapter-item "><a href="contracts/mocks/NFT.sol/contract.NFT.html">NFT</a></li><li class="chapter-item "><a href="contracts/mocks/NFT.sol/contract.NFT1155.html">NFT1155</a></li></ol></li><li class="chapter-item "><a href="contracts/modules/index.html">❱ modules</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/modules/mint/index.html">❱ mint</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/modules/mint/ApprovalMintModule.sol/contract.ApprovalMintModule.html">ApprovalMintModule</a></li><li class="chapter-item "><a href="contracts/modules/mint/FeeMintModule.sol/struct.CharacterNoteData.html">CharacterNoteData</a></li><li class="chapter-item "><a href="contracts/modules/mint/FeeMintModule.sol/contract.FeeMintModule.html">FeeMintModule</a></li><li class="chapter-item "><a href="contracts/modules/mint/LimitedMintModule.sol/contract.LimitedMintModule.html">LimitedMintModule</a></li></ol></li><li class="chapter-item "><a href="contracts/modules/ModuleBase.sol/abstract.ModuleBase.html">ModuleBase</a></li></ol></li><li class="chapter-item "><a href="contracts/storage/index.html">❱ storage</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/storage/LinklistExtendStorage.sol/contract.LinklistExtendStorage.html">LinklistExtendStorage</a></li><li class="chapter-item "><a href="contracts/storage/LinklistStorage.sol/contract.LinklistStorage.html">LinklistStorage</a></li><li class="chapter-item "><a href="contracts/storage/Web3EntryExtendStorage.sol/contract.Web3EntryExtendStorage.html">Web3EntryExtendStorage</a></li><li class="chapter-item "><a href="contracts/storage/Web3EntryStorage.sol/contract.Web3EntryStorage.html">Web3EntryStorage</a></li></ol></li><li class="chapter-item "><a href="contracts/upgradeability/index.html">❱ upgradeability</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/upgradeability/TransparentUpgradeableProxy.sol/contract.TransparentUpgradeableProxy.html">TransparentUpgradeableProxy</a></li></ol></li><li class="chapter-item "><a href="contracts/Linklist.sol/contract.Linklist.html">Linklist</a></li><li class="chapter-item "><a href="contracts/MintNFT.sol/contract.MintNFT.html">MintNFT</a></li><li class="chapter-item "><a href="contracts/Web3Entry.sol/contract.Web3Entry.html">Web3Entry</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
