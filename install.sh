#!/usr/bin/env bash
set -e

info="\033[0;32m==> info ]\033[0m"
warning="\033[0;33m==> warn ]\033[0m"
error="\033[0;31m==> error ]\033[0m"

check_root() {
  if [[ $EUID -ne 0 ]]; then
      echo -e "$error This script must be run as root\n$info You could also run: sudo $0" 1>&2
      exit 1
  fi
}

detect_osx_version() {
  result=`sw_vers -productVersion`

  if [[ $result =~ "10.7" ]]; then
      osxversion="10.7"
      osxvername="Lion"
      cltools=xcode46cltools_10_76938132a.dmg
      mountpath="/Volumes/Command Line Tools (Lion)"
      mpkg="Command Line Tools (Lion).mpkg"
      pkg_url="https://www.dropbox.com/s/fnqgdilm0yddfc0/xcode462_cltools_10_76938260a.dmg"
      pkgmd5="ca48a44bfbf61d0dce9692ba4edb204f"
      #downloaded from: https://developer.apple.com/downloads/
  elif [[ $result =~ "10.8" ]]; then
      osxversion="10.8"
      osxvername="Mountain Lion"
      cltools=xcode462_cltools_10_86938259a.dmg
      mountpath="/Volumes/Command Line Tools (Mountain Lion)"
      mpkg="Command Line Tools (Mountain Lion).mpkg"
      pkg_url="https://www.dropbox.com/s/hw45wvjxrkrl59x/xcode462_cltools_10_86938259a.dmg"
      pkgmd5="90c5db99a589c269efa542ff0272fc28"
      #downloaded from: https://developer.apple.com/downloads/
  else
      echo -e "$error This machine is running an unsupported version of OS X" 1>&2
      exit 1
  fi

  echo -e "$info Detected OS X $osxversion $osxvername"
}

check_tools() {
  RECEIPT_FILE=/var/db/receipts/com.apple.pkg.DeveloperToolsCLI.bom
  if [ -f "$RECEIPT_FILE" ]; then 
    echo -e "$info Command Line Tools are already installed. Exiting..." 
    exit 0
  fi
}

download_tools () {
  # Use wget to download the appropriate installer curl has some issues (or I couldn't find the flags :)
  if [ -f /tmp/$cltools ]; then
    # indirmd5=`md5 -q /tmp/$cltools`
    if [ `md5 -q /tmp/$cltools` = "${pkgmd5}" ]; then
      echo -e "$info $cltools already downloaded to /tmp/$cltools."
    else
       rm -f /tmp/$cltools
    fi
  else
    cd /tmp && wget $pkg_url -O ./$cltools
  fi
}

install_tools() {
  # Mount the Command Line Tools dmg
  echo -e "$info Mounting Command Line Tools..."
  hdiutil mount -nobrowse /tmp/$cltools
  # Run the Command Line Tools Installer
  echo -e "$info Installing Command Line Tools..."
  installer -pkg "$mountpath/$mpkg" -target "/Volumes/Macintosh HD"
  # Unmount the Command Line Tools dmg
  echo -e "$info Unmounting Command Line Tools..."
  hdiutil unmount "$mountpath"

  gcc_bin=`which gcc`
  gcc --version &>/dev/null && echo -e "$info gcc found in $gcc_bin"
}
 
cleanup () {
  rm /tmp/$cltools
  echo -e "$info Cleanup complete."
  exit 0
}

main() {
  check_root
  # Detect and set the version of OS X for the rest of the script
  detect_osx_version
  # Check for if tools are already installed by looking for a receipt file
  check_tools
  # Check for and if necessary download the required dmg
  download_tools
  # Start the appropriate installer for the correct version of OSX
  install_tools
  # Cleanup files used during script
  cleanup
}

main