#!/bin/bash
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
	read -r -p "Sind Sie sicher, dass Sie die statischen IP Einstellungen aendern wollen? [y/n]" response < /dev/tty

	# Vergleich ob bestaetigt wurde
	if [[ $response =~ ^(yes|Y|y|ja|j|J)$ ]]; then
		printf "Aenderung wird ausgefuehrt\n"
	else
		printf "Abbruch\n"
		exit 1	# Installation abbrechen
	fi

	# Zusaetzliche Zeile
	echo
}

user_check
printf "Statischen IP Einstellungen werden durchgefuehrt.\n"

confirm

# dhcpcd.conf mit Daten beschreiben
echo 'interface eth0' >> /etc/dhcpcd.conf
echo 'arping 192.168.1.1' >> /etc/dhcpcd.conf
echo 'arping 192.168.2.5' >> /etc/dhcpcd.conf
echo 'fallback 192.168.1.1' >> /etc/dhcpcd.conf
echo '' >> /etc/dhcpcd.conf
echo 'profile 192.168.1.1' >> /etc/dhcpcd.conf
echo 'static ip_address=192.168.1.83/24' >> /etc/dhcpcd.conf
echo 'static routers=192.168.1.1' >> /etc/dhcpcd.conf
echo 'static domain_name_servers=192.168.1.1' >> /etc/dhcpcd.conf
echo '' >> /etc/dhcpcd.conf
echo 'profile 192.168.2.5' >> /etc/dhcpcd.conf
echo 'static ip_address=192.168.2.50/24' >> /etc/dhcpcd.conf
echo 'static routers=192.168.2.5' >> /etc/dhcpcd.conf
echo 'static domain_name_servers=192.168.2.5' >> /etc/dhcpcd.conf

# dhcpcd Dienst neustarten
systemclt restart dhcpcd

# Network interfaces beschreiben
echo '#Ethernet' >> /etc/network/interfaces
echo 'auto lo' >> /etc/network/interfaces
echo 'iface lo inet loopback' >> /etc/network/interfaces
echo '' >> /etc/network/interfaces
echo 'iface eth0 inet manual' >> /etc/network/interfaces

printf "\nFertig!\n"
printf "Der Raspberry Pi muss rebootet werden, um die Einstellungen zu uebernehmen.\n\n"