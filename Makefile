# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

all: clean install build foundry-test

# Install proper solc version.
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_10

# Clean the repo
clean  :; forge clean

# Install the Modules
install :; forge install 

# Update Dependencies
update:; forge update

# Builds
build  :; forge build

# chmod scripts
scripts :; chmod +x ./scripts/*

# Tests
# --ffi # enable if you need the `ffi` cheat code on HEVM
foundry-test :; forge clean && forge test --optimize --optimizer-runs 200 -v

# Run solhint
solhint :; solhint -f table "{contracts,test,scripts}/**/*.sol"

# slither
# to install slither, visit [https://github.com/crytic/slither]
slither :; slither . --fail-low #--triage-mode

# mythril
mythril :
	@echo " > \033[32mChecking contracts with mythril...\033[0m"
	./tools/mythril.sh

mythx :
	@echo " > \033[32mChecking contracts with mythx...\033[0m"
	mythx analyze

manticore :
	@echo " > \033[32mChecking contracts with manticore...\033[0m"
	./tools/manticore/manticore.sh

# upgradeable check
upgradeable:
	@echo " > \033[32mChecking upgradeable...\033[0m"
	./tools/checkUpgradeable.sh

# check upgradeable contract storage layout
storage-layout:
	@echo " > \033[32mChecking contract storage layout...\033[0m"
	./tools/checkStorageLayout.sh

# Lints
lint :; forge fmt && npx prettier --write "test/**/*.ts"

# Generate Gas Snapshots
snapshot :; forge clean && forge snapshot
