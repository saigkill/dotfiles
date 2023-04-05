#!/usr/bin/env bash
#
# dotfiles : https://github.com/saigkill/dotfiles
#
# Script to bootstrap a linux box
#
# Authors:
#   Sascha Manns <Sascha.Manns@outlook.de>
#

if [[ "$OSTYPE" != "linux"* ]]; then
  echo "$0 : Will only run on Linux"
  exit 1
fi

# Some variables
distro=$(cat /etc/os-release | grep ^NAME= | cut -c7- | sed 's/"//')
os_version=$( cat /etc/os-release | grep "VERSION_ID" | cut -d= -f2 | sed 's/"//g')
dotnet_sdk="7.0"
hostname=`hostname`
DIR=$(cd $(dirname "$0"); pwd)

echo "Detected $distro $os_version"
echo "Hostname: $hostname"
echo "Dotnet SDK: $dotnet_sdk"

echo "Would you like to continue? (y/n)"
read -p "$* [y/n]: " yn
case $yn in
  [Yy]*) echo "Working around" ;;
  [Nn]*) exit ;;
esac

if [[ "$distro" == "Pengwin" ]]; then
  echo "Would you like to initialize Pengwin? (y/n)"
  read -p "$* [y/n]: " yn
  case $yn in
  [Yy]*) pengwin-setup ;;
  [Nn]*) return 0 ;;
esac
fi

###############################################################################
# Repositories
###############################################################################
echo "Adding repositories"
if [[ "$distro" == "Pengwin" || "$distro" == "Debian" || "$distro" == "Kali GNU/Linux" ]]; then
  wget https://packages.microsoft.com/config/debian/$os_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
fi
echo "Added Microsoft repository"

###############################################################################
# apt-get
###############################################################################

echo "Updating via apt-get"
sudo apt-get update
sudp apt-get upgrade

echo "Installing packages via apt-get"
if [[ -f $DIR/packages/apt ]]; then
  exec<$DIR/packages/apt
  while read line
  do
    if [[ ! "$line" =~ (^#|^$) ]]; then
      packages="$packages $line"
    fi
  done
  sudo apt-get install $packages
fi

###############################################################################
# Additional
###############################################################################
echo "Installing additional packages"

echo "Installing Awesome Windows Terminal Fonts"
if [[ "$distro" == "Pengwin" || "$distro" == "Debian" || "$distro" == "Kali GNU/Linux" ]]; then
  awesomedir='../awesome-windows-terminal-fonts'
  $awesomedir/install.sh
fi

echo "Installing Postman"
if [[ "$distro" == "Pengwin" || "$distro" == "Debian" || "$distro" == "Kali GNU/Linux" ]]; then
  wget https://dl.pstmn.io/download/latest/linux_64 -O postman.tar.gz
  tar -xzf postman.tar.gz
  sudo mv Postman /opt
  rm postman.tar.gz
fi

echo "Installing Keybase"
if [[ "$distro" == "Pengwin" || "$distro" == "Debian" || "$distro" == "Kali GNU/Linux" ]]; then
  curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
  sudo apt install ./keybase_amd64.deb
  run_keybase
fi

echo "Installing Topgrade"
if [[ "$distro" == "Pengwin" || "$distro" == "Debian" || "$distro" == "Kali GNU/Linux" ]]; then
  TOPGRADE_VERSION=$(curl -s "https://api.github.com/repos/topgrade-rs/topgrade/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  wget https://github.com/topgrade-rs/topgrade/releases/download/$TOPGRADE_VERSION/topgrade-$TOPGRADE_VERSION-x86_64-unknown-linux-musl.tar.gz
  tar xvfz topgrade-$TOPGRADE_VERSION-x86_64-unknown-linux-musl.tar.gz
  sudo mv topgrade /usr/local/bin
  rm topgrade-$TOPGRADE_VERSION-x86_64-unknown-linux-musl.tar.gz
fi

echo "Installing Github CLI"
if [[ "$distro" == "Pengwin" || "$distro" == "Debian" || "$distro" == "Kali GNU/Linux" ]]; then
	type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
fi

###############################################################################
# Homebrew
# This step expects a running homebrew installation (like in pengwin-setup
###############################################################################
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "Installing packages via brew"
if [[ -f $DIR/packages/brew ]]; then
  exec<$DIR/packages/brew
  while read line
  do
    if [[ ! "$line" =~ (^#|^$) ]]; then
      packages="$packages $line"
    fi
  done
  brew install $packages
fi

###############################################################################
# Tpgrade
###############################################################################
echo "Running Topgrade"
topgrade

###############################################################################
# ZSH
###############################################################################
echo "Initializing zsh"
zsh

chsh -s $(which zsh) # Change default shell to zsh

echo "Deploying Linux on APT is done!"
