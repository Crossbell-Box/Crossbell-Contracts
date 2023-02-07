#!/usr/bin/env bash
set -x

if [ ! -d "contracts" ]; then
	echo "error: script needs to be run from project root './tools/manticore/manticore.sh'"
	exit 1
fi

# flatten
yarn
mkdir -p flattened
#forge flatten contracts/Web3Entry.sol -o ./flattened/Web3Entry.sol
#forge flatten contracts/Linklist.sol -o ./flattened/Linklist.sol
#forge flatten contracts/MintNFT.sol -o ./flattened/MintNFT.sol
forge flatten contracts/misc/Tips.sol -o ./flattened/Tips.sol
#forge flatten contracts/misc/NewbieVilla.sol -o ./flattened/NewbieVilla.sol

# run check
# run check
echo '
pip3 install solc-select && solc-select install 0.8.16 && solc-select use 0.8.16 && cd /project &&
pip3 install crytic-compile==0.2.2 &&
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Tips: "
manticore ./flattened/Tips.sol --contract=Tips --config=tools/manticore/manticore.yaml &&
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" ' |
docker run --rm -v "$PWD":/project -i --ulimit stack=100000000:100000000 --entrypoint=sh  trailofbits/manticore