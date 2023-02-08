#!/usr/bin/env bash
set -x

if [ ! -d "contracts" ]; then
	echo "error: script needs to be run from project root './tools/checkStorageLayout.sh'"
	exit 1
fi

for contract in Web3Entry Tips NewbieVilla
do
  file=$(mktemp /tmp/crossbell-contracts-storage-layout.XXXXX) || exit 2
  forge inspect ${contract} storage-layout --pretty > ${file} || exit 3

  diff ${file} ./tools/storageLayout/${contract}-storage-layout.txt
done