#!/usr/bin/env bash

set -x

# To load the variables in the .env file
source .env

echo $PWD
# To deploy and verify our contract
forge script scripts/MarketPlace.s.sol:MarketPlaceScript --rpc-url $RINKEBY_RPC_URL  --private-key $PRIVATE_KEY --broadcast -vvvv