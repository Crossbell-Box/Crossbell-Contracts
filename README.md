# Crossbell

Crossbell is an **ownership** **platform** composed of

1. an EVM-compatible blockchain
2. a protocol implemented by a set of smart contracts

Specifically, the information generated from **social activities** will be the initial form of data-ownership by users on Crossbell.

This repository is the implementation of the protocol.

## Run

```shell
yarn
yarn test
```

## Protocol Overview

All social activities can be described as different **interactions** among different **instances**.

### Instances

Since Crossbell is EVM-compatible, two types of instances are inherited directly:

-   Crypto address
-   Asset (NFT/Cryptocurrency/...)

Though a crypto address is theoretically enough to recognize different identities. We always want a more well-rounded image in social activities, e.g, with a special avatar and more distinctive characters. Then we introduce another two instances in the Crossbell world:

-   Profile
-   Note

A profile is created and owned by some crypto address. The profile owner is free to post any notes under one of her profiles.

### Interaction

The most straightforward interaction along with social activities we can imagine might be “follow”. But absolutely there are numerous different types of interactions. For example,

-   profile1 “super follows” profile2
-   profile3 “dates” with profile4
-   note2 “comments” on note1
-   profile1 “shares” note1 (yes, interactions among different types of instances could also happen)
-   profile1 “blocks” address3
-   ......

All the above examples are common interactions in social activities. We generalize such interactions as “**link**” on Crossbell.

-   The linker could be a profile or a note
-   The link-ee could be any instance on Crossbell, or any arbitrary ones as long as with a URI.
-   Each link is attached with a type(e.g. `follow`, `comment`, ... ), suggesting the real meaning underneath.

|         | Ethereum address | Profile | Note | Asset on Crossbell(NFT/Cryptocurrency/...) | Any URI |
| ------- | ---------------- | ------- | ---- | ------------------------------------------ | ------- |
| Profile | L                | L       | L    | L                                          | L       |
| Note    | L                | L       | L    | L                                          | L       |

### Capitalization

We cannot deny that information capitalization is a reasonable demand. But it’s never easy to clearly draw a line between those supposed to be the native asset on Crossbell and those not. With multiple considerations, generally, we propose two types of information as native assets and one manual approach to capitalizing non-asset information.

**Profile**

Each profile is natively created to be an NFT.

**Linklist**

All the linking objects with the **same link type** and emitted from a **profile**, natively aggregate as an NFT.

capitalization principles should serve human intuitions. So we exclude the linking objects emitted from a **note** as native NFTs, which don’t aggregate as same meaningful and valuable information as those from a profile.

**Mint**

Besides the two native assets on Crossbell, there’s another approach called `Mint` to convert the non-NFT information to an NFT.

As we mentioned before, each profile as a whole is natively an NFT, but the note posted under the profile is not. To provide a manual approach to capitalize those valuable or memorable single notes, each crypto address could mint a note to receive an NFT. That mechanism is similar to buying a copy of a book.

### Modularity

As we discussed above, `instance`, `link`, and `mint` are created to help sketch the basics of social activities. For further flexibility and composability, there are two types of modules that can be configured on the action object.

-   Link Module
-   Mint Module

Each module is a standalone contract that adheres to a specific interface. The undetermined states within the contract hold unlimited potential. Once an instance is linked, the corresponding link module will be triggered. Once a note is minted, the corresponding mint module will be triggered. Take some examples,

-   Each profile could set a link module for itself: the first 1000 followers could get a special NFT.
-   Each profile owner could set a mint module for any of her notes: the minter should pay a specific amount of tokens.

Here we highlight one important difference between the link module and the mint module:

-   Link Module can not revert the link interaction.
-   Mint Module can revert the mint interaction.

`Link` is essentially to deliver some information within the context of social activities. How that information is finally disseminated could be the compromised result of complicated interactions. But the information self could whatever be permissionless published. So Link Module can not revert the link interaction.

Whereas mint is to generate a new asset, involving property rights or copyright, or whatever more complicated things. No means no in this case.
