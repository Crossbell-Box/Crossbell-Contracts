#!/usr/bin/env bash

set -x

# First, start Anvil:
# anvil

# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script scripts/MarketPlace.s.sol:MarketPlaceScript --fork-url http://localhost:8545  --private-key $PRIVATE_KEY_LOCAL --broadcast -vvvvv
