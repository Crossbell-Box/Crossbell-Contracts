#!/usr/bin/env bash

set -x

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script scripts/MarketPlace.s.sol:MarketPlaceScript ---rpc-url $CROSSBELL_RPC  --private-key $PRIVATE_KEY --broadcast -vvv
