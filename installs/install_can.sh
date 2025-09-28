#!/bin/bash

declare -a PkgArray=("git-core" "git" "can-utils")

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
printf "Installation der CAN-Bus Rescourcen für den AudiPi wird gestartet\n"

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

echo 'dtoverlay=mcp2515-can0,oscillator=16000000,interrupt=1' >> /boot/config.txt
echo 'dtoverlay=spi-bcm2835-overlay' >> /boot/config.txt
echo 'dtoverlay=spi0-1cs,cs0_pin=8' >> /boot/config.txt

printf "\nFertig!\n"
printf "Wenn das die erste Installation der Software ist sollte der Raspberry Pi rebootet werden\n\n"
