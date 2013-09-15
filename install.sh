#!/usr/bin/env bash
set -e

info()  { echo -e "[\033[0;32m info  \033[0m] ${*}" ; }
warn()  { echo -e "[\033[0;33m warn  \033[0m] ${*}" ; }
error() { echo -e "[\033[0;31m error \033[0m] ${*}" ; }
fatal() { error $* 1>&2 ; exit 1 ; }

check_root() {
  if [[ $EUID -ne 0 ]]; then
    fatal "This script must be run as root\n$info You could also run: sudo $0"
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
    fatal "This machine is running an unsupported version of OS X"
  fi

  info "Detected OS X $osxversion $osxvername"
}

check_tools() {
  RECEIPT_FILE=/var/db/receipts/com.apple.pkg.DeveloperToolsCLI.bom
  if [ -f "$RECEIPT_FILE" ]; then
    info "Command Line Tools are already installed. Exiting..."
    exit 0
  fi
}

verify_download() {
  if [ -f /tmp/$cltools ]; then
    if [ `md5 -q /tmp/$cltools` = "${pkgmd5}" ]; then
      info "$cltools checksum verified"
    else
      warn "/tmp/$cltools checksum is invalid, retrying download"
      rm -f /tmp/$cltools
      download_tools
    fi
  else
    download_tools
  fi
}

download_tools () {
  info "Downloading $cltools"
  curl -L -s $pkg_url > /tmp/$cltools
  verify_download
}

main_volume_name() {
  # The main volume is typically, but not necessarily called '/Volumes/Macintosh HD'
  root_disk=$(df -l /|tail -1|cut -d' ' -f1)
  volume_name=$(diskutil info $root_disk | grep 'Volume Name' | sed 's/.*Name: *//')
  [[ -z "$volume_name" ]] && fatal "Failed to locate main HD volume"
  [[ ! -d "/Volumes/$volume_name" ]] && fatal "Something went wrong, $volume_name is not a directory"
  echo "/Volumes/$volume_name"
}

install_tools() {
  # Mount the Command Line Tools dmg
  info "Mounting Command Line Tools"
  hdiutil mount -nobrowse /tmp/$cltools
  # Run the Command Line Tools Installer
  info "Installing Command Line Tools"
  installer -pkg "$mountpath/$mpkg" -target "$(main_volume_name)"
  # Unmount the Command Line Tools dmg
  info "Unmounting Command Line Tools"
  hdiutil unmount "$mountpath"

  gcc_bin=`which gcc`
  gcc --version &>/dev/null && echo -e "$info gcc found in $gcc_bin"
}

cleanup () {
  rm /tmp/$cltools
  info "Cleanup complete."
  exit 0
}

main() {
  check_root
  # Detect and set the version of OS X for the rest of the script
  detect_osx_version
  # Check for if tools are already installed by looking for a receipt file
  check_tools
  # Check for and if necessary download the required dmg
  verify_download
  # Start the appropriate installer for the correct version of OSX
  install_tools
  # Cleanup files used during script
  cleanup
}

main
