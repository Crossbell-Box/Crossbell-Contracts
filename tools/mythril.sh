#!/usr/bin/env bash
#set -x

if [ ! -d "contracts" ]; then
	echo "error: script needs to be run from project root './tools/mythril.sh'"
	exit 1
fi

echo '
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Web3Entry: "
myth analyze contracts/Web3Entry.sol --solc-json mythril.config.json --solv 0.8.18 --max-depth 10 --execution-timeout 900  --solver-timeout 900 &&
echo "NewbieVilla: "
myth analyze contracts/misc/NewbieVilla.sol --solc-json mythril.config.json --solv 0.8.18 --max-depth 10 --execution-timeout 900  --solver-timeout 900 &&
echo "Tips: "
myth analyze contracts/misc/Tips.sol --solc-json mythril.config.json --solv 0.8.18 --max-depth 10 --execution-timeout 900  --solver-timeout 900 &&
echo "TipsWithFee: "
myth analyze contracts/misc/TipsWithFee.sol --solc-json mythril.config.json --solv 0.8.18 --max-depth 10 --execution-timeout 900  --solver-timeout 900 &&
echo "TipsWithConfig: "
myth analyze contracts/misc/TipsWithConfig.sol --solc-json mythril.config.json --solv 0.8.18 --max-depth 10 --execution-timeout 900  --solver-timeout 900 &&
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" ' |
docker run --rm -v "$PWD":/project -i --workdir=/project --entrypoint=sh mythril/myth