#!/bin/bash

CONFIG=/boot/config.txt
CONFIG_BACKUP=false
declare -a PkgArray=("lightdm")


# Check ob Programm als root ausgefuehrt wird
user_check() {
	if [ $(id -u) -ne 0 ]; then
		printf "Script muss mit root ausgefuehrt werden. Versuche 'sudo ./install.sh'\n"
		exit 1				# Beende Programm
	fi
}

# Bestaetige Installation
confirm() {
	# Einlesen der Commandozeile
	read -r -p "Sind Sie sicher? [y/n]" response < /dev/tty

	# Vergleich ob bestaetigt wurde
	if [[ $response =~ ^(yes|Y|y|ja|j|J)$ ]]; then
		printf "Installation wird ausgefuehrt\n"
	else
		printf "Abbruch der Installation\n"
		exit 1	# Installation abbrechen
	fi

	# Zusaetzliche Zeile
	echo
}

user_check
printf "Installation vom AudiPi wird gestartet\n"

confirm

#apt update && apt upgrade

for val in ${PkgArray[@]}; do
	dpkg -s "$val" &> /dev/null
        if [ $? -eq 0 ]; then
                echo "Package $val is installed!"
        else
                echo "Package $val is NOT installed!"
#               apt install $val
        fi
done

printf "\nFertig!\n"
printf "Wenn das die erste Installation der Software ist sollte der Raspberry Pi rebootet werden\n\n"
