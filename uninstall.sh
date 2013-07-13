#!/usr/bin/env bash
set -e
info="\033[0;32m==> info ]\033[0m"
warning="\033[0;33m==> warn ]\033[0m"
error="\033[0;31m==> error ]\033[0m"

check_root() {
  if [[ $EUID -ne 0 ]]; then
      echo -e "$error This script must be run as root
      You could also run:
      sudo $0" 1>&2
      exit 1
  fi
}

is_tools_avail? () {
	RECEIPT_FILE=/var/db/receipts/com.apple.pkg.DeveloperToolsCLI.bom
	RECEIPT_PLIST=/var/db/receipts/com.apple.pkg.DeveloperToolsCLI.plist
	 
	if [ ! -f "$RECEIPT_FILE" ]; then
	  echo -e "$info Command Line Tools not installed."
	  local result=0
	else
		local result=1
	fi
	return $result
}

main() {
	if ! is_tools_avail?; then 
	  echo -e "$info Command Line Tools installed\n\t(found $RECEIPT_FILE)"
	  check_root
	  cd /
	  # Remove files and dirs mentioned in the "Bill of Materials" (BOM)
	  lsbom -fls $RECEIPT_FILE | sudo xargs -I{} rm -r "{}"
	 
	  # remove the receipt & plist
	  sudo rm $RECEIPT_FILE
	  sudo rm $RECEIPT_PLIST

	  # conclude
	  echo -e "$info Done! Command Line Tools appear as uninstalled."
	fi  
	exit 0
}

main