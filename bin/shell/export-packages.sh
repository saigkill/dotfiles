#!/bin/bash
# (c) 2016 Sascha Manns <Sascha.Manns@outlook.de>
# This script creates a list of all packages (Debian based) and GPG keys for a exact replication on another Debian based distro.
# TODO: Add ssh id_rsa

mkdir ~/export
pushd ~/export

usage() {
	echo "usage: $0 [-b] [-r] ..."
	echo
	echo "Optionen:"
	echo "-b : Backup packages"
	echo "-r : Restore packages"
}

case "$1" in
	-b)
		echo "*** Paketliste ***"
		echo "Erstelle Paketliste zur Wiederherstellung ..."
		sudo dpkg --get-selections | awk '!/deinstall|purge|hold/ {print $1}' > packages.list
		echo "Paketliste erstellt"

		echo "*** Paketstatus ***"
		echo "Erstelle erweiterten Paketstatus ..."
		sudo apt-mark showauto > package-states-auto
		sudo apt-mark showmanual > package-states-manual 
		echo "Paketstatus erstellt"

		echo "*** Paketquellen ***"
		echo "Paketquellen sichern ..."
		sudo find /etc/apt/sources.list* -type f -name '*.list' -exec bash -c 'echo -e "\n## $1 ";grep "^[[:space:]]*[^#[:space:]]" ${1}' _ {} \; > sources.list.save 
		echo "Paketquellen gesichert"

		echo "*** Schlüsselbund ***"
		echo "Erstelle Schlüsselbund der vertrauenswürdigen Schlüssel..."
		sudo cp /etc/apt/trusted.gpg trusted-keys.gpg 
		sudo cp -R /etc/apt/trusted.gpg.d trusted.gpg.d.save
		echo "Schlüsselbund erstellt"
	
		;;

	-r)
		echo "*** Schlüsselbund ***"
		echo "Importiere Schlüsselbund..."
		sudo apt-key add trusted-keys.gpg
		sudo apt-get update
		echo "Schlüsselbund importiert"

		echo "*** Paketliste ***"
		echo "Paketliste aus früherer Version importieren..."
		xargs -a "packages.list" sudo apt-get install
		echo "Paketliste importiert"

		echo "*** Paketstatus ***"
		echo "Paketstatus aus früherer Version importieren..."
		xargs -a "package-states-auto" sudo apt-mark auto
		xargs -a "package-states-manual" sudo apt-mark manual 
		echo "Paketstatus importiert" 
		;;
	*)
		usage
		exit 1
esac

popd
exit 0
